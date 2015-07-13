#
# Docker Buildkite Agent with Docker-in-Docker support
#

FROM blueimp/dind:1.6

MAINTAINER Sebastian Tschan <mail@blueimp.net>

# Install the buildkite agent:
RUN wget -O - \
  https://raw.githubusercontent.com/buildkite/agent/master/install.sh | \
  BETA=true DESTINATION=/buildkite bash

# Set the buildkite agent environment variables:
ENV PATH="$PATH":/buildkite/bin \
    BUILDKITE_BOOTSTRAP_SCRIPT_PATH=/buildkite/bootstrap.sh \
    BUILDKITE_BUILD_PATH=/buildkite/builds \
    BUILDKITE_HOOKS_PATH=/buildkite/hooks \
    BUILDKITE_DISABLE_GIT_SUBMODULES=true

# Install the envconfig script:
ADD https://raw.githubusercontent.com/blueimp/docker/1.0.0/bin/envconfig.sh \
  /usr/local/bin/envconfig
RUN chmod +x /usr/local/bin/envconfig

# Add the envconfig configuration file:
COPY envconfig.conf /usr/local/etc/envconfig.conf

# Add envconfig as entrypoint init script:
RUN ln -s /usr/local/bin/envconfig /usr/local/etc/entrypoint.d/20-envconfig.sh

# Add additional entrypoint init scripts:
COPY entrypoint.d /usr/local/etc/entrypoint.d

# Run the buildkite agent as superd process with the isolated docker daemon:
RUN echo 'buildkite-agent start' >> /usr/local/etc/superd.conf

CMD ["buildkite-agent", "start"]
