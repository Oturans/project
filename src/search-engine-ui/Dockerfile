FROM python:3.6.0-alpine

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
ENV MONGO mongo
ENV MONGO_PORT 27017
COPY . .
WORKDIR /app/ui
ENV FLASK_APP ui.py
CMD ["gunicorn","ui:app","-b","0.0.0.0" ]

# FLASK_APP=ui.py gunicorn ui:app -b 0.0.0.0