#!/bin/bash

# Set the API token and chat ID
API_TOKEN="<your_api_token>"
CHAT_ID="<your_chat_id>"

# Set the message text
MESSAGE="This is a test message"

# Use the curl command to send the message
curl -s -X POST https://api.telegram.org/bot$API_TOKEN/sendMessage -d chat_id=$CHAT_ID -d text="$MESSAGE"