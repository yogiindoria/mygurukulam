#!/bin/bash

DB_DIR="$HOME/.processmanager"
DB_FILE="$DB_DIR/services.db"

mkdir -p "$DB_DIR"
touch "$DB_FILE"


register_service() {

    if [ -z "$SCRIPT" ] || [ -z "$ALIAS" ]; then
        echo "Usage: ./ProcessManager.sh -o register -s <script> -a <alias>"
        exit 1
    fi

    if [ ! -f "$SCRIPT" ]; then
        echo "Script does not exist"
        exit 1
    fi

    if grep -q "^$ALIAS|" "$DB_FILE"; then
        echo "Service already registered"
        exit 1
    fi

    echo "$ALIAS|$SCRIPT" >> "$DB_FILE"

    echo "Service registered successfully"
    echo "Alias : $ALIAS"
    echo "Script: $SCRIPT"
}


start_service() {

    if [ -z "$ALIAS" ]; then
        echo "Alias is required"
        exit 1
    fi

    SCRIPT=$(grep "^$ALIAS|" "$DB_FILE" | cut -d'|' -f2)

    if [ -z "$SCRIPT" ]; then
        echo "Service not registered"
        exit 1
    fi

    PID=$(pgrep -f "$SCRIPT" | head -1)

    if [ -n "$PID" ]; then
        echo "Service is already running"
        echo "PID: $PID"
        exit 0
    fi

    nohup "$SCRIPT" > /tmp/"$ALIAS".log 2>&1 &

    PID=$!

    echo "$PID" > "$DB_DIR/$ALIAS.pid"

    echo "Service started"
    echo "Alias: $ALIAS"
    echo "PID  : $PID"
}


status_service() {

    if [ -z "$ALIAS" ]; then
        echo "Alias is required"
        exit 1
    fi

    if [ ! -f "$DB_DIR/$ALIAS.pid" ]; then
        echo "Service is not running"
        exit 0
    fi

    PID=$(cat "$DB_DIR/$ALIAS.pid")

    if ps -p "$PID" > /dev/null; then
        echo "Service $ALIAS is RUNNING"
        echo "PID: $PID"
    else
        echo "Service $ALIAS is NOT RUNNING"
    fi
}


kill_service() {

    if [ -z "$ALIAS" ]; then
        echo "Alias is required"
        exit 1
    fi

    if [ ! -f "$DB_DIR/$ALIAS.pid" ]; then
        echo "Service is not running"
        exit 0
    fi

    PID=$(cat "$DB_DIR/$ALIAS.pid")

    if ps -p "$PID" > /dev/null; then
        kill "$PID"
        echo "Service $ALIAS stopped"
    else
        echo "Service is already stopped"
    fi

    rm -f "$DB_DIR/$ALIAS.pid"
}


priority_service() {

    if [ -z "$ALIAS" ] || [ -z "$PRIORITY" ]; then
        echo "Usage: ./ProcessManager.sh -o priority -p <low/med/high> -a <alias>"
        exit 1
    fi

    if [ ! -f "$DB_DIR/$ALIAS.pid" ]; then
        echo "Service is not running"
        exit 1
    fi

    PID=$(cat "$DB_DIR/$ALIAS.pid")

    case "$PRIORITY" in

        low)
            NICE=10
            ;;

        med)
            NICE=0
            ;;

        high)
            NICE=-10
            ;;

        *)
            echo "Priority must be low, med or high"
            exit 1
            ;;
    esac

    renice "$NICE" -p "$PID"

    echo "Priority changed"
}


list_services() {

    echo "Registered Services:"
    echo "--------------------"

    cut -d'|' -f1 "$DB_FILE"
}


top_services() {

    echo "Alias PID STATE PRIORITY SCRIPT"
    echo "--------------------------------"

    if [ -n "$ALIAS" ]; then

        if [ ! -f "$DB_DIR/$ALIAS.pid" ]; then
            echo "Service is not running"
            exit 1
        fi

        PID=$(cat "$DB_DIR/$ALIAS.pid")

        SCRIPT=$(grep "^$ALIAS|" "$DB_FILE" | cut -d'|' -f2)

        ps -p "$PID" -o pid=,stat=,ni=,args=

        echo "Alias : $ALIAS"
        echo "Script: $SCRIPT"

    else

        for PID_FILE in "$DB_DIR"/*.pid
        do

            [ -e "$PID_FILE" ] || continue

            ALIAS=$(basename "$PID_FILE" .pid)
            PID=$(cat "$PID_FILE")
            SCRIPT=$(grep "^$ALIAS|" "$DB_FILE" | cut -d'|' -f2)

            if ps -p "$PID" > /dev/null; then
                ps -p "$PID" -o pid=,stat=,ni=
                echo "Alias : $ALIAS"
                echo "Script: $SCRIPT"
                echo
            fi

        done

    fi
}


while getopts "o:s:a:p:" option
do

    case "$option" in

        o)
            OPERATION="$OPTARG"
            ;;

        s)
            SCRIPT="$OPTARG"
            ;;

        a)
            ALIAS="$OPTARG"
            ;;

        p)
            PRIORITY="$OPTARG"
            ;;

        *)
            echo "Invalid option"
            exit 1
            ;;

    esac

done


case "$OPERATION" in

    register)
        register_service
        ;;

    start)
        start_service
        ;;

    status)
        status_service
        ;;

    kill)
        kill_service
        ;;

    priority)
        priority_service
        ;;

    list)
        list_services
        ;;

    top)
        top_services
        ;;

    *)
        echo "Usage:"
        echo "./ProcessManager.sh -o register -s <script> -a <alias>"
        echo "./ProcessManager.sh -o start -a <alias>"
        echo "./ProcessManager.sh -o status -a <alias>"
        echo "./ProcessManager.sh -o kill -a <alias>"
        echo "./ProcessManager.sh -o priority -p <low/med/high> -a <alias>"
        echo "./ProcessManager.sh -o list"
        echo "./ProcessManager.sh -o top [-a <alias>]"
        ;;

esac