FROM python:3.9

RUN         apt-get update

WORKDIR    /app
COPY       . /app
# Copy my project folder content into /app container directory
RUN        pip install -r requirements.txt
EXPOSE     8000


CMD ["python", "app/app.py"]
