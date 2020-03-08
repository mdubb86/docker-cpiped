#!/usr/bin/with-contenv /bin/bash
if [[ -z "$CARD" || -z "$DEVICE" || -z "$CONTROL" || -z "$PIPE" || -z "$LEVEL" ]] ; then
    echo 'ERROR: CARD DEVICE CONTROL PIPE and LEVEL environment variables must be set'
else
    SELECTED=$(aplay -l | awk -v card="$CARD" -v device="$DEVICE" '$1 == "card" {split($0,a,","); s=index(a[1],"["); e=index(a[1],"]"); c=substr(a[1],s+1,e-s-1); s=index(a[2],"["); e=index(a[2],"]"); d=substr(a[2],s+1,e-s-1); e=index(a[1],":"); x=substr(a[1],6,e-6); e=index(a[2],":"); y=substr(a[2],9,e-9); if(c==card && d==device) print x"\t"y"\n"}')
    if [ -z "$SELECTED" ]; then
        echo "ERROR: Unable to find $CARD:$DEVICE"
        echo "Available card/device:"
        aplay -l | awk -v card="$CARD" -v device="$DEVICE" '$1 == "card" {split($0,a,","); s=index(a[1],"["); e=index(a[1],"]"); c=substr(a[1],s+1,e-s-1); s=index(a[2],"["); e=index(a[2],"]"); d=substr(a[2],s+1,e-s-1); e=index(a[1],":"); x=substr(a[1],6,e-6); e=index(a[2],":"); y=substr(a[2],9,e-9);print x":"y" ("c":"d")"}'
    else
        CARD_ID=$(echo $SELECTED | awk '{print $1}')
        DEVICE_ID=$(echo $SELECTED | awk '{print $2}')
        HW_ADDRESS="hw:${CARD_ID},${DEVICE_ID}"
        CONTROL_ID=$(amixer --card $CARD_ID controls | awk  -v "control=$CONTROL" '{split($0,a,","); num=substr(a[1],7); name=substr(a[3],7, length(a[3]) - 7); if (control==name) {print num}}')
        if [ -z "$CONTROL_ID" ]; then
            echo "ERROR: Unable to find $CONTROL"
            echo "Available Controls:"
            amixer --card $CARD_ID controls | awk '{split($0,a,","); num=substr(a[1],7); name=substr(a[3],7, length(a[3]) - 7); print num". "name}' | sort -n
        else
            echo "HW_ADDRESS='$HW_ADDRESS'" > /root/dynamic.env
            rm /etc/services.d/cpiped/down
            amixer --card $CARD_ID cset numid=$CONTROL_ID $LEVEL%
            echo "Set $CONTROL on $CARD:$DEVICE to $LEVEL%"
        fi
    fi
fi


