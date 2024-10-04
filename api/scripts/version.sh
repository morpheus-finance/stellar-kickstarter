#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"

echo `grep 'version: ' $DIR/../spec/api_v2.yaml | sed -r 's/version: ([^+]*)$/\1/' | xargs`
