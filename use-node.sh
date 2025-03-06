#!/bin/bash
set -e

if [ $# -ne 1 ]; then
  echo "Usage: use-node <version>"
  echo "Available versions:"
  . $NVM_DIR/nvm.sh && nvm ls
  exit 1
fi

. $NVM_DIR/nvm.sh && nvm use "$1"
