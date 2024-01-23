#!/usr/bin/env python3
import os
import json
from uptime_kuma_api import UptimeKumaApi

# Define the path to your monitor JSON file
monitor_file_path = "monitors.json"

# Load the monitor data from the JSON file
with open(monitor_file_path, "r") as file:
    monitor_data = json.load(file)

# Set your Uptime Kuma API URL
api_url = os.environ.get("UPTIME_URL")

# Initialize the Uptime Kuma API client
api = UptimeKumaApi(api_url)

# Log in to Uptime Kuma using the provided credentials
api.login(os.environ.get("UPTIME_USERNAME"), os.environ.get("UPTIME_PASSWORD"))

# Create monitors from the JSON data
for monitor_info in monitor_data:
    try:
        # Add a monitor using the information from the JSON
        api.add_monitor(**monitor_info)
        print(f"Monitor '{monitor_info['name']}' added successfully.")
    except Exception as e:
        print(f"Failed to add monitor '{monitor_info['name']}': {str(e)}")

# Close the API session
api.logout()

