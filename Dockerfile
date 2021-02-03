FROM python:3.9-alpine

RUN apk add --no-cache --update bash curl jq bats \
    g++ # To compile Pandas

RUN pip install pyyaml pandas

COPY bin/* /usr/local/bin/
COPY property_weights.yaml /usr/local/
