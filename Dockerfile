FROM docker.io/ubuntu:latest 

ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Basic Foundations
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq curl gnupg jq nano zip unzip wget file locales sudo ca-certificates lsb-release python3 python3-pip python3-venv python3-setuptools libicu-dev awscli cfn-lint

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_22.x  | bash -
RUN apt-get update && apt-get -y install nodejs

# Install Yarn
RUN curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get -y install yarn

# Install Global Yarn Modules
RUN yarn global add typescript npm-check-updates aws-cdk

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
RUN apt-get update && apt-get -y install gh

# Install DIR Colours
RUN git clone --recursive https://github.com/joel-porquet/zsh-dircolors-solarized ~/.zsh/zsh-dircolors-solarized

# Install zsh and configure
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)" -- \
    -t https://github.com/denysdovhan/spaceship-prompt \
    -a 'SPACESHIP_PROMPT_ADD_NEWLINE="false"' \
    -a 'SPACESHIP_PROMPT_SEPARATE_LINE="false"' \
    -a 'ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=1"' \ 
    -a 'ZSH_AUTOSUGGEST_USE_HIGHLIGHT="true"' \
    -a 'source ~/.zsh/zsh-dircolors-solarized/zsh-dircolors-solarized.zsh' \
    -a 'eval $(dircolors ~/.zsh/zsh-dircolors-solarized/dircolors-solarized/dircolors.ansi-dark)' \
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions 

RUN chsh -s /bin/zsh

# Install Azure Functions Tools
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg 
RUN mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
RUN sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" > /etc/apt/sources.list.d/dotnetdev.list'
RUN apt-get update && apt-get install azure-functions-core-tools-4
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Fetch the latest Bicep CLI binary
RUN curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64
# Mark it as executable
RUN chmod +x ./bicep
# Add bicep to your PATH (requires admin)
RUN sudo mv ./bicep /usr/local/bin/bicep
# Verify you can now access the 'bicep' command
RUN bicep --help
# Done!

# Install ACT
RUN curl https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash

# Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="false"
# Use the OSS Moby Engine instead of the licensed Docker Engine
ARG USE_MOBY="true"
# Engine/CLI Version
ARG DOCKER_VERSION="latest"
# Enable new "BUILDKIT" mode for Docker CLI
ENV DOCKER_BUILDKIT=1
# Setting username
ARG USERNAME=root
# Copy Scripts
COPY scripts/*.sh /tmp/scripts/
# Run docker-in-docker
RUN apt-get update \
    && /bin/bash /tmp/scripts/docker-in-docker-debian.sh "${ENABLE_NONROOT_DOCKER}" "${USERNAME}" "${USE_MOBY}" "${DOCKER_VERSION}" \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* /tmp/scripts/

VOLUME [ "/var/lib/docker" ]
ENTRYPOINT [ "/usr/local/share/docker-init.sh" ]
CMD [ "sleep", "infinity" ]
