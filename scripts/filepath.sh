#!/bin/bash
set -euo pipefail

function filepath()
{
    local container_name
    local target_time
    local DATE
    local TIME
    container_name="$1"
    target_time="$2"
    DATE=`date "+%Y-%m-%d" --date "${target_time}"`
    TIME=`date "+%Y%m%dT%H%M" --date "${target_time}"`
    echo "${container_name}/${DATE}/${container_name}_${TIME}"
}
