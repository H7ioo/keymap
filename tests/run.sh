#!/usr/bin/env bash
# Run every tests/*.sim through kanata's simulator and compare with tests/*.expected.
# Usage: SIM=/path/to/kanata_simulated_input tests/run.sh [--update]
set -euo pipefail

cd "$(dirname "$0")"
sim=${SIM:-kanata_simulated_input}
failed=0

for input in *.sim; do
  name=${input%.sim}
  # The simulator also prints bare "42" lines (internal markers); keep only timing and output events.
  actual=$("$sim" -c ../kanata.kbd -s "$input" 2>/dev/null | grep -v '^42$')
  if [[ ${1:-} == --update ]]; then
    printf '%s\n' "$actual" > "$name.expected"
  elif diff -u --label "$name.expected" --label "$name (actual)" "$name.expected" <(printf '%s\n' "$actual"); then
    echo "ok   $name"
  else
    echo "FAIL $name"
    failed=1
  fi
done

exit $failed
