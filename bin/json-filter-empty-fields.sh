#!/usr/bin/env bash

# "Slurps" a stream of JSON objects and converts them to a JSON array. Filters out any empty fields (for example, property values)

jq -s '. | del(.[][] | select(. == [""]))'
