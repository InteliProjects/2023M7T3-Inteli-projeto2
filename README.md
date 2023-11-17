# Inteli - Instituto de Tecnologia e Liderança

<p align="center">
<a href= "https://www.inteli.edu.br/"><img src="https://imgur.com/fQPDDtj.png" alt="Inteli - Instituto de Tecnologia e Liderança" border="0" width=100% height=40%></a>
</p>

<br>

<br>

# CogniVoice - Inovação em Busca por Voz para a IBM

Veja aqui o [comercial](https://www.youtube.com/watch?v=z_hQXupXes4) da solução.

## Visão Geral

O CogniVoice é um motor de busca assistido por voz, criado para capacitar as equipes de marketing e vendas da IBM com acesso rápido e eficiente a insights relevantes. Utilizando tecnologias avançadas de reconhecimento de voz e processamento de linguagem natural (NLP), o CogniVoice permite que os usuários façam perguntas em linguagem natural e recebam respostas confiáveis e precisas.

## Problema a ser resolvido

Encontrar informações relevantes rapidamente é um desafio para equipes de vendas e marketing, especialmente em relação a tópicos específicos de discussão em empresas. A dinâmica dos negócios e a necessidade de mobilidade exigem uma solução acessível em dispositivos móveis, permitindo pesquisas rápidas e convenientes por voz. Assim, surge a necessidade de uma ferramenta que facilite o acesso a informações cruciais de forma eficiente e adaptada ao estilo de vida móvel dessas equipes.

## Funcionalidades Principais

-   Busca por Voz: Interaja com o sistema usando comandos de voz naturais e intuitivos.
-   Integração com Notícias e ChatGPT: Acesso a uma base de notícias atualizada periodicamente e à API do ChatGPT para garantir informações abrangentes e atualizadas.
-   Insights Rápidos e Precisos: Receba respostas rápidas e precisas que ajudam a tomar decisões informadas.

### 🚀 Integrantes

-   <a href="https://www.linkedin.com/in/antonionassar/">Antonio Nassar</a>
-   <a href="https://www.linkedin.com/in/bruno-omeira/">Bruno Meira</a>
-   <a href="https://www.linkedin.com/in/luísa-vitória-leite-silva-681443230/">Luísa Silva</a>
-   <a href="https://www.linkedin.com/in/marcelofeitoza7/">Marcelo Feitoza</a>
-   <a href="https://www.linkedin.com/in/matheusmacedosantos/">Matheus Santos</a>
-   <a href="https://www.linkedin.com/in/pedro-hagge/">Pedro Baptista</a>
-   <a href="https://www.linkedin.com/in/sofia-moreiras-pimazzoni/">Sofia Pimazzoni</a>

## 📁 Estrutura de pastas

|--> assets<br>
&emsp;| --> imagens <br>
&emsp;| --> videos <br>
&emsp;|--> readme.md<br>
|--> docs<br>
&emsp;| --> apresentação <br>
&emsp;| --> outros <br>
&emsp;|--> readme.md<br>
|--> src<br>
&emsp;|--> readme.md<br>
| readme.md<br>

Dentre os arquivos e pastas presentes na raiz do projeto, definem-se:

-   <b>assets</b>: aqui estão os arquivos relacionados a parte gráfica do projeto, ou seja, as imagens e links de vídeos que os representam (o logo do grupo pode ser adicionado nesta pasta).

-   <b>docs</b>: aqui estão todos os documentos do projeto. Há também uma pasta denominada <b>outros</b> onde estão presentes outros documentos complementares, além de um arquivo README para o grupo registrar a localização de cada artefato.

-   <b>src</b>: Todo o código fonte criado para o desenvolvimento do projeto, incluindo backend e frontend se aplicáveis.

-   <b>README.md</b>: arquivo que serve como guia e explicação geral sobre o projeto (o mesmo que você está lendo agora).

## 🔧 Instalação

O projeto pois 4 dependências notáveis: Node.js, Flutter, Rust, e Docker.

### Node.js

Para instalar o Node.js de forma simples, usaremos o NVM (Node Version Manager). Para instalar o NVM, execute o seguinte comando no terminal:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
```

Após a instalação, feche e abra o terminal novamente. Para verificar se o NVM foi instalado corretamente, execute o seguinte comando:

```bash
nvm --version
```

Agora, para instalar o Node.js na versão 18.0.0, utilizada no projeto, execute o seguinte comando:

```bash
nvm install 18.0.0
```

Para verificar se o Node.js foi instalado corretamente, execute o seguinte comando:

```bash
node --version
```

Para rodar a aplicação, execute o seguinte comando:

```bash
cd src/BackEnd && npm install && npm start
```

### Flutter

Para instalar o Flutter, siga as instruções presentes na documentação oficial: <https://flutter.dev/docs/get-started/install> selecionando o seu sistema operacional. Esse guia também inclui instruções para instalar o Android Studio, que é necessário para rodar o aplicativo em um emulador.

Após a instalação, para verificar se o Flutter foi instalado corretamente, execute o seguinte comando:

```bash
cd src/cognivoice && flutter doctor
```

Para rodar a aplicação, execute o seguinte comando:

```bash
flutter run
```

### Rust

Para instalar o Rust precisaremos apenas de um comando:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

Após a instalação, feche e abra o terminal novamente. Para verificar se o Rust foi instalado corretamente, execute o seguinte comando:

```bash
rustc --version
```

Para rodar a aplicação, execute o seguinte comando:

```bash
cd src/logger-api && cargo run
```

### Docker

Para instalar o Docker, siga as instruções presentes na documentação oficial: <https://docs.docker.com/engine/install/> selecionando o seu sistema operacional.

Após a instalação, feche e abra o terminal novamente. Para verificar se o Docker foi instalado corretamente, execute o seguinte comando:

```bash
docker --version
```

Para rodar a aplicação, execute o seguinte comando:

```bash
cd src/alert-backend && docker-compose up
```

Agora com todas as dependências instaladas, você pode rodar o projeto.

## 🗃 Histórico de lançamentos

-   0.1.0 - 11/08/2023
    -   Entendimento de negócio
    -   Entendimento de design
    -   Arquitetura do sistema 1.0
-   0.0.0 - 31/07/2023
    -   Template Inicial.

## 📋 Licença/License

<p xmlns:cc="http://creativecommons.org/ns#" xmlns:dct="http://purl.org/dc/terms/"><a property="dct:title" rel="cc:attributionURL" href="#">CogniVoice</a> by <a rel="cc:attributionURL dct:creator" property="cc:attributionName" href="#">Inteli, Antonio Nassar, Bruno Meira, Emanuel Costa, Luísa Silva, Marcelo Feitoza, Matheus Santos, Pedro Baptista, Sofia Pimazzoni</a> is 
licensed under <a href="http://creativecommons.org/licenses/by/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">Attribution 4.0 International<img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/cc.svg?ref=chooser-v1"><img style="height:22px!important;margin-left:3px;vertical-align:text-bottom;" src="https://mirrors.creativecommons.org/presskit/icons/by.svg?ref=chooser-v1"></a></p>

## 🎓 Referências

IBM. Encontre respostas rapidamente com documentos e soluções Cloud. Disponível em: <https://cloud.ibm.com/docs?locale=pt-BR>. Acesso em: set. 2023.

IBM. Speech to text. Disponível em: <https://cloud.ibm.com/apidocs/speech-to-text>. Acesso em: ago. 2023.

ADZLANI, Nasri. RabbitMQ on Docker and python. Disponível em: <https://nasriadzlani.medium.com/rabbitmq-on-docker-and-python-300e449fcc8c>. Acesso em: set. 2023.

PALLETS, Flask. API. Disponível em: <https://flask.palletsprojects.com/en/3.0.x/api/>. Acesso em: set. 2023.

_Alguns textos foram baseados em pesquisas no ChatGPT._ Disponível em: <https://chat.openai.com/>.
