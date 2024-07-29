FROM ubuntu:24.04

ARG RUNNER_VERSION="2.318.0"
ARG RUNNER_ARCH="linux-arm64"

# Prevents installdependencies.sh from prompting the user and blocking the image creation
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt upgrade -y

# Add new user as runners can't be launched by the root user.
RUN useradd -m docker

# Install dependencies
RUN apt install -y --no-install-recommends \
    curl jq build-essential libssl-dev libffi-dev python3 python3-venv python3-dev python3-pip

# Download runner
RUN cd /home/docker && mkdir actions-runner && cd actions-runner
RUN curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz 
RUN tar xzf ./actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz

# Install runner dependencies
RUN chown -R docker ~docker && /home/docker/actions-runner/bin/installdependencies.sh

COPY start.sh start.sh
RUN chmod +x start.sh

USER docker

ENTRYPOINT ["./start.sh"]