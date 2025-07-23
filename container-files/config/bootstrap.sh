#!/usr/bin/env bash

set -euo pipefail

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >&2
}

# Supervisord default params
SUPERVISOR_PARAMS='-c /etc/supervisord.conf'

log "Starting supervisor bootstrap process"

# Create directories for supervisor's UNIX socket and logs
mkdir -p /data/conf /data/run /data/logs
chmod 755 /data/conf /data/run /data/logs

log "Created supervisor directories"

# Run initialization scripts if they exist
if [ -d "/config/init" ] && [ "$(ls -A /config/init/*.sh 2>/dev/null)" ]; then
  log "Running initialization scripts"
  for init in /config/init/*.sh; do
    if [ -r "$init" ]; then
      log "Running init script: $init"
      # shellcheck source=/dev/null
      source "$init"
    fi
  done
  log "Initialization scripts completed"
fi

# We have TTY, so probably an interactive container...
if [ -t 0 ]; then
  log "Interactive mode detected"
  # Run supervisord detached...
  supervisord $SUPERVISOR_PARAMS
  log "Supervisord started in background"

  # Some command(s) has been passed to container? Execute them and exit.
  # No commands provided? Run bash.
  if [ $# -gt 0 ]; then
    log "Executing command: $*"
    exec "$@"
  else
    log "Starting interactive shell"
    export PS1='[\u@\h : \w]\$ '
    exec /bin/bash
  fi

# Detached mode? Run supervisord in foreground, which will stay until container is stopped.
else
  log "Daemon mode detected"
  # If some extra params were passed, execute them before supervisord starts.
  if [ $# -gt 0 ]; then
    log "Executing pre-supervisord command: $*"
    "$@"
  fi
  log "Starting supervisord in foreground"
  exec supervisord -n $SUPERVISOR_PARAMS
fi