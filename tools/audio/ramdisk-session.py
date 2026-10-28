#!/usr/bin/env python3
"""Run a bounded command/script on the bring-up ramdisk's root telnet shell."""
import argparse
import base64
import re
import shlex
import socket
import sys
import time
import uuid
from pathlib import Path


def run(command, host="192.168.77.1", timeout=45):
    tag = "CODEX_DONE_" + uuid.uuid4().hex
    output = bytearray()
    with socket.create_connection((host, 23), timeout=5) as conn:
        conn.settimeout(0.5)

        def receive():
            data = conn.recv(65536)
            if not data:
                raise ConnectionError("device closed telnet connection")
            # BusyBox negotiates echo and suppress-go-ahead at connection setup.
            for match in re.finditer(rb"\xff([\xfb-\xfe])(.)", data, re.S):
                verb, option = match.group(1)[0], match.group(2)
                reply = b"\xfe" if verb in (251, 252) else b"\xfc"
                conn.sendall(b"\xff" + reply + option)
            return re.sub(rb"\xff[\xfb-\xfe].", b"", data, flags=re.S)

        deadline = time.monotonic() + 8
        while time.monotonic() < deadline:
            try:
                data = receive()
                if b"# " in data:
                    break
            except socket.timeout:
                continue
        conn.sendall(b"stty -echo\r\n")
        time.sleep(0.1)
        payload = ("( " + command + "\n); _codex_rc=$?; printf '\\n" + tag +
                   ":%s\\n' \"$_codex_rc\"\n")
        conn.sendall(payload.replace("\n", "\r\n").encode())
        deadline = time.monotonic() + timeout
        pattern = re.compile(rb"(?:\r?\n)" + tag.encode() + rb":(\d+)\r?\n")
        while time.monotonic() < deadline:
            try:
                output.extend(receive())
            except socket.timeout:
                continue
            match = pattern.search(output)
            if match:
                body = output[:match.start()].decode("utf-8", "replace")
                body = re.sub(r"\x1b\[[0-9;?]*[A-Za-z]", "", body).replace("\r", "")
                return body, int(match.group(1))
        raise TimeoutError(f"no completion marker in {timeout}s; captured {len(output)} bytes")


def run_serial(command, port, timeout=45):
    import serial
    tag = "CODEX_DONE_" + uuid.uuid4().hex
    output = bytearray()
    with serial.Serial(port, 115200, timeout=0.25, write_timeout=5) as conn:
        conn.write(b"\r\n")
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            if b"# " in conn.read(4096):
                break
        conn.write(b"stty -echo\n")
        time.sleep(0.1)
        payload = ("( " + command + "\n); _codex_rc=$?; printf '\\n" + tag +
                   ":%s\\n' \"$_codex_rc\"\n")
        conn.write(payload.encode())
        deadline = time.monotonic() + timeout
        pattern = re.compile(rb"\n" + tag.encode() + rb":(\d+)\n")
        while time.monotonic() < deadline:
            output.extend(conn.read(65536))
            clean = bytes(output).replace(b"\r", b"")
            match = pattern.search(clean)
            if match:
                body = clean[:match.start()].decode("utf-8", "replace")
                body = re.sub(r"\x1b\[[0-9;?]*[A-Za-z]", "", body)
                return body, int(match.group(1))
        raise TimeoutError(f"no serial completion marker in {timeout}s; captured {len(output)} bytes")


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("command", nargs="?")
    ap.add_argument("--script", type=Path)
    ap.add_argument("--host", default="192.168.77.1")
    ap.add_argument("--serial", help="USB ACM console, e.g. COM5 (requires pyserial)")
    ap.add_argument("--timeout", type=float, default=45)
    ap.add_argument("--output", type=Path)
    args = ap.parse_args()
    if bool(args.command) == bool(args.script):
        ap.error("provide a command or --script")
    command = args.command
    if args.script:
        encoded = base64.b64encode(args.script.read_bytes().replace(b"\r\n", b"\n")).decode()
        # Keep each PTY input line below Linux's canonical input limit.
        chunks = [encoded[i:i + 1000] for i in range(0, len(encoded), 1000)]
        command = ": > /tmp/codex-session.b64\n"
        command += "\n".join("printf %s " + shlex.quote(chunk) + " >> /tmp/codex-session.b64" for chunk in chunks)
        command += "\nbase64 -d /tmp/codex-session.b64 > /tmp/codex-session.sh && sh /tmp/codex-session.sh"
    if args.serial:
        text, code = run_serial(command, args.serial, args.timeout)
    else:
        text, code = run(command, args.host, args.timeout)
    if args.output:
        args.output.write_text(text, encoding="utf-8", newline="\n")
    sys.stdout.buffer.write(text.encode("utf-8"))
    print(f"\n[remote exit={code}]")
    return code


if __name__ == "__main__":
    raise SystemExit(main())
