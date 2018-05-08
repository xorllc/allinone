#!/bin/bash

IMAGE=allinone

docker run -d \
  -p 4000:4000 \
  -p 2222:22 \
  --name desk3 \
  -e PASSWORD=zaksab37 \
  -e USER=user \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --cap-add=SYS_PTRACE \
  --cap-add=NET_ADMIN \
  ${IMAGE}
