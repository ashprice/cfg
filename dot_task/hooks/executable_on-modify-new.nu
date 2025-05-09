#!/usr/bin/env -S nu -n --no-std-lib --stdin

def main [...args: string] {
  let tasks = from json -o
  let task = $tasks | get 1
  let old_task = $tasks | get 0

  let task_due = $task | get due?
  let old_due = $old_task | get due?

  let task_sched = $task | get scheduled?
  let old_sched = $old_task | get scheduled?

  let task_until = $task | get until?
  let old_until = $task | get until?

  if ($task_due == $old_due and $task_sched == $old_sched and $task_until == $old_until) {
    $task | to json -s -r
  } else if ($task | is-not-empty parent?) {
    let parent_uuid = $task | get parent
    let parent_raw = open ~/.task/taskchampion.sqlite3
      | query db $"select data from tasks where uuid = '($parent_uuid)'"
      | get 0.data
    let parent = $parent_raw | from json

    let parent_due = $parent | get due
    let offset = task rc.verbose=nothing rc:/home/hearth/.task/.taskrc calc $task_due - $parent_due e> /dev/null

    let parent_sched = $parent | get scheduled?
    let parent_until = $parent | get until?

    let task = (
      $task
      | if ($parent_sched != null) {
        update scheduled {|i|
          $i.scheduled | task rc.verbose=nothing rc:/home/hearth/.task/.taskrc calc $parent_sched + $offset e> /dev/null
        }
      } else { $in }
      | if ($parent_until != null) {
        update until {|i|
          $i.until | task rc.verbose=nothing rc:/home/hearth/.tsak/.taskrc calc $parent_until + $offset e> /dev/null
        }
      } else { $in }
    )

    $task | to json -s -r
  } else {
    $task | to json -s -r
  }
}
