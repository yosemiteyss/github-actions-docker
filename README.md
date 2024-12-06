# Self-hosted action runners using Docker

## Create runner image

- Create ubuntu image with actions runner installed, and push to ghcr.io.
- Build arm64 image:
    - `./publish-ubuntu-arm64.sh username token`
- Build x64 image:
    - `./publish-ubuntu-x64.sh username token`
- Runner version:
    - `RUNNER_VERSION="2.321.0"`

## Setup self-hosted runner for repository

- Setup repository in `docker-compose.yml`:
    - `REPO`: user/repo
    - `TOKEN`: github PAT
- Start container:
    - `docker-compose up -d`
- Remove container:
    - `docker-compose down`
