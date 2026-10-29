from pathlib import Path
import subprocess, re

# Human authorized this exact recipient (sender of message 000005) and text.
# Claim once before submitting; do not retry automatically after an ambiguous result.
ssh = ['ssh', '-i', 'work/codex-7552n-key', '-o', 'BatchMode=yes',
       '-o', 'IdentitiesOnly=yes', '-o', 'UserKnownHostsFile=work/codex-known-hosts',
       'root@192.168.77.1']
cmd = '''to=$(sed -n 's/^from: *//p' /etc/changxing60/sms-pool/msg/000005 | head -1)
case "$to" in ''|*[!0-9+]*) echo invalid-recipient; exit 1;; esac
grep -q '测试618' /etc/changxing60/sms-pool/msg/000005 || exit 1
mkdir /run/codex-sms-618-sent || exit 1
/opt/changxing60/bin/changxing60-sms send "$to" '畅行60：短信发送测试618' > /run/codex-sms-618-sent/result 2>&1
rc=$?
cat /run/codex-sms-618-sent/result
echo sms_submit_rc=$rc
exit "$rc"
'''
r = subprocess.run(ssh + [cmd], capture_output=True, timeout=90)
output = (r.stdout + r.stderr).decode('utf8', errors='replace')
output = re.sub(r'(?<!\d)\+?\d{7,}(?!\d)', '[phone-redacted]', output)
(Path(__file__).resolve().parent / 'sms-outgoing-submit.txt').write_text(output, encoding='utf8')
print(output)
raise SystemExit(r.returncode)
