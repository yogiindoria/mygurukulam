#!/bin/bash

DB_DIR="/home/yogesh/LinuxAssignment4/.otssh"
DB_FILE="$DB_DIR/server.db"

# Create database directory/file if not exists
mkdir -p "$DB_DIR"
touch "$DB_FILE"

show_help() {
cat <<EOF

Usage:

  otssh -a -n NAME -h HOST -u USER [-p PORT] [-i KEY]
      Add a new server

  otssh -U -n NAME [-h HOST] [-u USER] [-p PORT] [-i KEY]
      Update an existing server

  otssh ls
      List all server names

  otssh ls -d
      List server details

  otssh rm SERVER_NAME
      Delete a server

  otssh SERVER_NAME
      Connect to a server
EOF
}

add_server() {
    local name="" host="" user="" port="22" key=""

    OPTIND=1
    while getopts "n:h:u:p:i:" opt; do
        case "$opt" in
            n) name="$OPTARG" ;;
            h) host="$OPTARG" ;;
            u) user="$OPTARG" ;;
            p) port="$OPTARG" ;;
            i) key="$OPTARG" ;;
            *)
                echo "[ERROR]: Invalid option for add"
                exit 1
                ;;
        esac
    done

    if [[ -z "$name" || -z "$host" || -z "$user" ]]; then
        echo "[ERROR]: -n (name), -h (host) and -u (user) are required"
        exit 1
    fi

    if grep -q "^$name|" "$DB_FILE"; then
        echo "[ERROR]: Server '$name' already exists."
        exit 1
    fi

    echo "$name|$host|$user|$port|$key" >> "$DB_FILE"
    echo "Server '$name' added successfully"
}

update_server() {
    local name="" host="" user="" port="" key=""
    local old_data old_host old_user old_port old_key

    OPTIND=1
    while getopts "n:h:u:p:i:" opt; do
        case "$opt" in
            n) name="$OPTARG" ;;
            h) host="$OPTARG" ;;
            u) user="$OPTARG" ;;
            p) port="$OPTARG" ;;
            i) key="$OPTARG" ;;
            *)
                echo "[ERROR]: Invalid option for update"
                exit 1
                ;;
        esac
    done

    if [[ -z "$name" ]]; then
        echo "[ERROR]: Please provide server name."
        exit 1
    fi

    old_data=$(grep "^$name|" "$DB_FILE")

    if [[ -z "$old_data" ]]; then
        echo "[ERROR]: Server information is not available, please add server first"
        exit 1
    fi

    IFS='|' read -r _ old_host old_user old_port old_key <<< "$old_data"

    host="${host:-$old_host}"
    user="${user:-$old_user}"
    port="${port:-$old_port}"
    key="${key:-$old_key}"

    sed -i "/^$name|/d" "$DB_FILE"
    echo "$name|$host|$user|$port|$key" >> "$DB_FILE"

    echo "Server '$name' updated successfully"
}

list_server() {
    local detail=false

    [[ "$1" == "-d" ]] && detail=true

    if [[ ! -s "$DB_FILE" ]]; then
        echo "No servers found."
        return
    fi

    while IFS='|' read -r name host user port key; do
        [[ -z "$name" ]] && continue

        if [[ "$detail" == true ]]; then
            cmd="ssh"

            [[ -n "$key" ]] && cmd="$cmd -i $key"

            if [[ -n "$port" && "$port" != "22" ]]; then
                cmd="$cmd -p $port"
            fi

            cmd="$cmd $user@$host"

            echo "$name: $cmd"
        else
            echo "$name"
        fi
    done < "$DB_FILE"
}

delete_server() {
    local name="$1"

    if [[ -z "$name" ]]; then
        echo "[ERROR]: Please provide a server name."
        exit 1
    fi

    if ! grep -q "^$name|" "$DB_FILE"; then
        echo "[ERROR]: Server information is not available."
        exit 1
    fi

    sed -i "/^$name|/d" "$DB_FILE"

    echo "Server '$name' deleted successfully"
}

connect_server() {
    local name="$1"
    local line

    line=$(grep "^$name|" "$DB_FILE")

    if [[ -z "$line" ]]; then
        echo "[ERROR]: Server information is not available, please add server first"
        exit 1
    fi

    IFS='|' read -r _ host user port key <<< "$line"

    msg="Connecting to $name"

    if [[ -n "$port" && "$port" != "22" ]]; then
        msg="$msg on $port port"
    fi

    msg="$msg as $user"

    [[ -n "$key" ]] && msg="$msg via $key key"

    echo "$msg"

    ssh_cmd=(ssh)

    [[ -n "$key" ]] && ssh_cmd+=(-i "$key")

    if [[ -n "$port" && "$port" != "22" ]]; then
        ssh_cmd+=(-p "$port")
    fi

    ssh_cmd+=("$user@$host")

    exec "${ssh_cmd[@]}"
}

MODE="$1"
shift

case "$MODE" in
    -a)
        add_server "$@"
        ;;
    -U)
        update_server "$@"
        ;;
    ls)
        list_server "$@"
        ;;
    rm)
        delete_server "$1"
        ;;
    "")
        show_help
        ;;
    *)
        connect_server "$MODE"
        ;;
esac
