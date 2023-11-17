import pandas as pd
import numpy as np

from unidecode import unidecode

import spacy

#nltk para pre proscesamento e tokenização
import nltk
nltk.download('punkt')

from nltk.tokenize import word_tokenize
from nltk.tokenize import sent_tokenize
import re

from nltk.stem import WordNetLemmatizer

nltk.download('rslp')

stemmer = nltk.stem.RSLPStemmer()

# Pacote nlp para portugues
nlp = spacy.cli.download('pt_core_news_sm')
nlp = spacy.load('pt_core_news_sm')

#Biblioteca usada para consultar uma URL
import requests
import urllib.request
from urllib.request import urlopen
from urllib.error import HTTPError

#Biblioteca usada analisar os dados retornados da url
from bs4 import BeautifulSoup


#importação de keras, para execução do modelo e criação do dicionario
from keras.preprocessing.text import Tokenizer

#setup w2vec
import gensim
from scipy.spatial.distance import cosine
from gensim.models import KeyedVectors

# Biblioteca para funções matemáticas
import math
import os


def remocaoAcentos(text):
    return unidecode(text)

def maiusculas(dados):
    if isinstance(dados, pd.DataFrame):
        return dados.applymap(lambda x: x.lower() if isinstance(x, str) else x)
    elif isinstance(dados, str):
        return dados.lower()
    else:
        return dados

def lowercase_text(text):
  return text.lower()

def clean_title(match_comp):
    pattern = re.compile(r'^(.*?)\s*(-|\||por)\s*.*$')
    match = pattern.match(match_comp)
    return match.group(1) if match else match_comp

def remove_marks(text):
    if isinstance(text, str): #verifica se o que está sendo processado é uma string
        return re.sub(r'[^\w\s]|_', '', text) #substituir todos os caracteres especiais por uma string vazia
    else:
        return text

def remove_aspas(column_or_text):
    if isinstance(column_or_text, pd.Series):  # Verifica se é uma coluna de DataFrame
        return column_or_text.apply(remove_aspas)
    elif isinstance(column_or_text, str):  # Verifica se é uma string
        return column_or_text.replace('"', '')
    else:
        return column_or_text  # Retorna outros tipos de dados sem modificação


def remove_duplicate_spaces(text):
    # Substitui sequências de espaços em branco por um único espaço
    cleaned_text = re.sub(r'\s+', ' ', text)
    return cleaned_text.strip()

def remove_isolated_numbers(text):
    # Substitui números isolados por um espaço em branco
    cleaned_text = re.sub(r'\b\d+\b', '', text)
    return cleaned_text.strip()

def extrair_titulo(url):
    print(url)
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36'
    }

    try:
        req = urllib.request.Request(url, headers=headers)
        page = urllib.request.urlopen(req)

        # response = requests.get(url, headers=headers)
        # response.raise_for_status()

        soup = BeautifulSoup(page, 'html.parser')
        title_new = soup.title.string
        title_new = clean_title(title_new)
        return title_new
    except HTTPError as e:
        print(f"Erro ao acessar a URL {url}: {e}")
        return ""  # Retorna um título vazio em caso de erro

def remove_tags(url):
    try:
        useless_tittle = extrair_titulo(url)
        useless_tittle = remocaoAcentos(useless_tittle)
        useless_tittle = maiusculas(useless_tittle)
        tittle = clean_title(useless_tittle)

        # parse html content
        headers = {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Safari/537.36'
        }

        # req = urllib.request.Request(url, headers=headers)
        # page = urllib.request.urlopen(req)

        page = requests.get(url, headers=headers)
        page.raise_for_status()

        soup = BeautifulSoup(page.text, "html.parser")

        for data in soup(['style', 'script', 'title']):
            # Remove as tags
            data.decompose()

        # return data by retrieving the tag content
        all_text = ' '.join(soup.stripped_strings)

        all_text = maiusculas(all_text)
        all_text = remocaoAcentos(all_text)

        quebra = all_text.find(tittle)

        if quebra != -1:  # verifica encontrou a quebra
            all_text = all_text[quebra:]
            all_text = remove_marks(all_text)
            all_text = remove_aspas(all_text)
            all_text = remove_duplicate_spaces(all_text)
            all_text = remove_isolated_numbers(all_text)
            return all_text
        else:
            all_text = remove_marks(all_text)
            all_text = remove_aspas(all_text)
            all_text = remove_duplicate_spaces(all_text)
            all_text = remove_isolated_numbers(all_text)
            return all_text
    except Exception as e:
        print(f"Erro ao processar a URL {url}: {e}")
        return ""  # Retorna uma string vazia em caso de erro

