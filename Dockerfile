ARG VARIANT="16-buster"
FROM mcr.microsoft.com/vscode/devcontainers/typescript-node:0-${VARIANT}

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
     && apt-get -y install --no-install-recommends jq nano zip unzip curl wget sudo

RUN su node -c "npm install -g husky && npm install -g npm-check-updates"
