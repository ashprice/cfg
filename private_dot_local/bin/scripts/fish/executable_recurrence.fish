#!/usr/bin/env fish

# this is all quite slow. 
# in the absence of taskwarrior profiling data I don't really know how to speed it up 
# maybe working with the JSON in julia would be better

set parents (task +PARENT _uuids)  

set children_to_delete ""
for parent in $parents
  set children (task '(status:pending or status:waiting)' parent:$parent due.before:today _uuids)
  if test (count $children) -gt 1
    set dues (task $children _unique due)
    if test (count $dues) -gt 1
      set due (printf "%s\n" | sort -n | head -n 1)
      set children_to_delete (task '(status:pending or status:waiting)' parent:$parent "(due.before:today and due.after:$due)" _uuids)
      task rc.bulk=0 rc.confirmation=0 rc.recurrence.confirmation=no $children_to_delete delete
      set -e due 
    end
  end
end

set recurs (task _unique recur)
for span in $recurs
  set 30spans (task calc "$span*30" | sd '[a-zA-Z](\d+)[a-zA-Z]' '$1')
  set until 0

  if test $30spans -lt 90
    set until 90
  else if test $30spans -gt 90
    set until (task calc "$span*3" | sd '[a-zA-Z](\d+)[a-zA-Z]' '$1') 
  end

  task rc.bulk=0 rc.confirmation=0 rc.recurrence.confirmation=0 '(status:recurring or status:pending or status:waiting)' recur:$span mod until:today+{$until}d
  set -e until
end
     

#task rc.bulk=0 rc.confirmation=0 rc.recurrence.confirmation=no status:deleted +CHILD purge
#task rc.bulk=0 rc.confirmation=0 rc.recurrence.confirmation=no status:deleted +PARENT purge


