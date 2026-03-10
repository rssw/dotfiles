#!/usr/bin/env bash
set -euo pipefail

zgrep -hE '^(Start-Date:|Commandline:)' /var/log/apt/history.log* \
	| grep -vE 'aptdaemon|upgrade' \
	| grep '^Commandline:'