date_regex = [
  r'(\d{1,2} de [a-zA-Z]+ de \d{4})',
  r'(\d{1,2}/\d{1,2}/\d{2,4})',
  r'(\d{1,2} [a-zA-Z]+ \d{2,4})'
]

def extract_dates(row):
    quebra = row['tag_removed'].find(row['titulo'])
    for regex in date_regex:
        match = re.search(regex, row['tag_removed'][quebra:])
        if match:
            return match.group(1)
    return None

def extrair_dominio(url):
    regex_url = r'https://(.*?)/'
    fonte = re.findall(regex_url, url)
    if fonte:
        return fonte[0]
    else:
        return None

def named_entities_filtred(coluna, filtro):
  results = []
  for linha in coluna:
    # print(linha)
    doc = nlp(linha)
    org_entities = set(ent.text for ent in doc.ents if ent.label_ == filtro)
    entities = [(ent.text, ent.label_) for ent in doc.ents]
    results.append(org_entities)
    # print("teste",results)
  return results

def named_entities(coluna):
  results = []
  for linha in coluna:
    # print(linha)
    doc = nlp(linha)
    entities = [(ent.text, ent.label_) for ent in doc.ents]
    results.append(entities)
    # print("teste",results)
  return results

def stopWords(dados):
    if isinstance(dados, str):
        dados = [dados]

    resultado = [' '.join([token.text for token in nlp(texto) if not token.is_stop]) for texto in dados]

    return resultado

def lematizar(dados):
    resultado = []
    for texto in dados:
        # Processa o texto com o modelo do Spacy
        doc = nlp(texto)
        # Lematiza o documento
        lemmas = [token.lemma_ for token in doc]
        # Junta tudo de volta a um texto
        textoLemmatizado = ' '.join(lemmas)
        resultado.append(textoLemmatizado)
    return resultado

def tokenizar_texto(texto):
    doc = nlp(texto)
    tokens = [token.text for token in doc]
    return tokens

def pipeline_dataframe(dados, colum_name):
  #Cria um dataframe vazio para armazenar os dados tratados
  treated_data =  pd.DataFrame()

  #Busca pela url o site, faz o tratamento do html e retorna o texto da noticia
  treated_data["data"] = dados[colum_name].apply(remove_tags)

  treated_data["data"] = treated_data["data"].apply(remove_duplicate_spaces)

  #Remove possiveis acentos da tabela
  treated_data = treated_data.applymap(remocaoAcentos)

  treated_data = treated_data.applymap(lowercase_text)

  treated_data["data"] = stopWords(treated_data["data"])

  treated_data["data"] = lematizar(treated_data["data"])

  treated_data["data"] = treated_data["data"].apply(tokenizar_texto)

  return treated_data

def pipeline_speech_to_text(text):
  array_phrase = []

  text = remocaoAcentos(text)

  text = lowercase_text(text)

  text = remove_marks(text)

  text = stopWords(text)

  text = lematizar(text)

  text = tokenizar_texto(str(text)[1:-1].strip("'"))

  array_phrase.append(text)

  return array_phrase

from sentence_transformers import SentenceTransformer

#função para vetorização
def Vetorizacao(dataframe,modelo):
  # Calcula os embeddings para a coluna de texto
  embeddings_liz = modelo.encode(dataframe.tolist())

  # Cria um novo DataFrame com os embeddings
  embeddings_df = pd.DataFrame(embeddings_liz)

  return embeddings_df

