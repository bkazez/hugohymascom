#!/bin/bash

# Function to kill background processes on exit
cleanup() {
    echo "Stopping all dev servers..."
    jobs -p | xargs -r kill
    exit
}

# Set up signal traps
trap cleanup SIGINT SIGTERM

echo "Starting all tenant dev servers..."

# Start each tenant in background
for tenant_dir in netlify/*/; do
    if [ -d "$tenant_dir" ]; then
        tenant_name=$(basename "$tenant_dir")
        echo "Starting $tenant_name..."
        (cd "$tenant_dir" && netlify dev) &
    fi
done

echo "All dev servers started. Press Ctrl+C to stop all."

# Wait for all background processes
wait