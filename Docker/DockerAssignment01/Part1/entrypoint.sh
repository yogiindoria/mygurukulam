#!/bin/sh

update_config() {

    HOUR=$(date +%H)

    if [ "$HOUR" -ge 10 ] && [ "$HOUR" -lt 12 ]; then

        PERIOD="10 AM - 12 PM"
        MESSAGE="Hello from Yogesh"
        DESCRIPTION="Yogesh is currently active"

    elif [ "$HOUR" -ge 16 ] && [ "$HOUR" -lt 18 ]; then

        PERIOD="4 PM - 6 PM"
        MESSAGE="Hello from Shubham Rathi"
        DESCRIPTION="Shubham Rathi is currently active"

    else

        PERIOD="Outside Working Hours"
        MESSAGE="Website is currently unavailable"
        DESCRIPTION="Available only from 10 AM - 12 PM and 4 PM - 6 PM"

    fi

    cat > /usr/share/nginx/html/config.js <<EOF
const SITE_CONFIG = {
    period: "$PERIOD",
    message: "$MESSAGE",
    description: "$DESCRIPTION"
};
EOF
}

update_config

(
    while true
    do
        sleep 30
        update_config
    done
) &

nginx -g "daemon off;"