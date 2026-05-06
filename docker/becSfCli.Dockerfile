# syntax=docker/dockerfile:1.7
FROM ubuntu:rolling

ENV DEBIAN_FRONTEND=noninteractive
ENV HTTP_PROXY=http://becpx-forti.res.bec.dk:80
ENV HTTPS_PROXY=http://becpx-forti.res.bec.dk:80
ENV NO_PROXY=.bec.dk
RUN echo -e '--insecure' >> .curlrc
RUN apt-get update && apt-get -y upgrade \
    && apt-get install --assume-yes curl build-essential fzf git jq make neovim nodejs npm openssh-client ripgrep ruby sl stow sudo wget zoxide \
    && apt-get install --assume-yes zsh zsh-syntax-highlighting zsh-autosuggestions openjdk-11-jdk-headless tar unzip python3-pip lynx
RUN cat <<'EOF' >/usr/local/bin/git-credential-vscode-optional
#!/bin/sh
node_bin=""
helper_js=""

for candidate in /home/krg/.vscode-server/bin/*/node; do
    if [ -x "$candidate" ]; then
        node_bin="$candidate"
        break
    fi
done

for candidate in /tmp/vscode-remote-containers-*.js; do
    if [ -f "$candidate" ]; then
        helper_js="$candidate"
        break
    fi
done

if [ -n "$node_bin" ] && [ -n "$helper_js" ]; then
    exec "$node_bin" "$helper_js" git-credential-helper "$@"
fi

exit 0
EOF
RUN chmod 0755 /usr/local/bin/git-credential-vscode-optional

# sfcli
RUN wget https://developer.salesforce.com/media/salesforce-cli/sf/channels/stable/sf-linux-x64.tar.xz \
    && mkdir -p /opt/sf \
    && tar xJf sf-linux-x64.tar.xz -C /opt/sf --strip-components 1 \
    && ln -s /opt/sf/bin/sf /usr/bin/sf

# neovim
RUN curl -LO https://github.com/neovim/neovim/releases/download/v0.12.2/nvim-linux-x86_64.tar.gz \
    && tar -C /opt -xzf nvim-linux-x86_64.tar.gz
ENV PATH=/opt/nvim-linux-x86_64/bin:$PATH
RUN nvim --headless +q \
    && curl --insecure 'https://ftp.nluug.nl/pub/vim/runtime/spell/pl.utf-8.spl' --create-dirs -o '/opt/nvim-linux-x86_64/share/nvim/runtime/spell/pl.utf-8.spl'

ADD https://github.com/zsh-users/zsh-autosuggestions.git /usr/share/zsh/plugins/zsh-autosuggestions
ADD https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh/plugins/zsh-syntax-highlighting

RUN useradd --create-home --shell /bin/zsh -G sudo --password '$6$nooneknows$/v16z4qG1mJ3zqKrKWSCAoglhbUk1VMKqo23Zgs3U.O6SMhrIpWesLb/B9STU3tYSD7xYh/FPFiSk4OEXSbrt.' krg \
    && sed -i -- 's/root/krg/g' /etc/sudoers

USER krg
ENV HOME=/home/krg
WORKDIR /home/krg
RUN git clone https://github.com/Kasakasz/wsl.git
WORKDIR /home/krg/wsl
RUN stow neovim \
    && stow zsh \
    && stow git \
    && stow ranger
RUN git config --global --replace-all credential.helper '!f() { /usr/local/bin/git-credential-vscode-optional "$@"; }; f' \
    && git config --global --add credential.helper store
WORKDIR /home/krg
RUN npm config set strict-ssl false \
    && npm set prefix="$HOME/.local" \
    && npm install --global yarn eslint prettier prettier-plugin-apex @prettier/plugin-xml npm-groovy-lint typescript \
    && /home/krg/.local/bin/yarn config set "strict-ssl" false

ENV SF_CONTAINER_MODE true
ENV SFDX_CONTAINER_MODE true
ENV SF_DISABLE_TELEMETRY true
ENV SHELL /bin/zsh

RUN sf autocomplete
ENV DEBIAN_FRONTEND=dialog
RUN echo "insecure" >> .curlrc

COPY --chown=krg:krg ./sfAuthFiles/* /home/krg/sfAuthFiles/
RUN chmod +x ./wsl/docker/restoreOrgs.sh \
    && ./wsl/docker/restoreOrgs.sh skipcache

RUN mkdir /home/krg/workspace
COPY --chown=krg:krg ./workspace/ /home/krg/workspace/

USER root
# clone repos
RUN --mount=type=secret,id=git_credentials,target=/root/.git-credentials,mode=0600 \
    bitbucket_remote="$(grep 'bitbucket.intra.bec.dk' /root/.git-credentials | head -n 1 | tr -d '\r')" \
    && test -n "$bitbucket_remote" \
    && git clone "$bitbucket_remote/scm/cem/nykcore.git" /home/krg/nyk-core \
    && git clone "$bitbucket_remote/scm/cem/nykelectriccarcalculator.git" /home/krg/nyk-ecc \
    && git clone "$bitbucket_remote/scm/cem/scoutz-common.git" /home/krg/scoutz-common \
    && git clone "$bitbucket_remote/scm/cem/credit.git" /home/krg/credit-blazers \
    && git clone "$bitbucket_remote/scm/cem/creditforce.git" /home/krg/credit-force \
    && git clone "$bitbucket_remote/scm/cem/scoutz-customer-ui.git" /home/krg/scoutz-customer-ui \
    && git clone "$bitbucket_remote/scm/cem/case-management.git" /home/krg/case-management \
    && chown -R krg:krg /home/krg/nyk-core /home/krg/nyk-ecc /home/krg/scoutz-common /home/krg/credit-blazers /home/krg/credit-force /home/krg/scoutz-customer-ui /home/krg/case-management

USER krg

CMD ["/bin/zsh", "-i"]