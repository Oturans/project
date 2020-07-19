FROM python:3.6.0-alpine

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
ENV MONGO mongo
ENV MONGO_PORT 27017
ENV RMQ_HOST rabbit
ENV RMQ_QUEUE urls
ENV RMQ_USERNAME guest
ENV RMQ_PASSWORD guest 
COPY . .
ENV EXCLUDE_URLS .*github.com
CMD ["python","-u","crawler/crawler.py","https://vitkhab.github.io/search_engine_test_site/"]
