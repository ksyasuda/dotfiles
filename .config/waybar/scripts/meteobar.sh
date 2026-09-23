#!/usr/bin/env bash
meteobar --location 'Los Angeles' --units imperial --icons fontawesome --tooltip-format days --days 3 | \
  jq -c '
    .class |= (if type == "array" then .[0] else . end) |
    .tooltip |= (
      split("\n") |
      map(select(test("[╭╰╮]") | not)) |
      map(select(test("foreground=.#5c6370.>[─]") | not)) |
      map(
        gsub("<span foreground=.#61afef.>│</span> *"; "") |
        gsub(" *<span foreground=.#61afef.>│</span>"; "")
      ) |
      map(select(test("^[[:space:]]*$") | not)) |
      join("\n")
    )
  '
