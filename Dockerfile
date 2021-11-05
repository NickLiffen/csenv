FROM docker.io/ubuntu:latest 

# Basic Foundations
RUN apt-get update && apt-get -y install curl gnupg jq nano zip unzip wget file locales sudo

# Install Python
RUN apt-get update && apt-get -y install python3 python3-pip python3-venv python3-setuptools

# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_16.x  | bash -
RUN apt-get update && apt-get -y install nodejs

# Install Yarn
RUN curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get -y install yarn

# Install Global Yarn Modules
RUN yarn global add typescript npm-check-updates

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
    -p git \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions 

RUN chsh -s /bin/zsh

# Install AWS CLI
RUN pip3 --no-cache-dir install --upgrade awscli

# Install CFN-LINT
RUN pip3 --no-cache-dir install --upgrade cfn-lint

