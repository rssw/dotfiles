#!/usr/bin/env bash
# usage:
#   sudo fail2ban_matches.sh            # scan last 24h
#   sudo fail2ban_matches.sh 48h        # scan last 48h
#   sudo fail2ban_matches.sh 7d         # scan last 7 days

set -euo pipefail

SINCE="${1:-24h}"

find_jail_block() {
	local jail="$1"
	local file

	file="$(grep -RIl "^\[$jail\]" /etc/fail2ban /data/fail2ban 2>/dev/null | head -n1 || true)"
	if [ -z "$file" ]; then
		return 1
	fi

	awk -v jail="[$jail]" '
		$0 == jail { in_block = 1; next }
		in_block && /^\[/ { in_block = 0 }
		in_block
	' "$file"
	echo "##FILE:$file" 1>&2
}

get_kv() {
	awk -v key="$1" '
		BEGIN { IGNORECASE = 1 }
		$0 ~ "^[[:space:]]*" key "[[:space:]]*=" {
			sub(/^[[:space:]]*[^=]+=[[:space:]]*/, "", $0)
			print $0
			exit
		}
	'
}

echo
sudo fail2ban-client status \
	| sed -n 's/.*Jail list: *//p' \
	| tr ',' '\n' \
	| sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
	| while read -r jail; do
		[ -z "$jail" ] && continue
		echo "===== $jail ====="

		block="$(find_jail_block "$jail" || true)" || {
			echo "(could not locate jail config on disk; skipping)"
			echo
			continue
		}
		jailfile="$(printf '%s\n' "$block" | grep -m1 '^##FILE:' | sed 's/^##FILE://')"
		block="$(printf '%s\n' "$block" | sed '/^##FILE:/d')"

		filter="$(printf '%s\n' "$block" | get_kv filter | awk '{print $1}')"
		[ -z "$filter" ] && filter="$(sudo fail2ban-client get "$jail" filter 2>/dev/null | awk 'NR==1{print $1}')"

		backend="$(printf '%s\n' "$block" | get_kv backend || true)"
		logpath="$(printf '%s\n' "$block" | get_kv logpath || true)"
		jm_cfg="$(printf '%s\n' "$block" | get_kv journalmatch || true)"
		jm_cli="$(sudo fail2ban-client get "$jail" journalmatch 2>/dev/null || true)"

		journalmatch="$(printf '%s\n%s\n' "$jm_cfg" "$jm_cli" \
			| sed -E 's/^[[:space:]]*Journal match:[[:space:]]*//I' \
			| sed 's/^[[:space:]]*//; s/[[:space:]]*$//' \
			| head -n1)"

		fconf=""
		for dir in /etc/fail2ban/filter.d /data/fail2ban/filter.d; do
			if [ -f "$dir/$filter.conf" ]; then
				fconf="$dir/$filter.conf"
				break
			fi
		done

		if [ -z "$fconf" ]; then
			echo "(filter file not found for filter='$filter' from $jailfile)"
			echo
			continue
		fi

		out="/tmp/f2b_${jail}.matched"
		: > "$out"
		if echo "$backend" | grep -qi systemd || [ -n "$journalmatch" ]; then
			sudo fail2ban-regex systemd-journal "$fconf" "" \
				-m "$journalmatch since=-$SINCE" --print-all-matched \
				> "$out" 2>/dev/null || true
		else
			# shellcheck disable=SC2086
			sudo fail2ban-regex $logpath "$fconf" "" \
				--print-all-matched \
				> "$out" 2>/dev/null || true
		fi

		echo "-- matches (first 200 lines) --"
		sed -n '1,200p' "$out"

		echo "-- top IPs --"
		grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}' "$out" \
			| sort | uniq -c | sort -nr | head || true

		echo
	done
