#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
exec MQSim -i ssdconfig.xml -w wl_inclass.xml
