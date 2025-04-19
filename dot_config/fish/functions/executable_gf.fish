function gf
  argparse -x l,r,g,d,R,D -x C,l,r,g,d,R,D 'h/help' 'l' 'c' 's' 'C' 'r' 'g' 'd' 'R' 'D' -- $argv
  if set -ql _flag_help
    echo "
gf - gtrash wrapper

General listing:
  gf -l             => list trash
  gf -l -c          => list trash from cwd 
  gf -l -s          => list trash + sort by size 

Cleanup:
  gf -C             => prune older than 30days 
  gf -C -s          => view and select larger items for deletion

Restoring:
  gf -r             => restore 
  gf -r -c          => restore trashed from cwd 
  gf -g             => restore in groups 

Permanent deletion:
  gf -d             => permanent delete
  gf -d -c          => permanent delete from cwd 

Trashing items:
  gf                => trash 
  gf -R             => trash recursively
  gf -D             => trash directory 
" 
    return 0
  end

  if set -ql _flag_l
    set cmd gtrash find -S
    if set -ql _flag_c
      set cmd $cmd --cwd
    end
    if set -ql _flag_s
      set cmd $cmd --sort size
    end
    if test -z "$argv"
      $cmd
    else
      $cmd $argv
    end
  else if set -ql _flag_C
   if set -ql _flag_s
      gtrash prune --day 30
    else
      gtrash find -S --size-large 500M | fzf --multi | awk -F'\t' '{print $3}' | xargs -o -r gtrash rm
    end
  else if set -ql _flag_r
    set cmd gtrash find -S
    if set -ql _flag_c
      set cmd $cmd --cwd
    end
    $cmd | fzf --multi | awk -F'\t' '{print $3}' | xargs -o -r gtrash restore
  else if set -ql _flag_g
    gtrash restore-group
  else if set -ql _flag_d
    set cmd gtrash find -S
    if set -ql _flag_c
      set cmd $cmd --cwd
    end
    $cmd | fzf --multi | awk -F'\t' '{print $3}' | xargs -o -r gtrash rm
  else
    if test -z "$argv"
      echo "Expected at least one argument"
    else
      set cmd gtrash put --rm-mode
      if set -ql _flag_R
        $cmd --recursive
      else if set -ql _flag_D
        $cmd --dir
      end
      $cmd $argv
    end
  end
end

