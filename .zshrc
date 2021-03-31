# Enable Powerlevel10k instant prompt.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
	source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Set path
export PATH=$HOME/.dotnet/tools:$HOME/flutter/bin:$HOME/.local/share/gem/ruby/2.7.0/bin:$HOME/.yarn/bin:$HOME/bin:/usr/local/bin:/var/lib/flatpak/exports/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# omz configs
ZSH_THEME="powerlevel10k/powerlevel10k"
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )
# CASE_SENSITIVE="true"
HYPHEN_INSENSITIVE="true"
# DISABLE_AUTO_UPDATE="true"
# DISABLE_UPDATE_PROMPT="true"
export UPDATE_ZSH_DAYS=7
# DISABLE_MAGIC_FUNCTIONS="true"
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
ENABLE_CORRECTION="true"
COMPLETION_WAITING_DOTS="true"

# Plugins
plugins=(git command-not-found history-substring-search zsh-autosuggestions nvm rustup rust cargo docker docker-compose dotnet)

# Plugin Configs
export NVM_AUTOLOAD=1
export COMMAND_NOT_FOUND_INSTALL_PROMPT=1

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor
export EDITOR='nvim'

# Compilation flags
export MAKEFLAGS="-j16"

# Aliases
alias nano="nvim"
alias vi="nvim"
alias vim="nvim"
alias ls="exa -laFghHUum@ --sort name --group-directories-first --git --icons "
alias tree="exa -laFghHUumRT@ --sort name --group-directories-first --git --icons"
alias rr="curl -s -L http://bit.ly/10hA8iC | bash"
alias cat="bat"
alias parrot="curl parrot.live"
alias neofetch="neofetch | lolcat"
alias grep="batgrep"
alias sudo="doas"
alias pacman="paru"
alias man="batman"
alias gitdiff="batdiff"

# Manpage color
export LESS_TERMCAP_mb=$'\e[1;32m'
export LESS_TERMCAP_md=$'\e[1;32m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_so=$'\e[01;33m'
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;4;31m'

# Spicetify
export SPICETIFY_INSTALL="/usr/share/spicetify-cli"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Kitty
autoload -Uz compinit
compinit
# Completion for kitty
kitty + complete setup zsh | source /dev/stdin

# Command not found
command_not_found_handler() {
	local pkgs cmd="$1"

	pkgs=(${(f)"$(pkgfile -b -v -- "$cmd" 2>/dev/null)"})
	if [[ -n "$pkgs" ]]; then
		printf 'The application %s is not installed. It may be found in the following packages:\n' "$cmd"
		printf '  %s\n' $pkgs[@]
		setopt shwordsplit
		pkg_array=($pkgs[@])
		pkgname="${${(@s:/:)pkg_array}[2]}"
		printf 'Do you want to Install package %s? (y/N) ' $pkgname
		if read -q "choice? "; then
			echo
			echo "Executing command: pacman -S $pkgname"
			sudo pacman -S $pkgname
		else
			echo " "
		fi
	else
		printf 'zsh: command not found: %s\n' "$cmd"
	fi 1>&2

	return 127
}

# Git logs
gitlog() {
  setterm -linewrap off

  git --no-pager log --all --color=always --graph --abbrev-commit --decorate \
  --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' | \
  sed -E \
  -e 's/\|(\x1b\[[0-9;]*m)+\\(\x1b\[[0-9;]*m)+ /├\1─╮\2/' \
  -e 's/(\x1b\[[0-9;]+m)\|\x1b\[m\1\/\x1b\[m /\1├─╯\x1b\[m/' \
  -e 's/\|(\x1b\[[0-9;]*m)+\\(\x1b\[[0-9;]*m)+/├\1╮\2/' \
  -e 's/(\x1b\[[0-9;]+m)\|\x1b\[m\1\/\x1b\[m/\1├╯\x1b\[m/' \
  -e 's/╮(\x1b\[[0-9;]*m)+\\/╮\1╰╮/' \
  -e 's/╯(\x1b\[[0-9;]*m)+\//╯\1╭╯/' \
  -e 's/(\||\\)\x1b\[m   (\x1b\[[0-9;]*m)/╰╮\2/' \
	-e 's/(\x1b\[[0-9;]*m)\\/\1╮/g' \
  -e 's/(\x1b\[[0-9;]*m)\//\1╯/g' \
  -e 's/^\*|(\x1b\[m )\*/\1⎬/g' \
  -e 's/(\x1b\[[0-9;]*m)\|/\1│/g' | command less -r +'/[^/]HEAD'

  setterm -linewrap on
}

# Flutter
export CHROME_EXECUTABLE=/usr/bin/google-chrome-unstable

# Java
export JAVA_HOME=/usr/lib/jvm/java-15-openjdk

# Load nvm
source /usr/share/nvm/init-nvm.sh

# Neofetch cuz its cool
neofetch | lolcat
