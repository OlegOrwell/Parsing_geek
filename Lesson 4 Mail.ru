import requests
from pprint import pprint
from lxml import html
import json
from pymongo import MongoClient

main_link = 'https://news.mail.ru/'
name = "Новости mail.ru"

response = requests.get(main_link, headers={'User-Agent': "Mozilla"})
dom = html.fromstring(response.text)
#news = dom.xpath("//div[@class=' js-module']")
moscow_news = dom.xpath("//li[@class='list__item list__item_height_fixed_primary']")

news = []
for new in moscow_news:
    list_news = {}

    list_news["resource"] = name
    list_news["category"] = dom.xpath(".//span[@class = 'hdr__inner']//text()")[0]

    short_text = new.xpath(".//span[@class ='link__text']/text()")
    list_news["short_text"] = short_text
    link = new.xpath(".//a[@class='link link_flex']/@href")
    list_news["link"] = link

    for lin in link:
        response_big = requests.get(lin, headers={'User-Agent': "Mozilla"})
        dom2 = html.fromstring(response_big.text)

        date_time = dom2.xpath(".//span[@class='note__text breadcrumbs__text js-ago']/@datetime")

        list_news["date"] = date_time
        list_news["news_big"] = dom2.xpath(".//div[@class='article__text js-module js-view js-mediator-article js-smoky-links']//div[@class='article__item article__item_alignment_left article__item_html']//text()")

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
