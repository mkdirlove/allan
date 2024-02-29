#!/bin/bash

# SFTP Configuration
sftp_username="admin"
sftp_host="ALMALINUX_SERVER_2_IP"
sftp_dir="/lopt/filesystem"
ssh_key="/path/to/ssh/key"  # Update this with the path to your SSH private key

# Local JSON file directory
local_json_dir="/tmp"

# Find the latest JSON file matching the pattern
latest_json_file=$(ls -1t "$local_json_dir"/filesystem_*/*.json | head -n 1)

# Check if JSON file exists
if [ -f "$latest_json_file" ]; then
    # Extracting filename from the path
    json_filename=$(basename "$latest_json_file")
    
    # Create directory if it doesn't exist on ALMALINUX SERVER 2
    ssh -i "$ssh_key" "$sftp_username@$sftp_host" "mkdir -p $sftp_dir"

    # Transfer JSON file to ALMALINUX SERVER 2 via SFTP
    echo "Transferring $json_filename to $sftp_host..."
    scp -i "$ssh_key" "$latest_json_file" "$sftp_username@$sftp_host:$sftp_dir/"

    # Check if transfer was successful
    if [ $? -eq 0 ]; then
        echo "File transfer complete."

        # Remove the JSON file from ALMALINUX SERVER 1
        rm "$latest_json_file"
        echo "Deleted $latest_json_file from ALMALINUX SERVER 1."
    else
        echo "Error: Failed to transfer file."
    fi
else
    echo "No JSON file found matching the pattern."
fi
	
