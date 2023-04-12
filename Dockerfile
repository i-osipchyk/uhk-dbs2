FROM python:3.9 as base

WORKDIR /app

COPY app.py /app
COPY templates /app/templates
COPY static /app/static
COPY requirements.txt /app

RUN pip install -r requirements.txt

ENV FLASK_ENV="docker"
ENV FLASK_APP=app.py

EXPOSE 5000

##### NEW IMAGE: DEBUG #####
FROM base as debug

RUN pip install debugpy

ENV PYTHONDONTWRITEBYTECODE 1

ENV PYTHONUNBUFFERED 1

#CMD python -m debugpy --listen 0.0.0.0:5678 --wait-for-client -m flask run -h 0.0.0.0 -p 5000

##### NEW IMAGE: PRODUCTION #####
FROM base as prod

CMD flask run -h 0.0.0.0 -p 5000