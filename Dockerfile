FROM debian:12-slim

WORKDIR /root
ENV LANG en_US.UTF-8

## Update Debian packages
# RUN sed -i 's@deb.debian.org@mirrors.tuna.tsinghua.edu.cn@g' /etc/apt/sources.list.d/debian.sources
RUN apt-get clean && apt-get update && \
	apt-get install --no-install-recommends -y ninja-build gettext cmake unzip curl build-essential wget \
	git ripgrep fd-find bear zsh \
	lua5.4 python3 python3-pip python3-neovim python3-venv npm

## Utils
ENV PATH=/root/.cargo/bin:$PATH
ENV RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
ENV RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init && \
    chmod +x rustup-init && \
    ./rustup-init -y --default-toolchain nightly && \
    rm rustup-init && \
    . $HOME/.cargo/env
RUN git clone https://github.com/kamiyaa/joshuto.git && \
    cd joshuto && \
    cargo install --path=. --force --root=/usr/local && \
    cd .. && \
    rm -r joshuto
Run git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && \
    yes | zsh -c ~/.fzf/install
RUN cargo install starship --locked
 
## Config files
RUN git clone https://github.com/rqdmap/dotfiles.git
RUN mv /root/dotfiles/config/.zsh /root/ && \
    mv /root/dotfiles/config/.zshrc /root/ && \
	mkdir -p /root/.config && \
	mv /root/dotfiles/config/.config/joshuto /root/.config && \
	mv /root/dotfiles/config/.config/starship.toml /root/.config && \
	mv /root/dotfiles/config/.config/nvim /root/.config && \
	rm -rf /root/dotfiles

## Neovim 
RUN git clone https://github.com/neovim/neovim && cd neovim && make CMAKE_BUILD_TYPE=RelWithDebInfo -j $(nproc) && make install && cd .. && rm -rf neovim
RUN npm install -g neovim
ARG MASON_LSP="bash-language-server lua-language-server pyright python-lsp-server rust-analyzer"
RUN nvim --headless "+Lazy! sync" +MasonUpdate +"MasonInstall ${MASON_LSP}" +qa

## Clean
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
	apt-get autoremove -y && apt-get autoclean -y

CMD tail -f /dev/null

