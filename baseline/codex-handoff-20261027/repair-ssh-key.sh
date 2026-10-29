#!/bin/sh
set -eu
B=/mnt/changxing60-disk/.changxing60/codex-backup-20261028
awk '{print NR, length($0), $1, $NF}' /etc/dropbear/authorized_keys
if [ -f "$B/authorized_keys.before" ]; then
 cat "$B/authorized_keys.before" > /etc/dropbear/authorized_keys
else
 : > /etc/dropbear/authorized_keys
fi
printf '\n' >> /etc/dropbear/authorized_keys
cat /etc/dropbear/codex-7552n.pub >> /etc/dropbear/authorized_keys
chmod 600 /etc/dropbear/authorized_keys
sync
awk '{print NR, length($0), $1, $NF}' /etc/dropbear/authorized_keys
