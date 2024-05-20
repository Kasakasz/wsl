FROM ubuntu:rolling

ENV DEBIAN_FRONTEND=noninteractive
ENV HTTP_PROXY=http://becpx-forti.res.bec.dk:80
ENV HTTPS_PROXY=http://becpx-forti.res.bec.dk:80
ENV NO_PROXY=.bec.dk
RUN echo -e '--insecure' >> .curlrc
RUN apt-get update && apt-get -y upgrade
RUN apt-get install --assume-yes curl build-essential fzf git jq make neovim nodejs npm openssh-client ripgrep ruby sl stow sudo wget zoxide
RUN apt-get install --assume-yes zsh zsh-syntax-highlighting zsh-autosuggestions openjdk-11-jdk-headless tar unzip python3-pip lynx

# sfcli
RUN wget https://developer.salesforce.com/media/salesforce-cli/sf/channels/stable/sf-linux-x64.tar.xz
RUN mkdir -p /opt/sf
RUN tar xJf sf-linux-x64.tar.xz -C /opt/sf --strip-components 1
RUN ln -s /opt/sf/bin/sf /usr/bin/sf

# neovim
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
RUN tar -C /opt -xzf nvim-linux64.tar.gz
ENV PATH=/opt/nvim-linux64/bin:$PATH
RUN nvim --headless +q

RUN useradd --create-home --shell /bin/zsh -G sudo --password '$6$xyz$vVpe5cb9AP6pTO9KCbzGIgaZ1CFAxCGODy0Nmsrl2DwPEaQTbKh0XsQLAb6/afo3kisfnNPWUftZ08xPgZ/dW0' krg
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
RUN npm install --global yarn eslint prettier prettier-plugin-apex @prettier/plugin-xml npm-groovy-lint typescript
RUN /home/krg/.local/bin/yarn config set "strict-ssl" false

ENV SF_CONTAINER_MODE true
ENV SFDX_CONTAINER_MODE true
ENV SF_DISABLE_TELEMETRY true
ENV SHELL /bin/zsh
ENV FZF_DEFAULT_OPTS="--preview nvim{}"

RUN sf autocomplete
ENV DEBIAN_FRONTEND=dialog

COPY --chown=krg:krg ./sfAuthFiles/* /home/krg/sfAuthFiles/
RUN chmod +x ./wsl/docker/restoreOrgs.sh
RUN ./wsl/docker/restoreOrgs.sh

COPY --chown=krg:krg --chmod=600 ./.ssh/id_ed25519 /home/krg/.ssh/id_ed25519
COPY --chown=krg:krg --chmod=644 ./.ssh/id_ed25519.pub /home/krg/.ssh/id_ed25519.pub
COPY --chown=krg:krg --chmod=644 ./.ssh/known_hosts /home/krg/.ssh/known_hosts
RUN mkdir /home/krg/workspace
COPY --chown=krg:krg ./workspace/ /home/krg/workspace/

RUN git clone ssh://git@bitbucket.intra.bec.dk:30050/cem/nykcore.git ./nyk-core
RUN git clone ssh://git@bitbucket.intra.bec.dk:30050/cem/nykelectriccarcalculator.git ./nyk-ecc
RUN git clone ssh://git@bitbucket.intra.bec.dk:30050/cem/scoutz-common.git ./scoutz-common