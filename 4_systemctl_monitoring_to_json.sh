#!/bin/bash

# Output JSON file directory
json_dir="/tmp"

# Define the filename with current date and time
filename="$json_dir/services_$(date '+%Y%m%d_%H%M%S').json"

# Run systemctl command and filter specific states
running_services=$(systemctl --no-legend list-units --state=running)
exited_services=$(systemctl --no-legend list-units --state=exited)
failed_services=$(systemctl --no-legend list-units --state=failed)
dead_services=$(systemctl --no-legend list-units --state=dead)

# Convert systemctl output to JSON format
echo "{" > "$filename"

# Convert running services to JSON
echo '"services_state_running": [' >> "$filename"
echo "$running_services" | while read -r unit load active sub description; do
    echo '{"service": "'"$unit"'", "description": "'"$description"'", "status": "active"},' >> "$filename"
done
echo '],' >> "$filename"

# Convert exited services to JSON
echo '"services_state_exited": [' >> "$filename"
echo "$exited_services" | while read -r unit load active sub description; do
    echo '{"service": "'"$unit"'", "description": "'"$description"'", "status": "exited"},' >> "$filename"
done
echo '],' >> "$filename"

# Convert failed services to JSON
echo '"services_state_failed": [' >> "$filename"
echo "$failed_services" | while read -r unit load active sub description; do
    echo '{"service": "'"$unit"'", "description": "'"$description"'", "status": "failed"},' >> "$filename"
done
echo '],' >> "$filename"

# Convert dead services to JSON
echo '"services_state_dead": [' >> "$filename"
echo "$dead_services" | while read -r unit load active sub description; do
    echo '{"service": "'"$unit"'", "description": "'"$description"'", "status": "inactive"},' >> "$filename"
done
echo ']}' >> "$filename"

echo "JSON file created: $filename"
