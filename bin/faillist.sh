#!/usr/bin/env bash
set -euo pipefail

jails=("$@")
if [ ${#jails[@]} -eq 0 ]; then
	jails=(sshd mailu-front_bad-auth)
fi

log_file="/var/log/fail2ban.log"

for jailname in "${jails[@]}"; do
	echo "=== BANNED IPs for '$jailname' ==="
	banned_line="$(fail2ban-client status "$jailname" | grep 'Banned IP')"
	banned_ips="$(echo "$banned_line" | cut -d: -f2- | tr ' ' '\n' | sort -u)"
	echo "$banned_ips"
	echo

	echo "=== IPs with at least one failure (not yet banned) for '$jailname' ==="
	maxretry="$(fail2ban-client get "$jailname" maxretry 2>/dev/null || true)"
	if [ -z "$maxretry" ]; then
		echo "(Could not determine maxretry)"
		maxretry=999
	fi

	grep "\[$jailname\] Found" "$log_file" | awk '{print $(NF-3)}' | \
		sort | uniq -c | sort -nr | while read -r count ip; do
			if ! grep -qx "$ip" <<EOF
$banned_ips
EOF
			then
				remaining=$((maxretry - count))
				if (( remaining > 0 )); then
					echo "$count failures from $ip (ban in $remaining more attempts)"
				else
					echo "$count failures from $ip (ban likely pending)"
				fi
			fi
		done

	echo
done
