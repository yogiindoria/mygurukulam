#!/bin/bash

CONFIG_FILE="$HOME/.ssh/config"

# create file if not exist
mkdir -p "$HOME/.ssh"
touch "$CONFIG_FILE"

show_usage() {
    echo "Usage"
    echo "  Add     : otssh -a -n <name> -h <host> -u <user> [-p port] [-i identity_file]"
    echo "  List    : otssh ls [-d]        (-d = detail, shows the ssh command too)"
    echo "  Connect : otssh <name>   (or: otssh -c -n <name>)"
    echo "  Delete  : otssh rm <name>   (or: otssh rm -n <name>)"
    echo "  Update  : otssh -u -n <name> -h <host> -u <user> [-p port] [-i identity_file]"
    exit 1
}

ACTION=""
NAME=""
HOST=""
USER_NAME=""
IDENTITY_FILE=""
PORT=22
DETAIL="no"
FIRST_ARG="yes"

while [ $# -gt 0 ]
do
    case "$1" in

        -a)
            ACTION="add"
            ;;

        ls)
            ACTION="list"
            ;;

        -c)
            ACTION="connect"
            ;;

        rm)
            ACTION="delete"
            if [ -n "$2" ] && [[ "$2" != -* ]]; then
                NAME="$2"
                shift
            fi
            ;;

        -U)
            ACTION="update"
            ;;

        -u)
            if [ "$FIRST_ARG" = "yes" ]; then
                ACTION="update"
            else
                USER_NAME="$2"
                shift
            fi
            ;;

        -d)
            DETAIL="yes"
            ;;

        -n)
            NAME="$2"
            shift
            ;;

        -h)
            HOST="$2"
            shift
            ;;

        -p)
            PORT="$2"
            shift
            ;;

        -i)
            IDENTITY_FILE="$2"
            shift
            ;;

        *)
            if [[ "$1" != -* ]]; then
                ACTION="connect"
                NAME="$1"
            else
                show_usage
            fi
            ;;
    esac

    FIRST_ARG="no"
    shift
done

# FUNCTIONS-----------------------

# WRITE ENTRY (internal, shared by add & update) ###

write_entry() {
    {
        echo ""
        echo "Host $NAME"
        echo "    HostName $HOST"
        echo "    User $USER_NAME"
        echo "    Port $PORT"
        if [ -n "$IDENTITY_FILE" ]; then
            echo "    IdentityFile $IDENTITY_FILE"
        fi
    } >> "$CONFIG_FILE"
}


# ADD SERVER ######################

add_server() {

    if grep -q "^Host $NAME$" "$CONFIG_FILE"; then
        echo "Server '$NAME' already exists."
        exit 1
    fi

    write_entry

    echo "Server '$NAME' added successfully."
}


# LIST ###############################

list_servers() {

    if [ "$DETAIL" = "yes" ]; then

        awk '

        function print_entry() {
            if (host_name != "") {
                if (key != "")
                    printf "%s: ssh -i %s -p %s %s@%s\n", host_name, key, port, user, host
                else if (port == "22")
                    printf "%s: ssh %s@%s\n", host_name, user, host
                else
                    printf "%s: ssh -p %s %s@%s\n", host_name, port, user, host
            }
        }

        $1=="Host" {
            print_entry()
            host_name=$2
            host=""
            user=""
            port="22"
            key=""
        }

        $1=="HostName" {
            host=$2
        }

        $1=="User" {
            user=$2
        }

        $1=="Port" {
            port=$2
        }

        $1=="IdentityFile" {
            key=$2
        }

        END {
            print_entry()
        }

        ' "$CONFIG_FILE"

    else

        grep "^Host " "$CONFIG_FILE" | awk '{print $2}'

    fi
}


# CONNECT ############################

connect_server() {

    if ! grep -q "^Host $NAME$" "$CONFIG_FILE"; then
        echo "Server information is not available, please add server first"
        exit 1
    fi

    # ssh "$NAME"
   eval $(awk -v host="$NAME" '
    $1=="Host" && $2==host {found=1; next}
    $1=="Host" && found {exit}

    found {
        if($1=="HostName") print "HOST="$2
        if($1=="User") print "USER_NAME="$2
        if($1=="Port") print "PORT="$2
        if($1=="IdentityFile") print "IDENTITY_FILE="$2
    }
    ' "$CONFIG_FILE")

    echo "Connecting to $NAME on $PORT port as $USER_NAME via $IDENTITY_FILE key"
}


# REMOVE ENTRY (internal, no output) ###

remove_entry() {

    awk -v host="$NAME" '
    BEGIN {skip=0}

    /^Host / {
        if ($2==host)
            skip=1
        else
            skip=0
    }

    !skip
    ' "$CONFIG_FILE" > /tmp/ssh_config_tmp

    mv /tmp/ssh_config_tmp "$CONFIG_FILE"
}


# DELETE ##############################

delete_server() {

    if ! grep -q "^Host $NAME$" "$CONFIG_FILE"; then
        echo "Server not found."
        exit 1
    fi

    remove_entry
    echo "Server deleted successfully."
}


# UPDATE ################################

update_server() {

    # remove old entry if it exists (silent upsert, no error if missing)
    remove_entry

    write_entry

    echo "Server updated successfully."
}



# MAIN ACTIONS--------------------

case "$ACTION" in

    add)

        if [[ -z "$NAME" || -z "$HOST" || -z "$USER_NAME" ]]; then
            show_usage
        fi

        add_server
        ;;

    list)

        list_servers
        ;;

    connect)

        if [[ -z "$NAME" ]]; then
            show_usage
        fi

        connect_server
        ;;

    delete)

        if [[ -z "$NAME" ]]; then
            show_usage
        fi

        delete_server
        ;;

    update)

        if [[ -z "$NAME" || -z "$HOST" || -z "$USER_NAME" ]]; then
            show_usage
        fi

        update_server
        ;;

    *)

        show_usage
        ;;

esac