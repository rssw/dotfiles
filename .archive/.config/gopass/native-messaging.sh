#!/bin/sh
export GPG_TTY="$(tty)"
exec /run/current-system/sw/bin/gopass-jsonapi listen
