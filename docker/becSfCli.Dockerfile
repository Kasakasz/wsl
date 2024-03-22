FROM salesforce/cli:latest-full

ENV DEBIAN_FRONTEND=noninteractive
ENV HTTP_PROXY=http://becpx-forti.res.bec.dk:80
ENV HTTPS_PROXY=http://becpx-forti.res.bec.dk:80
ENV NO_PROXY=.bec.dk
RUN echo -e '--insecure' >> .curlrc
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y build-essential fzf git jq make neovim nodejs npm openssh-client ripgrep ruby sl stow sudo wget zoxide
RUN apt-get install -y zsh zsh-syntax-highlighting zsh-autosuggestions openjdk-11-jdk-headless tar unzip python-pip lynx

RUN wget https://developer.salesforce.com/media/salesforce-cli/sf/channels/stable/sf-linux-x64.tar.xz
RUN mkdir -p /opt/sf
RUN tar xJf sf-linux-x64.tar.xz -C /opt/sf --strip-components 1
RUN ln -s /opt/sf/bin/sf /usr/bin/sf

RUN useradd --create-home --shell /bin/zsh -G sudo --password '$6$becdoker$bXrBXRidq4R.EOk5jx0LWdpgmCmN7pg0REKpHS2M/KnPHlnc6SgMRpt38r4GnvE2bAUKgmKvF6LRwDCdPnU2x.' krg
RUN sed -i -- 's/root/krg/g' /etc/sudoers

USER krg
WORKDIR /home/krg
RUN git clone https://github.com/Kasakasz/wsl.git
WORKDIR /home/krg/wsl
RUN stow neovim
RUN stow zsh
RUN stow git
RUN stow ranger
WORKDIR /home/krg
RUN npm config set strict-ssl false
RUN npm set prefix="$HOME/.local"
RUN npm install --global yarn neovim eslint prettier prettier-plugin-apex @prettier/plugin-xml npm-groovy-lint typescript
RUN /home/krg/.local/bin/yarn config set "strict-ssl" false
RUN nvim --headless +q

ENV SF_CONTAINER_MODE true
ENV SFDX_CONTAINER_MODE true
ENV SF_DISABLE_TELEMETRY true
ENV SHELL /bin/zsh

RUN sf autocomplete
ENV DEBIAN_FRONTEND=dialog