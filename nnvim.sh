#!/bin/bash

if [[ "$1" == "--lazy" ]]; then
    export NVIM_APPNAME=nvim-lazy
    shift
fi

exec /usr/bin/nvim "$@"
