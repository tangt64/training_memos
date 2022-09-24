#!/bin/bash
cat << EOF
Hello, $USER; you are running this program on $(hostname -s).
Your home directory is $HOME
EOF
