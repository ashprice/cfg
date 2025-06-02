export module to

export def twdensity [] {
  let today = (
    dt now
    | dt format %F
    | into datetime
  )
  
  let tasks = (
    open ~/.task/taskchampion.sqlite3
    | query db $"select uuid, data from tasks"
    | par-each {|i|
      let data = $i.data | from json
      {
        uuid: $i.uuid,
        due: $data.due?,
        wait: $data.wait?,
        status: $data.status,
        density: $data.density?,
        depends: $data.depends?
      }
    }
    | where ($it.status == "pending" or ($it.status == "completed" and $it.density != null) or ($it.status == "deleted" and $it.density != null))
  )

  let clear_density = (
    $tasks
    | where ($it.status == "completed" or $it.status == "deleted")
    | get uuid
    | str join ' '
  )

  if ($clear_density | is-not-empty) {
    task rc.bulk=0 rc.recurrence.confirmation=0 rc.confirmation=0 $clear_density mod density:""
  }

  let tasks = (
    $tasks
    | where (($it.status != "completed") and ($it.status != "deleted"))
    | par-each {
      $in
      | upsert due {|i|
        if ($i.due != null) {
          ($i.due | into int) * 1_000_000_000 | into datetime
        }
      }
      | upsert wait {|i|
        if ($i.wait != null) {
          ($i.wait | into int) * 1_000_000_000 | into datetime
        }
      }
    }
  )

  def recurse-dues [tasks: list<any>] {
    let updated = (
      $tasks
      | par-each {
        if ($in.due == null and $in.depends != null) {
          update due (
            $in.depends
            | split row ','
            | par-each {|i| $tasks | where uuid == $i | get due?.0?}
            | sort -r
            | match ($in | describe) { "list<int>" => { $in | first } }
          )
          | update depends (
            $in.depends
            | split row ','
            | par-each {|i| $tasks | where uuid == $i | get depends?.0?}
            | str join ','
          )
        } else {
          $in | update depends (null)
        }
      }
      | sort-by uuid
    )

    if ($tasks == $updated) {
      $updated
    } else {
      recurse-dues $updated
    }
  }

  let tasks = recurse-dues $tasks

  let tasks = (
    $tasks
    | where due != null
    | select uuid density due
    | par-each {
      update due (
        $in.due
        | dt format %F
        | into datetime
      )
    }
  )

  let prior = (
    $tasks
    | where due != null
    | where due <= ($today + 14day)
  )

  let prior_count = (
    $prior
    | length
  )

  let prior_ids = (
    $prior
    | where (($it.due <= $today) and (($it.density | into int) != $prior_count))
    | get uuid
    | str join ' '
  )

  if (($prior_count | is-not-empty) and ($prior_ids | is-not-empty)) {
    task rc.confirmation=0 rc.recurrence.confirmation=0 rc.bulk=0 $prior_ids mod density:($prior_count)
  }

  let current = (
    $tasks
    | par-each {|i|
      $i
      | upsert count (
        $tasks
        | where (($it.due >= ($i.due - 14day)) and ($it.due <= ($i.due + 14day)) and ($i.due > $today))
        | length
      )
      | if ($in.density != null) {
        update density (
          $in.density
          | into int
        )
      } else {
        $in
      }
    }
    | where (($it.due > ($today)) and ($it.density != $it.count))
  )

  if ($current | is-not-empty) {
    $current
    | group-by count
    | values
    | each {
      task rc.recurrence.confirmation=0 rc.bulk=0 rc.confirmation=0 ($in | get uuid | str join ' ') mod density:($in.count | get 0) | print
    }
  }

  let densities = (
    task _unique density
    | lines
  )

  let count = (
    $densities
    | length
  )

  let densities = (
    $densities
    | into int
    | sort
    | enumerate
    | each { $"urgency.uda.density.($in.item).coefficient=(5 * ($in.index) / ($count) | math round -p 3)" }
  )

  let taskrc = (open -r ~/.task/.taskrc)

  $taskrc
  | lines
  | find --invert --regex '^urgency.uda.density.\d+.coefficient=\d+.*\d*$'
  | append $densities
  | to text
  | save -f ~/.task/.taskrc
}

export def recurs [] {
  let parentids = (
    task +PARENT _uuids
    | lines
    | str join "', '"
    | str replace -r "^" "('"
    | str replace -r "$" "')"
  )
  # let parents = (
  #   open ~/.task/taskchampion.sqlite3
  #   | query db $"select uuid, data from tasks where uuid in ($parentids)"
  #   | par-each {|i| { uuid: $i.uuid, data: ($i.data | from json ) }}
  #   | flatten
  # )
  let today = (
    task calc (
      dt now
      | dt format %F
      | into datetime
      | into int
    )
  )
  let children = (
    open ~/.task/taskchampion.sqlite3
    | query db $"select uuid, data from tasks where json_extract\(data, '$.parent') in ($parentids)"
    | par-each {|i|
      let data = $i.data | from json
      {
        uuid: $i.uuid,
        parent: $data.parent,
        due: $data.due,
        status: $data.status
      }
    }
    | where status == "pending"
    | group-by parent
    | values
    | par-each {|i|
      $i
      | where ($it.due | into int | $in * 1000000000) < ($today | into int)
      | sort-by due
      | skip 1
      | get uuid 
    }
    | flatten
    | str join ' '
  )  

  if ($children != '' and $children != null) {
    task rc.confirmation=0 rc.recurrence.confirmation=0 rc.bulk=0 $children delete
  }
}

