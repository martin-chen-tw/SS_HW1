#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
for i in 1 2 3; do
  MQSim -i ssdconfig.xml -w "workload_${i}.xml"
done
