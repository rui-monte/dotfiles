alias vim="nvim"
alias vi="nvim"

# neorex opens splits as Rex panes, but needs a Rex pane on a terminal and doesn't take nvim's flags
nvim() {
  if [[ -n "$REX_SESSION" && -z "$TMUX" && -t 0 && -t 1 && "$1" != -* ]] && (( $+commands[neorex] )); then
    neorex "$@"
  else
    command nvim "$@"
  fi
}

export EDITOR="nvim"
export VISUAL="nvim"
export PATH="$HOME/.local/bin:$PATH"
