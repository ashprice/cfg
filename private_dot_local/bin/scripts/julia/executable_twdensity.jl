# based on https://github.com/00sapo/TWDensity
# I thought julia would improve the speed; it doesn't by much at all, most of the overhead is task itself
# still, I introduced a filter so it doesn't try to reimport unchanged tasks
# other changes:
# - it hardcodes the window to 14 days
# - it changes the configuration for uda density coefficients
# - all dues <= today are counted as one day for density calculations (instead of eg. ignoring them)
# - waiting, deleted, and completed tasks will have density reset to nothing
# possible improvements:
# - it's a bit hard to visualize for me but I think from a graphing perspective that setting density in the other direction
#   may be a vaiid approach that *might* yield better results. 
#   however, you'd likely not want a blocking coefficient. and maybe not even urgency inheritance. 

import Dates
import JSON
using Dates
using JSON

function get_tw()
  output = read(`task rc:/home/hearth/.task/.taskrc status:pending -WAITING export`)
  return output = JSON.parse(String(output))
end

function get_due_date(task, all)
  if haskey(task, "due")
    return DateTime(task["due"], dateformat"yyyymmddTHHMMSSZ")
  elseif haskey(task, "depends")
    deps = isa(task["depends"], AbstractString) ? split(task["depends"], ",") : task["depends"]
    tmp = [ get_due_date(t, all) for t in all if get(t, "uuid", "") in deps ]
    dues = filter(!isnothing, tmp)
    return isempty(dues) ? nothing : maximum(dues)
  else
    return nothing
  end
end

function get_density(output)
  due_dates = filter(!isnothing, [ get_due_date(task, output) for task in output ])
  today = now()
  if isempty(due_dates)
    return zeros(Float64, 1)
  end
  max_due = maximum(due_dates)
  diff_ms = max(Dates.value(max_due - today), 0)
  days = div(diff_ms, 86400000) + 1
  density = zeros(Float64, days)
  for due in due_dates
    if due <= today
      density[1] += 1
    else
      day_offset = div(Dates.value(due - today), 86400000)
      idx = day_offset + 1
      if idx <= length(density)
        density[idx] += 1
      end
    end
  end
  return density
end

function set_density(output, density)
  window = 14
  today = now()
  for task in output
    due = get_due_date(task, output)
    if due !== nothing
      offset = max(0, div(Dates.value(due - today), 86400000))
      start = max(1, offset - window + 1)
      end_ = min(length(density), offset + window + 1)
      density_sum = round(Int, sum(density[start:end_]))
      if get(task, "density", "") != string(density_sum)
        task["density"] = string(density_sum)
        println("Task ", get(task, "description", "no description"), " set to desnity of ", density_sum)
      end
    end
  end
end

function out_tw(changed_tasks)
  run(`task rc.confirmation=0 rc.bulk=0 rc.recurrence.confirmation=0 rc:/home/hearth/.task/.taskrc '(status:waiting or status:deleted or status:completed)' modify density:""`)
  buffer = IOBuffer()
  JSON.print(buffer, changed_tasks)
  seekstart(buffer)
  run(pipeline(`task rc.confirmation=0 rc.bulk=0 rc.recurrence.confirmation=0 rc:/home/hearth/.task/.taskrc import`, stdin=buffer))
end

function update_config_file(config_path::String, output)
  densities = [ parse(Int, task["density"]) for task in output if haskey(task, "density") ]
  unique_densities = sort(unique(densities))
  num_unique = length(unique_densities)

  println("Unique densities: ", unique_densities)

  new_lines = String[]
  for (i, d) in enumerate(unique_densities)
    coeff = num_unique == 1 ? 5.0 : (5.0 * (i - 1)) / (num_unique - 1)
    push!(new_lines, "urgency.uda.density.$(Int(d)).coefficient=$(round(coeff, digits=3))")
  end

  lines = readlines(config_path)
  filtered_lines = filter(line -> !occursin(r"^urgency\.uda\.density\.\d+\.coefficient=", line), lines)
  all_lines = vcat(filtered_lines, new_lines)
  open(config_path, "w") do io
    for line in all_lines
      println(io, line)
    end
  end

  println("Configuration updated with $(length(new_lines)) new lines.")
end

function equal_tasks(task1, task2)
  return JSON.json(task1) == JSON.json(task2)
end

function main()
  output = get_tw()
  original_output = deepcopy(output)
  density = get_density(output)
  set_density(output, density)
  changed_tasks = [
                   modified for (modified, original) in zip(output, original_output)
                   if !equal_tasks(modified, original)
                  ]
  if !isempty(changed_tasks)
    println("Importing ", length(changed_tasks), "changed task(s).")
    out_tw(changed_tasks)
  else
    println("No tasks changed")
  end
  update_config_file("/home/hearth/.task/.taskrc", output)
end

main()
