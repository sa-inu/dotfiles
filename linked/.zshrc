# Environmental Variables# {{{
export LANG=ja_JP.UTF-8
export EDITOR=/usr/local/bin/vim
export PATH=/usr/local/bin:$PATH
export PATH="$(brew --prefix homebrew/php/php70)/bin:$PATH"
export PATH=$HOME/.nodebrew/current/bin:$PATH
export PATH=$HOME/.rbenv/bin:$PATH
export PATH=$HOME/.pyenv/bin:$PATH
export PATH=$HOME/Library/Python/2.7/bin:$PATH
if [ -x "`which go`" ]; then
  export GOROOT=`go env GOROOT`
  export GOPATH=$HOME/code/go-local
  export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
fi
eval "$(rbenv init - zsh)"
eval "$(pyenv init - zsh)"
# }}}
# Load Color{{{
autoload -Uz colors
colors
setopt prompt_subst
# ForeGround: %{$fg[code]%}
# BackGround: %{$bg[code]%}
# Reset: %{$reset_color%}
# Codes: {
# 0: black,
# 1: red,
# 2: green,
# 3: yellow,
# 4: blue,
# 5: magenta,
# 6: cyan,
# 7: white
# }
# }}}
# Load alias# {{{
if [ -f ~/.aliases ]; then
  . ~/.aliases
fi
# }}}
# Shell Settings{{{
setopt ignore_eof
setopt interactive_comments
setopt no_beep
setopt no_flow_control
setopt nonomatch
setopt pushd_ignore_dups
setopt nolistbeep

REPORTTIME=3

# Completion{{{
autoload -U compinit && compinit
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
setopt auto_param_slash
setopt mark_dirs
setopt list_types
setopt auto_menu
setopt auto_param_keys
setopt magic_equal_subst
setopt complete_in_word
setopt always_last_prompt
setopt print_eight_bit
setopt extended_glob
setopt globdots
setopt brace_ccl
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' verbose yes
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list _history
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-separator '-->'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' '+m:{A-Z}={a-z}'
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:messages' format '%F{YELLOW}%d'$DEFAULT
zstyle ':completion:*:warnings' format '%F{RED}No matches for:''%F{YELLOW} %d'$DEFAULT
zstyle ':completion:*:descriptions' format '%F{YELLOW}completing %B%d%b'$DEFAULT
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'$DEFAULT
zstyle ':completion:*:cd:*' ignore-parents parent pwd
zstyle ':completion:*:*files' ignored-patterns '*?.o' '*?~' '*\#'
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# zsh-completions
[ -d $HOME/.zsh/zsh-completions/src ] && fpath=($HOME/.zsh/zsh-completions/src $fpath)

source /usr/local/Cellar/zsh-syntax-highlighting/0.5.0/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

setopt auto_cd
function chpwd() { ls }

# autoload predict-on
# predict-on
# }}}
# History# {{{
HISTFILE=${HOME}/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt extended_history
setopt hist_ignore_all_dups
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_save_no_dups
setopt hist_reduce_blanks
setopt share_history
# }}}
# Prompt# {{{
autoload -Uz vcs_info
autoload -Uz add-zsh-hook
autoload -Uz is-at-least
autoload -Uz colors
zstyle ':vcs_info:*' max-exports 3
zstyle ':vcs_info:*' enable git svn hg bzr
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b]' '%m' '<!%a>'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true
if is-at-least 4.3.10; then
    zstyle ':vcs_info:git:*' formats '(%s)-[%b]' '%c%u %m'
    zstyle ':vcs_info:git:*' actionformats '(%s)-[%b]' '%c%u %m' '<!%a>'
    zstyle ':vcs_info:git:*' check-for-changes true
    zstyle ':vcs_info:git:*' stagedstr "+"
    zstyle ':vcs_info:git:*' unstagedstr "-"
fi
if is-at-least 4.3.11; then
    zstyle ':vcs_info:git+set-message:*' hooks \
                                            git-hook-begin \
                                            git-untracked \
                                            git-push-status \
                                            git-nomerge-branch \
                                            git-stash-count
    function +vi-git-hook-begin() {
        if [[ $(command git rev-parse --is-inside-work-tree 2> /dev/null) != 'true' ]]; then
            return 1
        fi
        return 0
    }
    function +vi-git-untracked() {
        if [[ "$1" != "1" ]]; then
            return 0
        fi
        if command git status --porcelain 2> /dev/null \
            | awk '{print $1}' \
            | command grep -F '??' > /dev/null 2>&1 ; then
            hook_com[unstaged]+='?'
        fi
    }
    function +vi-git-push-status() {
        if [[ "$1" != "1" ]]; then
            return 0
        fi
        if [[ "${hook_com[branch]}" != "master" ]]; then
            return 0
        fi
        local ahead
        ahead=$(command git rev-list origin/master..master 2>/dev/null \
            | wc -l \
            | tr -d ' ')
        if [[ "$ahead" -gt 0 ]]; then
            hook_com[misc]+="(p${ahead})"
        fi
    }
    function +vi-git-nomerge-branch() {
        if [[ "$1" != "1" ]]; then
            return 0
        fi
        if [[ "${hook_com[branch]}" == "master" ]]; then
            return 0
        fi
        local nomerged
        nomerged=$(command git rev-list master..${hook_com[branch]} 2>/dev/null | wc -l | tr -d ' ')
        if [[ "$nomerged" -gt 0 ]] ; then
            hook_com[misc]+="(m${nomerged})"
        fi
    }
    function +vi-git-stash-count() {
        if [[ "$1" != "1" ]]; then
            return 0
        fi
        local stash
        stash=$(command git stash list 2>/dev/null | wc -l | tr -d ' ')
        if [[ "${stash}" -gt 0 ]]; then
            hook_com[misc]+=":S${stash}"
        fi
    }
fi
function _update_vcs_info_msg() {
    local -a messages
    local prompt
    LANG=en_US.UTF-8 vcs_info
    if [[ -z ${vcs_info_msg_0_} ]]; then
        prompt=""
    else
        [[ -n "$vcs_info_msg_0_" ]] && messages+=( "%F{cyan}${vcs_info_msg_0_}%f" )
        [[ -n "$vcs_info_msg_1_" ]] && messages+=( "%F{yellow}${vcs_info_msg_1_}%f" )
        [[ -n "$vcs_info_msg_2_" ]] && messages+=( "%F{red}${vcs_info_msg_2_}%f" )
        prompt="${(j: :)messages}"
    fi
    echo $prompt
}
function _render_prompt() {
  exit_code='%?'
  PROMPT="(%(?!%{$fg[green]%}!%{$fg[red]%})$exit_code%{$reset_color%})`_update_vcs_info_msg`
%% "
  RPROMPT="( %{$fg[magenta]%}%~%{$reset_color%} )Oo."
}
precmd() { _render_prompt }
# }}}
# }}}
