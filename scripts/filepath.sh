#!/bin/bash
set -euo pipefail

function filepath()
{
    local container_name="$1"
    local target_time="$2"
    local DATE=`date "+%Y-%m-%d" --date "${target_time}"`
    local TIME=`date "+%Y%m%dT%H%M" --date "${target_time}"`
    echo "${container_name}/${DATE}/${container_name}_${TIME}"
}