vetorizadorTransformers = SentenceTransformer('distiluse-base-multilingual-cased')

def calculate_similiarity(vectors: list, phrase_vector: list) -> float:
    text_similarity_array = []

    if str(type(phrase_vector)) != "<class 'numpy.ndarray'>":
      phrase_vector = phrase_vector.values
    else:
      pass

    for index, row in vectors.iterrows():
        np_vector_row = row.values
        np_vector_text = phrase_vector

        product_sum = np.sum(np_vector_row * np_vector_text)

        squared_frase_um = np.square(np_vector_row)
        squared_frase_dois = np.square(np_vector_text)

        sum_of_squares_array1 = np.sum(squared_frase_um)
        sum_of_squares_array2 = np.sum(squared_frase_dois)

        modulo = math.sqrt(sum_of_squares_array1) * math.sqrt(sum_of_squares_array2)

        text_similarity = product_sum / modulo

        text_similarity_array.append(text_similarity)


    return text_similarity_array

def encontrar_maiores(array):
    maiores = []
    for i, numero in enumerate(array):
        if numero > 0.85:
            maiores.append([numero, i])

    maiores.sort(reverse=True)

    if len(maiores) >= 3:
        return maiores[:3]
    elif len(maiores) > 0:
        return maiores
    else:
        return 'Nao ha nenhuma noticia correspondente em nosso banco de dados.'

import json

def encontrar_noticias(indices, dataframe, coluna):
    noticias = []

    if str(type(indices)) == "<class 'str'>":
      return 'Nao ha nenhuma noticia correspondente em nosso banco de dados.'

    for i in indices:
        noticias.append(dataframe[coluna][i[1]])

    noticias_dict = {
        "noticia1": noticias[0] if len(noticias) > 0 else None,
        "noticia2": noticias[1] if len(noticias) > 1 else None,
        "noticia3": noticias[2] if len(noticias) > 2 else None
    }

    json_data = json.dumps(noticias_dict)

    return json_data

url = 'http://10.128.67.156:3001/v1/url/getall'
response = requests.get(url)

if response.status_code == 200:
    data = response.json()
else:
    print('Erro ao obter os dados da API')

df_news_database = pd.DataFrame(data)

df_news = pd.DataFrame()
df_news['all_news'] = df_news_database['url'].apply(remove_tags)

df_news_database_vectors = pipeline_dataframe(df_news_database, "url")
df_news_database_vectors

df_full_news_transformers = Vetorizacao(df_news_database_vectors['data'], vetorizadorTransformers)

"""# 19.0 Flask API"""

from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

# Rota de saúde
@app.route("/health", methods=['GET'])
def health_check():
    return "API está rodando sem erros", 200

# Rota para processar a entrada de voz
@app.route("/process_audio", methods=['POST'])
def process_audio():
    try:
        data = request.get_json()
        if data is not None and 'text' in data:
            text_value = data['text']

            text_value = pipeline_speech_to_text(text_value)

            vector_text = vetorizadorTransformers.encode(text_value)

            news_response = calculate_similiarity(df_full_news_transformers,vector_text)

            news_index = encontrar_maiores(news_response)

            news_response = encontrar_noticias(news_index, df_news, 'all_news')

            return news_response, 200
        else:
            return jsonify({"erro": "Dados JSON inválidos"}), 400
    except Exception as e:
        return jsonify({"erro": str(e)}), 500

@app.route("/call_external_api", methods=['GET'])
def update_news():
    url = 'http://10.128.67.156:3001/v1/url/getall'
    response = requests.get(url)

    if response.status_code == 200:
        data = response.json()
    else:
        print('Erro ao obter os dados da API')

    df_news_database = pd.DataFrame(data)

    df_news['all_news'] = df_news_database['url'].apply(remove_tags)

    df_news_database_vectors = pipeline_dataframe(df_news_database, "url")

    df_full_news_transformers = Vetorizacao(df_news_database_vectors['data'], vetorizadorTransformers)

    return "Vetores atualizados com sucesso", 200

if __name__ == '__main__':
    app.run(port=3000)
