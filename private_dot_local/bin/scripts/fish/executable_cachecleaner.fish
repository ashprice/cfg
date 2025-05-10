#!/usr/bin/env fish

# nb: please don't use this, I was doing some testing and it returned `/` as a directory to delete

fd -H -t d --changed-before 1week . /home/hearth/.cache/paru/ | sd '(^/([^/]+/){6}).*' '$1' | sort -u | xargs -I_ rmz _

fd -H -t f --exclude 'fish/' --exclude 'paru/' --changed-before 30days . /home/hearth/.cache/ -X rmz

