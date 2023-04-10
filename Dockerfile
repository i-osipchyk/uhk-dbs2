FROM python:3.9

EXPOSE 5000

WORKDIR /app

COPY requirements.txt /app
RUN pip install -r requirements.txt

COPY app.py /app
COPY templates /app/templates
COPY static /app/static

CMD python app.py