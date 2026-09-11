#!/usr/bin/env bash
# Safe lock test: locks the screen, but guarantees a way out.
#
# Polls noctalia's own `locked` status. If you unlock normally, the watchdog
# exits quietly. If you CANNOT unlock within the timeout, it kills noctalia -
# which destroys the lock surface - and restarts the shell. No TTY needed.
set -uo pipefail
TIMEOUT="${1:-60}"

locked() { noctalia msg status 2>/dev/null | grep -q '"locked": true'; }

(
  # wait for the lock to actually engage first
  for _ in $(seq 10); do locked && break; sleep 0.5; done
  for _ in $(seq "$TIMEOUT"); do
    sleep 1
    locked || { echo "[watchdog] unlocked normally - auth works"; exit 0; }
  done
  echo "[watchdog] still locked after ${TIMEOUT}s - releasing"
  pkill -x noctalia
  sleep 2
  setsid -f noctalia --daemon >/dev/null 2>&1
  echo "[watchdog] noctalia restarted; lock released"
) &

echo "Locking in 3s. Type your password normally."
echo "If it will not accept, wait ${TIMEOUT}s and the watchdog frees you."
sleep 3
noctalia msg session lock
wait
