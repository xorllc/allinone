#!/bin/bash

#PROXY='http://rmdc-proxy.oracle.com:80'
USERNAME='Brian_Hamilton'
EMAIL='david.hamilton@oracle.com'
read -s -p "Enter the SSH password for 'devusr': " PASSWORD
echo

docker build \
  --build-arg proxy=${PROXY} \
  --build-arg email=${EMAIL} \
  --build-arg username=${USERNAME} \
  --build-arg password=${PASSWORD} \
  -t cheshire .
