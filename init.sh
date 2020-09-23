#!/usr/bin/with-contenv /bin/bash

if [[ -z "$CARD" || -z "$PIPE"  || -z "$CONTROL" ]]; then
    echo 'ERROR: CARD PIPE and CONTROL environment variables must be set'
    exit 1
fi

# Setup cpiped
CARD_ID=$(aplay -l | grep "\[${CARD}\]" | grep -Po '^card [0-9]+' | cut -d' ' -f2 | uniq)
if [ -z "$CARD_ID" ]; then
    echo "ERROR: Unable to find $CARD"
    echo "Available cards:"
    aplay -l | grep '^card' | cut -d',' -f 1 | grep -Po "(?<=\[).*?(?=\])" | sort | uniq
else
    HW_ADDRESS="hw:${CARD_ID}"
    echo "HW_ADDRESS='$HW_ADDRESS'" > /root/dynamic.env
    rm /etc/services.d/cpiped/down
fi

# Setup alsa-grpc-server
touch alsa-grpc-server.version
existing=$(cat alsa-grpc-server.version)
latest=$(curl -s https://api.github.com/repos/mdubb86/alsa-grpc/releases/latest | jq -r '.name')
if [ "$existing" != "$latest" ]; then
    wget --quiet -O '/alsa-grpc-server' "https://github.com/mdubb86/alsa-grpc/releases/download/v${latest}/alsa_grpc_server_${latest}_amd64"
    if [ $? -eq 0 ]; then
        chmod +x /alsa-grpc-server
        echo $latest > alsa-grpc-server.version
        rm /etc/services.d/alsa-grpc-server/down
        echo "Downloaded alsa-grpc-server v$latest"
    else
        echo "Failed to download alsa-grpc-server v$latest"
    fi
fi
