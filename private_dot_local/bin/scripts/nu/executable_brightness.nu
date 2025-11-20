#!/usr/bin/env nu

def grab-monitor [] {
  ddcutil detect
  | lines
  | where $it =~ 'i2c'
  | split row '-'
  | last
  | str trim
}

def get-brightness [dev] {
  ddcutil --bus $dev getvcp 10
  | lines
  | str replace -r '.*current value =\s+(\d+).*' '$1'
  | first
  | into int
}

def set-brightness [dev new] {
  ddcutil --bus $dev setvcp 10 $new
}

def adjust-brightness [change:int] {
  let dev = (grab-monitor)
  let current = (get-brightness $dev)
  let new = ($current + $change)

  let new = (if $new < 0 { 0 } else if $new > 100 { 100 } else { $new })

  set-brightness $dev $new 
}

def main [delta:int] {
  adjust-brightness $delta
}

