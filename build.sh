#!/bin/bash

docker build -f ./docker/Dockerfile.prod --rm -t django-docker-box .
