#!/bin/fish
set -e
function Error()
{
  echo "error occur at line $1"
}

trap 'error $LINENO' ERR
Eraaa
