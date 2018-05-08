# Cheshire
## A Disposal Development Environment for Docker-based Services

Cheshire is an experimental project that explores the following ideas
* Using Docker containers to develop Docker container-based services (Docker-in-Docker)
* Using disposable dev environments that can be created and torn down as needed.

### Build
* If running within the corporate network, do the following to completely build from scratch.
```
  docker build \
  --build-arg proxy=http://rmdc-proxy.oracle.com:80 \
  --build-arg username=Brian_Hamilton \
  --build-arg email=david.hamilton@oracle.com \
  --no-cache \
  -t cheshire .
```
* If running with direct access to the internet, run the same build command, omitting the proxy build-arg above.

### Usage
* Run `docker run -p 30022:22 -p 30090-30099:30090-30099 -d --privileged cheshire` to start the environment. This particular setup allows SSH access from port 30022 and allows up to 10 web services started in the environment to be exposed to the host the Cheshire instance runs on.
* To SSH into the environment with the above example from the host this container runs on, do `ssh -p 30022 devusr@localhost`. Run `ssh -p 30022 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no devusr@localhost` to the above command if the container has restarted and you don't want to modify the ~/.ssh/known_hosts file.
* Note that this environment is configured to use xonsh when creating devusr. to review the tutorial, remove the .xonshrc included in this project.
