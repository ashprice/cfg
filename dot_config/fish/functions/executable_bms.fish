function bms
  rm -f /tmp/rg-fzf-f /tmp/rg-fzf-r

  set -lx RG_F_TMP (mktemp -u /tmp/rg-fzf-f-XXXXXXXX)
  set -lx RG_R_TMP (mktemp -u /tmp/rg-fzf-r-XXXXXXXX)

  # Default search dir is .
  set SEARCH_DIR "/home/hearth/.nb/bookmarks/"
  set INITIAL_QUERY ""

  if test (count $argv) -gt 0
    set INITIAL_QUERY (string join ' ' $argv)
  end

  set -x SEARCH_DIR $SEARCH_DIR
  set -x INITIAL_QUERY $INITIAL_QUERY

  set -x RG_PREFIX "rg --line-number --no-heading --color=always --smart-case "
  # I couldn't get this to work with fish lol
  fzf --ansi --disabled --query "$INITIAL_QUERY" \
    --with-shell 'bash -c' \
    --bind "start:reload:$RG_PREFIX {q} \"$SEARCH_DIR\" || true" \
    --bind "change:reload:sleep 0.1; $RG_PREFIX {q} \"$SEARCH_DIR\" || true" \
    --bind 'ctrl-t:transform:[[ ! $FZF_PROMPT =~ ripgrep ]] &&
  echo "rebind(change)+change-prompt(1. ripgrep> )+disable-search+transform-query:echo \{q} > /tmp/rg-fzf-f; cat /tmp/rg-fzf-r" ||
  echo "unbind(change)+change-prompt(2. fzf> )+enable-search+transform-query:echo \{q} > /tmp/rg-fzf-r; cat /tmp/rg-fzf-f"' \
    --color "hl:-1:underline,hl+:-1:underline:reverse" \
    --prompt "1. ripgrep> " \
    --delimiter : \
    --preview 'bat --color=always {1} --highlight-line {2}' \
    --preview-window 'up,80%,border-line,+{2}+3/3,~3' \
    --bind 'enter:become(nb open {1})' \
    --bind 'ctrl-o:become(nb show {1} -r)'

end
