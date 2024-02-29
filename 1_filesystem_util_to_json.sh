#!/bin/bash

# Step 1: Retrieve filesystem utilization information
df_output=$(df -k)

# Step 2: Convert information to JSON format
json_data=$(echo "$df_output" | awk 'NR>1 {print "{\"filesystem\":\""$1"\",\"size\":\""$2"\",\"used\":\""$3"\",\"available\":\""$4"\",\"use_percentage\":\""$5"\",\"mounted_on\":\""$6"\"},"}')

# Remove the trailing comma from the last entry
json_data="${json_data%,}"

# Step 3: Generate filename with current date and time
filename="/tmp/filesystem_$(date '+%Y%m%d_%H%M%S').json"

# Step 4: Save JSON data to file
echo "[$json_data]" > "$filename"

# Step 5: Transfer JSON file to ALMALINUX SERVER 2 via SFTP
sftp_username="your_username"
sftp_host="ALMALINUX_SERVER_2_IP"
sftp_dir="/path/to/destination/directory"
sftp_password="your_password"

# Transfer file using sftp
echo "put $filename $sftp_dir" | sftp "$sftp_username:$sftp_password@$sftp_host"

# Step 6: Optionally, convert received JSON file to CSV and TXT formats based on conditions
# Add your conversion logic here based on the received JSON file
