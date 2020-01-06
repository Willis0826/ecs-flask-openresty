FROM python:3.7-alpine
# env
ENV APP_DIR=/usr/src/app
ENV FLASK_APP=${APP_DIR}/app.py

LABEL description="Python with flask example app"
WORKDIR ${APP_DIR}
COPY . .
RUN pip install -r requirements.txt
EXPOSE 5000
CMD [ "python", "app.py" ]
