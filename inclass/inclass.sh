#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
for workload in 1 2 3; do
    MQSim -i ssdconfig.xml -w "wl_inclass_${workload}.xml"
done
