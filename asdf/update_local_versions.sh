#!/bin/bash

vc_file="$HOME/.config/asdf/.tool-versions"
local_file="$HOME/.tool-versions"

cp "$vc_file" "$local_file"

# reload the asdf tool environment
asdf reshim
