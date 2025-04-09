#!/usr/bin/env fish

fd -H -t d --changed-before 1week . /home/hearth/.cache/paru/ | sd '(^/([^/]+/){6}).*' '$1' | sort -u | xargs -I_ rmz _

fd -H -t f --exclude 'fish/' --exclude 'paru/' --changed-before 30days . /home/hearth/.cache/ -X rmz

while true
  set emptydirs ""
  set emptydirs (fd -H -t empty -t -d . /home/hearth/.cache)
  if test -n "$emptydirs"
    rmz $emptydirs
  else
    break
  end
end

