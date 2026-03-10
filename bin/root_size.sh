#!/usr/bin/env bash
set -euo pipefail

sudo find / -maxdepth 1 \
	! -iregex '/\(\(srv\)\|\(var\)\|\(opt\)\|\(home\)\|\(boot\)\|\(sys\)\|\(run\)\|\(dev\)\|\(usr\)\|\(proc\)\|\(nfs\)\)?' \
	-print0 \
| xargs -0 sh -c 'for path do find "$path" -mindepth 1 -maxdepth 1 -exec du -d1 -h -x "{}" \; ; done' _ \
| sort -h
