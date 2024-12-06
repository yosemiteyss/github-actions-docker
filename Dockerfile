FROM ghcr.io/catthehacker/ubuntu:act-22.04

ARG RUNNER_VERSION="2.321.0"
ARG RUNNER_ARCH="linux-x64"
ARG DEBIAN_FRONTEND=noninteractive

# Update dependencies
RUN apt update -y
RUN apt upgrade -y

# Add runner user to docker group
RUN useradd -m runner
RUN usermod -aG docker runner

# Disable sudo password for runner
RUN echo "runner ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

# Download and extract runner
RUN mkdir -p /home/runner/actions-runner && \
    cd /home/runner/actions-runner && \
    curl -O -L https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz && \
    tar xzf ./actions-runner-${RUNNER_ARCH}-${RUNNER_VERSION}.tar.gz

# Install runner dependencies
RUN chown -R runner /home/runner/actions-runner
RUN /home/runner/actions-runner/bin/installdependencies.sh

# Copy start script
COPY start.sh /home/runner/start.sh
RUN chmod +x /home/runner/start.sh

# Copy delete script
COPY delete-runners.sh /home/runner/delete-runners.sh
RUN chmod +x /home/runner/delete-runners.sh

# Switch to new user
USER runner
WORKDIR /home/runner

ENTRYPOINT ["/home/runner/start.sh"]
