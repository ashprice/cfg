#!/usr/bin/env fish

set parents (task +PARENT _uuids)  # Take the first argument as input

for parent in $parents
  pueue add -i "set -U children_of_(echo $parent | sd '-' '_') (task rc.gc=0 status:pending parent:$parent due.before:today _uuids)"
end
pueue wait && pueue clean

for children in (set -n | rg '^children_of_')
  if test -n "$$children" && test (count $$children) -gt 1
    pueue add -i "set -U dues_of_$children (task rc.gc=0 $$children _unique due)"
  end
end
pueue wait && pueue clean

set -U children_to_delete ""
for children in (set -n | rg '^children_of_')
  if test -n "$$children" && test (count $$children) -gt 1
    for dues in (set -n | rg '^dues_of_')
      if test -n "$$dues" && test (count $$dues) -gt 1
        for due in $$dues
          pueue add -i "set -Ua children_to_delete (task rc.gc=0 parent:(echo $children | sd 'children_of_' '' | sd '_' '-') due.before:today due.after:$due _uuids)"
        end
      end
    end
  end
end
pueue wait && pueue clean

task rc.bulk=0 rc.confirmation=0 rc.recurrence.confirmation=no $children_to_delete delete
task rc.bulk=0 rc.confirmation=0 rc.recurrence.confirmation=no status:deleted +CHILD purge
task rc.bulk=0 rc.confirmation=0 rc.recurrence.confirmation=no status:deleted +PARENT purge

# deleted parents usually aren't useful either



