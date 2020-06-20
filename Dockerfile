FROM python:3.8-buster as base

WORKDIR /opt/app
COPY Pipfile Pipfile.lock /opt/app/


FROM base as dev-builder
RUN pip install pipenv \
  && pipenv install --system --dev


FROM base as prod-builder
RUN pip install pipenv \
  && pipenv install --system


FROM python:3.8-slim-buster as dev

COPY --from=dev-builder /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY --from=dev-builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn

WORKDIR /opt/app

COPY . /opt/app

CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app


FROM python:3.8-slim-buster as prod

COPY --from=prod-builder /usr/local/lib/python3.8/site-packages /usr/local/lib/python3.8/site-packages
COPY --from=prod-builder /usr/local/bin/gunicorn /usr/local/bin/gunicorn

WORKDIR /opt/app

COPY . /opt/app

CMD exec gunicorn --bind :$PORT --workers 1 --threads 8 --timeout 0 app:app
