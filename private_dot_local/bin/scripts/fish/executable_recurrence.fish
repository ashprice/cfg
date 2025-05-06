#!/usr/bin/env fish

set parents (task +PARENT _uuids)  

set children_to_delete ""
for parent in $parents
  set children (task '(status:pending or status:waiting)' parent:$parent due.before:today _uuids)
  if test (count $children) -gt 1
    set dues (task $children _unique due)
    if test (count $dues) -gt 1
      set due (printf "%s\n" $dues | sort -n | head -n 1)
      set children_to_delete (task '(status:pending or status:waiting)' parent:$parent "(due <= today and due.after:$due)" _uuids)
      if test (count $children_to_delete) -gt 1
        task rc.bulk=0 rc.confirmation=0 rc.recurrence.confirmation=no $children_to_delete delete
      end
    end
  end
end

set recurs (task _unique recur)
for span in $recurs
  set 14spans (task calc "$span*14" | sd '[a-zA-Z](\d+)[a-zA-Z]' '$1')

  if test $14spans -lt 15
    set until ""
    task rc.bulk=0 rc.confirmation=0 rc.recurrence.confirmation=0 recur:$span mod until:""
  else if test $14spans -gt 15
    set until (task calc "$span*3" | sd '[a-zA-Z](\d+)[a-zA-Z]' '$1')
    task rc.bulk=0 rc.confirmation=0 rc.recurrence.confirmation=0 recur:$span mod until:today+{$until}d
  end
end

#task rc.bulk=0 rc.confirmation=0 rc.recurrence.confirmation=no status:deleted +CHILD purge
#task rc.bulk=0 rc.confirmation=0 rc.recurrence.confirmation=no status:deleted +PARENT purge


