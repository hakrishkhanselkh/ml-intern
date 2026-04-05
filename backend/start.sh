#!/bin/bash
# Entrypoint for HF Spaces dev mode compatibility.
# Dev mode spawns multiple CMD instances simultaneously on restart.
# The old process may still hold port 7860 briefly, so we retry
# with backoff until the port is free.

MAX_RETRIES=5
RETRY_DELAY=2

for i in $(seq 1 $MAX_RETRIES); do
    uvicorn main:app --host 0.0.0.0 --port 7860
    EXIT_CODE=$?

    if [ $EXIT_CODE -eq 0 ]; then
        exit 0
    fi

    # Check if another instance from this restart batch is already running
    if ss -tlnp 2>/dev/null | grep -q ":7860 "; then
        echo "Port 7860 already bound by another instance, exiting."
        exit 0
    fi

    if [ $i -lt $MAX_RETRIES ]; then
        echo "uvicorn exited ($EXIT_CODE), retrying in ${RETRY_DELAY}s (attempt $i/$MAX_RETRIES)..."
        sleep $RETRY_DELAY
    fi
done

echo "Failed to bind port 7860 after $MAX_RETRIES attempts."
exit 1
