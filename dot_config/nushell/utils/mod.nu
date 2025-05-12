export module to

export def recurs [] {
  let parentids = (
    task +PARENT _uuids
    | lines
    | str join "', '"
    | str replace -r "^" "('"
    | str replace -r "$" "')"
  )
  let parents = (
    open ~/.task/taskchampion.sqlite3
    | query db $"select uuid, data from tasks where uuid in ($parentids)"
    | par-each {|i| { uuid: $i.uuid, data: ($i.data | from json ) }}
    | flatten
  )
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
    | par-each {|i| { uuid: $i.uuid, data: ($i.data | from json) }}
    | flatten
    | where status == "pending"
    | group-by parent
    | transpose
    | par-each {
      update column1 {
        $in
        | where (
          ($it.due | into int | $in * 1000000000) < ($today | into int)
        )
        | sort-by due
        | skip 1
      }
    }
    | get column1
    | flatten
    | get uuid
    | str join ' '   
  )
  task rc.confirmation=0 rc.recurrence.confirmation=0 rc.bulk=0 $children delete 
}

