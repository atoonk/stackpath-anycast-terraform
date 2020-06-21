FROM python:3

WORKDIR /usr/src/app

#COPY requirements.txt ./
#RUN pip install --no-cache-dir -r requirements.txt

COPY ./mywebserver.py .

EXPOSE 8000
ENV PYTHONUNBUFFERED 1


CMD [ "python", "./mywebserver.py" ]
