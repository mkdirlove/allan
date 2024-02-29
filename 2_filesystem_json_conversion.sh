#!/bin/bash

# Directory paths
json_dir="/lopt/filesystem"             # Directory where JSON files are located
normal_dir="/opt/filesystem/normal"     # Directory to store normal text files
critical_dir="/opt/filesystem/critical" # Directory to store critical CSV files
archive_dir="/opt/json_archives"        # Directory to store archived JSON files

# Clearing directories before execution
rm -f "$normal_dir"/* "$critical_dir"/*

# Find the latest JSON file matching the pattern
latest_json_file=$(ls -1t "$json_dir"/filesystem_*%Y%m%d_%H%M%S.json | head -n 1)

# Check if JSON file exists
if [ -f "$latest_json_file" ]; then
    # Extracting filename components
    json_filename=$(basename "$latest_json_file")
    filesystem_no=$(echo "$json_filename" | awk -F '_' '{print $2}')

    # Read disk usage percentage from JSON file
    disk_used_percent=$(jq -r '.[0].use_percentage' "$latest_json_file")

    # Check if disk usage percentage is less than 85%
    if (( $(echo "$disk_used_percent < 85" | bc -l) )); then
        # Create text file for normal disk usage
        normal_text_file="$normal_dir/filesystem_${filesystem_no}_normal.txt"
        
        # Create normal text file with required format
        cat > "$normal_text_file" <<EOF
filesystem_no: $filesystem_no
status: normal
disk_percentage: $disk_used_percent
directory: $json_dir
date: $(date -d "${json_filename#filesystem_*}" '+%Y%m%d')
time: $(date -d "${json_filename#*_}" '+%H%M%S')
EOF

        echo "Normal text file created: $normal_text_file"
    else
        # Create CSV file for critical disk usage
        critical_csv_file="$critical_dir/filesystem_${filesystem_no}_critical.csv"

        # Extract relevant data from JSON file
        filesystem=$(jq -r '.[0].filesystem' "$latest_json_file")
        size=$(jq -r '.[0].size' "$latest_json_file")
        used=$(jq -r '.[0].used' "$latest_json_file")
        available=$(jq -r '.[0].available' "$latest_json_file")
        mounted_on=$(jq -r '.[0].mounted_on' "$latest_json_file")

        # Create critical CSV file with required format
        echo "filesystem_no,disk_usage_status,disk_percentage,filesystem,size,used,available,mounted_on" > "$critical_csv_file"
        echo "$filesystem_no,critical,$disk_used_percent,$filesystem,$size,$used,$available,$mounted_on" >> "$critical_csv_file"

        echo "Critical CSV file created: $critical_csv_file"
    fi

    # Archive processed JSON file
    mkdir -p "$archive_dir"
    mv "$latest_json_file" "$archive_dir/"
    echo "JSON file archived: $archive_dir/$json_filename"
else
    echo "No JSON file found matching the pattern."
fi
