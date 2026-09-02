#!/bin/bash
# Usage: ./test-esp32.sh [run|config|compile] [path/to/config.yaml]

ACTION=${1:-run}
YAML=${2:-examples/esp32/pip8048/esp32-pip8048-example-faker.yaml}

DIR=$(dirname "$YAML")
RELATIVE_ROOT=$(realpath --relative-to="$DIR" .)

esphome -s external_components_source "$RELATIVE_ROOT/components" "$ACTION" "$YAML"
