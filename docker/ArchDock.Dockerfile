FROM archlinux

RUN pacman -Syu --noconfirm
RUN pacman --noconfirm -S base-devel fzf git jq make neovim nodejs npm openssh ripgrep rustup ruby sl stow stylua sudo tree-sitter-cli wget which yazi zoxide
RUN pacman --noconfirm -S zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions jdk17-openjdk tar unzip python-pip lynx
RUN pacman --noconfirm -S ruby ruby-rdoc gcc make
RUN gem update --user-install
RUN gem install jekyll --user-install

RUN wget https://developer.salesforce.com/media/salesforce-cli/sf/channels/stable/sf-linux-x64.tar.xz
RUN mkdir -p /opt/sf
RUN tar xJf sf-linux-x64.tar.xz -C /opt/sf --strip-components 1
RUN ln -s /opt/sf/bin/sf /usr/bin/sf

RUN useradd --create-home --shell $(which zsh) --groups wheel --password '$2y$10$QaP8vQoQ6vgBFfTDlzMRYuFMhANtTnhPQ5BY3U.J9r7KzWi0jVlX2' kasakasz
RUN sed -i -- 's/root/kasakasz/g' /etc/sudoers

USER kasakasz
WORKDIR /home/kasakasz
RUN git clone https://github.com/Kasakasz/wsl.git
WORKDIR /home/kasakasz/wsl
RUN stow neovim
RUN stow zsh
RUN stow git
RUN stow ranger
WORKDIR /home/kasakasz
RUN npm config set strict-ssl false
RUN npm set prefix="$HOME/.local"
RUN npm install --global yarn neovim eslint prettier prettier-plugin-apex @prettier/plugin-xml npm-groovy-lint typescript
RUN /home/kasakasz/.local/bin/yarn config set "strict-ssl" false
RUN nvim --headless +q

ENV SF_CONTAINER_MODE true
ENV SFDX_CONTAINER_MODE true
ENV SF_DISABLE_TELEMETRY true
RUN sf autocomplete

ENV SHELL /bin/zsh
