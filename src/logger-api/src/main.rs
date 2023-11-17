use actix_web::middleware::Logger;
use actix_web::{get, post, web, App, HttpRequest, HttpResponse, HttpServer, Responder};
use chrono::{DateTime, Utc};
use serde::{Deserialize, Serialize};
use std::fs::OpenOptions;
use std::io::Write;

#[derive(Serialize)]
pub struct GenericResponse {
    pub status: String,
    pub message: String,
}

#[derive(Deserialize)]
pub struct LogInfo {
    level: String,
    message: String,
    error: Option<String>,
    stackTrace: Option<String>,
}

fn format_log_entry(info: &LogInfo, time: DateTime<Utc>, request: &HttpRequest) -> String {
    let error = match &info.error {
        Some(error) if !error.is_empty() => format!("- [{}]", error),
        _ => String::new(),
    };

    let stack_trace = match &info.stackTrace {
        Some(stack_trace) if !stack_trace.is_empty() => format!("- [{}]", stack_trace),
        _ => String::new(),
    };

    let client_ip = match request.connection_info().peer_addr() {
        Some(ip) => ip.to_string(),
        None => String::new(),
    };

    format!(
        "[{}] - [{}] [{}] - {} {} {}",
        &client_ip,
        time.to_rfc3339(),
        info.level,
        info.message,
        error,
        stack_trace
    )
}

fn save_log(log_entry: &str) -> Result<(), Box<dyn std::error::Error>> {
    let file = OpenOptions::new()
        .append(true)
        .create(true)
        .open("cognivoice.log")?;

    let mut file = std::io::LineWriter::new(file);

    let log_entry = log_entry.replace('\n', " ").replace('\r', " ");

    file.write_all(log_entry.as_bytes())?;
    file.write_all(b"\n")?;

    Ok(())
}

#[post("/logs")]
async fn logs_handler(info: web::Json<LogInfo>, request: HttpRequest) -> impl Responder {
    let now: DateTime<Utc> = Utc::now();
    let log_entry: String = format_log_entry(&info, now, &request);

    if let Err(err) = save_log(&log_entry) {
        eprintln!("Error saving log: {}", err);
        return HttpResponse::InternalServerError().json(GenericResponse {
            status: "error".to_string(),
            message: "Failed to save log".to_string(),
        });
    }

    HttpResponse::Ok().json(GenericResponse {
        status: "success".to_string(),
        message: "Log saved successfully".to_string(),
    })
}

#[get("/")]
async fn health_handler() -> impl Responder {
    HttpResponse::Ok().json(GenericResponse {
        status: "success".to_string(),
        message: "Server is running".to_string(),
    })
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    if std::env::var_os("RUST_LOG").is_none() {
        std::env::set_var("RUST_LOG", "actix_web=info");
    }
    env_logger::init();


    let address = "0.0.0.0:3002"; // Bind to all available network interfaces

    println!("Started on http://{}", address);

    HttpServer::new(move || {
        App::new()
            .service(logs_handler)
            .service(health_handler)
            .wrap(Logger::default())
    })
    .bind(address)?
    .run()
    .await
}
