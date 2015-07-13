# Docker Buildkite Agent

Minimal Docker-in-Docker (dind) image based on Alpine Linux running the
[Buildkite Agent](https://github.com/buildkite/agent).  
Includes docker, docker-compose, python, pip, git, bash and openssh-client.  
Supports running docker isolated or bind-mounting the host docker socket.

## Usage

### Provide secrets as environment variables

```sh
export BUILDKITE_AGENT_TOKEN=banana

export SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"
export SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub)"
export SSH_KNOWN_HOSTS="$(cat ~/.ssh/known_hosts)"
```

Replace "banana" with your buildkite agent token.  
Adjust the SSH file paths to the configuration files for your agent.

### Using the host docker daemon

Create a data-only container for the buildkite agent builds data:

```bash
docker create \
  -v /buildkite/builds:/buildkite/builds \
  --name=buildkite-builds \
  tianon/true
```

Start the agent with the builds volume and the bind-mounted host docker socket:

```bash
docker run -it \
  -e BUILDKITE_AGENT_TOKEN="$BUILDKITE_AGENT_TOKEN" \
  -e SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" \
  -e SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" \
  -e SSH_KNOWN_HOSTS="$SSH_KNOWN_HOSTS" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --volumes-from=buildkite-builds \
  blueimp/buildkite-agent
```

Share build data with docker containers run as buildkite agent tasks:

```bash
docker run --rm \
  --volumes-from=buildkite-builds \
  --workdir="$PWD" \
  busybox ls -l
```

### Using an isolated docker daemon

Start the buildkite agent with an isolated docker daemon:

```sh
docker run -it \
  -e BUILDKITE_AGENT_TOKEN="$BUILDKITE_AGENT_TOKEN" \
  -e SSH_PRIVATE_KEY="$SSH_PRIVATE_KEY" \
  -e SSH_PUBLIC_KEY="$SSH_PUBLIC_KEY" \
  -e SSH_KNOWN_HOSTS="$SSH_KNOWN_HOSTS" \
  -v /var/lib/docker \
  --privileged \
  blueimp/buildkite-agent superd
```

Share build data with docker containers run as buildkite agent tasks:

```bash
docker run --rm \
  -v "$PWD":"$PWD" \
  --workdir="$PWD" \
  busybox ls -l
```

Please note that the isolated Docker-in-Docker daemon is experimental.

## Customization

### Adding support for Git submodules

Create a custom docker image to enable Git submodules:

```
FROM blueimp/buildkite-agent

RUN apk add --update perl && rm -rf /tmp/* /var/cache/apk/*

ENV BUILDKITE_DISABLE_GIT_SUBMODULES=""
```

### Configuring the buildkite agent

Almost all agent settings can be set with environment variables.  
Alternatively, you can copy a configuration file into the container:

```
FROM blueimp/buildkite-agent

COPY buildkite-agent.cfg /buildkite/buildkite-agent.cfg

ENV BUILDKITE_AGENT_CONFIG=/buildkite/buildkite-agent.cfg
```

Please see https://buildkite.com/docs/agent/configuration for more information.

### Adding hooks for the buildkite agent

You can add hooks with a custom docker image:

```
FROM blueimp/buildkite-agent

COPY hooks /buildkite/hooks
```

Please see https://buildkite.com/docs/agent/hooks for more information.
