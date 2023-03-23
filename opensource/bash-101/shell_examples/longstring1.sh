#!/bin/bash
case $1 in
	-h | --help )
		cat << 'EOF'
-h, --help: show this help
-q, --quiet: run without diagnostics
-v, --verbose: add extra diagnostics
EOF
	exit 0
	;;
esac
