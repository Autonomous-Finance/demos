#!/bin/bash

npm list apm-tool || npm install -g apm-tool

apm-tool download @autonomousfinance/ownable

cp apm_modules/@autonomousfinance/ownable/source.lua ./ownable.lua
rm -rf apm_modules


if [[ "$(uname)" == "Linux" ]]; then
    BIN_PATH="$HOME/.luarocks/bin"
else
    BIN_PATH="/opt/homebrew/bin"
fi

mkdir -p build

$BIN_PATH/amalg.lua -s counter.lua -o build/counter.lua ownable