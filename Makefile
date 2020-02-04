##############################################
# System configuration
##############################################

PYTHON_VERSION ?= 3.7.6


##############################################
# Paths
##############################################

BIN=/usr/local/bin
APPS=/Applications
CONFIG=~/.myconfig

##############################################
# Bootstrap
##############################################

# Install Homebrew
$(BIN)/brew: 
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install git
$(BIN)/git:
	brew install git

# Download config
$(CONFIG): $(BIN)/git
	echo "Not yet implemented"

.PHONY: fonts
fonts: | $(CONFIG)
	cp $(CONFIG)/fonts/*.otf /Library/Fonts

.PHONY: shell
shell: | $(CONFIG)
	# Install oh-my-zsh
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	ln -sf $(CONFIG)/zsh/zshrc ~/.zshrc
	ln -sf $(CONFIG)/zsh ~/.zsh

.PHONY: bootstrap
bootstrap: fonts shell


##############################################
# Command line
##############################################

$(BIN)/pyenv: $(BIN)/brew
	brew install pyenv

.PHONY: python
python: $(BIN)/python
$(BIN)/python: $(BIN)/brew $(BIN)/pyenv
	pyenv install $(PYTHON_VERSION)
	pyenv global $(PYTHON_VERSION)
	eval "$(pyenv init -)"
	pip install --upgrade pip
	

~/.vimrc: $(CONFIG) 
	ln -sf $(CONFIG)/vim/vimrc ~/.vimrc
	ln -sf $(CONFIG)/vim/vimrc.local ~/.vimrc.local
	ln -sf $(CONFIG)/vim/vimrc.local.bundles ~/.vimrc.local.bundles
	mkdir -p ~/.config/nvim
	ln -sf $(CONFIG)/vim/nvim-init.vim ~/.config/nvim/init.vim

# Install fzf and rg as vim dependencies
$(BIN)/fzf: $(BIN)/brew
	brew install fzf

$(BIN)/rg: $(BIN)/brew
	brew install ripgrep

# Vim
.PHONY: vim
vim: $(BIN)/nvim
$(BIN)/nvim: $(BIN)/brew ~/.vimrc $(BIN)/fzf $(BIN)/rg
	brew install neovim
	pip install --upgrade neovim
	nvim -c ":PlugInstall"

# Tmux
.PHONY: tmux
tmux: $(BIN)/tmux
$(BIN)/tmux: $(BIN)/brew | $(CONFIG)
	# Install version 2.9a_1
	brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/c2a5cd21a94f5574458e16198f2c4a1b7a93a0c9/Formula/tmux.rb && brew pin tmux
	git clone https://github.com/samoshkin/tmux-config.git
	./tmux-config/install.sh
	ln -sf $(CONFIG)/tmux/tmux.conf ~/.tmux.conf
	rm -rf ./tmux-config
	

.PHONY: install-commands
install-commands: vim


##############################################
# Must have applications
##############################################

# iTerm2
$(APPS)/iTerm.app: | $(BIN)/brew
	brew cask install iterm2

# Bitwarden
$(APPS)/Bitwarden.app: | $(BIN)/brew
	brew cask install bitwarden

# Firefox
$(APPS)/Firefox.app: | $(BIN)/brew
	brew cask install firefox

# Magnet
$(APPS)/Magnet.app: | $(BIN)/brew
	echo "Not implemented yet. Install Magnet using APP store"

.PHONY: install-apps
install-apps: $(APPS)/Bitwarden.app $(APPS)/iTerm.app



##############################################
# Install everything
##############################################


.PHONY: install
install: bootstrap install-commands install-apps


.DEFAULT: install
