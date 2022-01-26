#!/bin/bash

set -euo pipefail
source $(dirname $0)/var.sh

git submodule foreach 'git clean -dffx; git reset --hard'
