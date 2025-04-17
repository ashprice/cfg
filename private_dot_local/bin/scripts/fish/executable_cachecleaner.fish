#!/usr/bin/env fish

fd -H -t d --changed-before 1week . /home/hearth/.cache/paru/ | sd '(^/([^/]+/){6}).*' '$1' | sort -u | xargs -I_ rmz _

fd -H -t f --exclude 'fish/' --exclude 'paru/' --changed-before 30days . /home/hearth/.cache/ -X rmz

