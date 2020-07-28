import requests
from pprint import pprint
from lxml import html
import json
from pymongo import MongoClient
from datetime import datetime

main_link = 'https://m.lenta.ru/rubrics/culture/art/'
name = "Новости lenta.ru"

response = requests.get(main_link, headers={'User-Agent': "Mozilla"})
dom = html.fromstring(response.text)
moscow_news = dom.xpath("//div[@class='rubric-page__top-card'] | //li[@class='tabloid__item _mini'] ")

news = []
for new in moscow_news:
    list_news = {}

    list_news["resource"] = name


    short_text = new.xpath(".//div[@class ='card-feature__title']/text() | .//div[@class ='card-mini__title']/text() ")
    list_news["short_text"] = short_text

    list_news["date"] = new.xpath(".//time[@class ='card-mini__date']/text()")
    if list_news["date"] == []:
        list_news["date"] = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    link = new.xpath(".//a[@class ='card-feature']/@href | .//a[@class ='card-mini']/@href")

    for lin in link:
        url = "https://lenta.ru"+lin
        list_news["link"] = url
        response_big = requests.get(url, headers={'User-Agent': "Mozilla"})
        dom2 = html.fromstring(response_big.text)
        list_news["news_big"] = dom2.xpath(".//div[@class='b-text clearfix js-topic__text']/p/text()")

    list_news["resource"] = name

    news.append(list_news)

pprint(news)

def new_data_to_mongo(news):
    client = MongoClient('127.0.0.1', 27017)
    db = client["news_db"]
    collection = db.collection

    for dat in news:
        a = dict(dat).get("link")
        p = 0
        for n in collection.find({"link": a}):
            p = 1
        if p !=1:
            collection.insert_one(dat)
        else:
            continue

    l = 0
    for col in collection.find({}):
        print(col)
        l += 1
    print(l)

new_data_to_mongo(news)
#db.collection.drop()
