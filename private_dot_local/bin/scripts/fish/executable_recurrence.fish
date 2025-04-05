#!/usr/bin/env fish

set parents (task +PARENT _uuids)  # Take the first argument as input

set -U children_to_delete ""
for parent in $parents
  set children (task rc.gc=0 status:pending parent:$parent due.before:today _uuids)
  if test (count $children) -gt 1
    set dues (task rc.gc=0 $children _unique due)
    if test (count $dues) -gt 1
      for due in $dues
        set -Ua children_to_delete (task rc.gc=0 parent:$parent "(due.before:today and due.after:$due)" _uuids)
      end
    end
  end
end

task rc.bulk=0 rc.confirmation=1 rc.recurrence.confirmation=no $children_to_delete delete
task rc.bulk=0 rc.confirmation=1 rc.recurrence.confirmation=no status:deleted +CHILD purge
task rc.bulk=0 rc.confirmation=1 rc.recurrence.confirmation=no status:deleted +PARENT purge

# deleted parents usually aren't useful either



