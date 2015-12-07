#
# Docker Buildkite Agent with Docker-in-Docker support
#

FROM blueimp/dind:1.9

MAINTAINER Sebastian Tschan <mail@blueimp.net>

# Install the buildkite agent:
RUN wget -O - \
  https://raw.githubusercontent.com/buildkite/agent/master/install.sh | \
  DESTINATION=/buildkite bash

# Set the buildkite agent environment variables:
ENV PATH="$PATH":/buildkite/bin \
    BUILDKITE_BOOTSTRAP_SCRIPT_PATH=/buildkite/bootstrap.sh \
    BUILDKITE_BUILD_PATH=/buildkite/builds \
    BUILDKITE_HOOKS_PATH=/buildkite/hooks \
    BUILDKITE_DISABLE_GIT_SUBMODULES=true

# Add the docker user configuration:
COPY docker /root/.docker

# Add the envconfig configuration file:
COPY envconfig.conf /usr/local/etc/

# Add the entrypoint init scripts:
COPY entrypoint.d /usr/local/etc/entrypoint.d

# Run the buildkite agent as superd process with the isolated docker daemon:
RUN echo 'buildkite-agent start' >> /usr/local/etc/superd.conf

CMD ["buildkite-agent", "start"]
