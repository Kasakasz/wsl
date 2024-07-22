source ~/.zsh/directories.zsh
source ~/.zsh/git.zsh
source ~/.zsh/prompt.zsh
source ~/.zsh/sudo.plugin.zsh

## History file configuration
[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"
[ "$HISTSIZE" -lt 50000 ] && HISTSIZE=50000
[ "$SAVEHIST" -lt 10000 ] && SAVEHIST=10000

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /home/krg/.jfrog/jfrog_zsh_completion

bindkey -v
bindkey ^R history-incremental-search-backward
bindkey ^S history-incremental-search-forward

export EDITOR='nvim'
export VISUAL='nvim'

autoload edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

alias pip=pip3
alias vsc='code --enable-features=UseOzonePlatform --ozone-platform=wayland .'
alias H=Hyprland
alias up='yay --noconfirm && npm upgrade -g && rustup update && sf update'

# compsys initialization
autoload -Uz compinit
compinit

# Custom key binds
bindkey '^p' history-beginning-search-backward
bindkey '^n' history-beginning-search-forward
bindkey -s '^o' 'code . -r\n'

# Salesforce cli autocomplete
eval
SF_AC_ZSH_SETUP_PATH=/home/krg/.cache/sf/autocomplete/zsh_setup && test -f $SF_AC_ZSH_SETUP_PATH && source $SF_AC_ZSH_SETUP_PATH; # sf autocomplete setup

eval "$(zoxide init zsh)"
