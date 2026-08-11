#!/bin/bash

# Assignment 2

case "$1" in
    addTeam)

		if [ $# -ne 2 ]; then
		echo "Usage: ./userManager.sh addTeam <TeamName>"
		exit 1
		fi

		if grep -q "^$2:" /etc/group; then 
		echo "Group already Exist"
		exit 1
		fi

		if sudo groupadd "$2"; then
		echo "Group '$2' Created Successfully."
		else
		echo "Failed to Create Group."
		fi

    ;;

    addUser)

		if grep -q "^ninja:" /etc/group; then
			:
		else 
			if sudo groupadd ninja; then
				:
			else
			echo "something went wrong"
				exit 1
			fi
		fi

		if [ $# -ne 3 ]; then
			echo "Usage: ./userManager.sh addUser <UserName> <GroupName>"
			exit 1
		fi

		if ! grep -q "^$3:" /etc/group ; then
			echo "Group '$3' Not Exist."
			exit 1
		fi

		if id "$2" > /dev/null 2>&1; then
			echo "User '$2' already exists."
			exit 1
		fi
		
		if sudo useradd -m -g "$3" "$2"; then
			echo "User '$2' created successfully."
		else
			echo "Failed to create user."
			exit 1
		fi

		if ! sudo usermod -aG ninja "$2"; then
			echo "Failed to add user to ninja group."
			exit 1
		fi

		sudo mkdir "/home/$2/team"
		sudo mkdir "/home/$2/ninja"

		sudo chown "$2:$3" "/home/$2/team"
		sudo chown "$2:ninja" "/home/$2/ninja"

		sudo chmod 751 "/home/$2"
		sudo chmod 2770 "/home/$2/team"
		sudo chmod 2770 "/home/$2/ninja"

		echo "Shared directories created successfully."
    ;;

    delUser)

	if [ $# -ne 2 ]; then 
		echo "Usage: ./userManager.sh delUser <UserName>"
		exit 1
	fi

	if id "$2" > /dev/null 2>&1; then
		sudo userdel -r "$2"
		echo "User deleted successfully"
		exit 0
	else 
		echo "User Does not Exist"
		exit 1
	fi
	;;

    delTeam)

	if [ $# -ne 2 ]; then 
		echo "Usage: ./userManager.sh delTeam <GroupName>"
		exit 1
	fi

	if grep -q "^$2:" /etc/group; then 
		if sudo groupdel  "$2"; then
			echo "Group '$2' Deleted"
		else 
			echo "Failed to delete group"
			exit 1
		fi
	else 
		echo "Group does not Exist"
		exit 1
	fi
	;;

   changePasswd)

	if [ $# -ne 2 ]; then 
		echo "Usage: ./userManager.sh changePasswd <UserName>"
		exit 1
	fi

	if id "$2" > /dev/null 2>&1; then
		sudo passwd "$2"
		exit 0
	else
		echo "User not Exist"
		exit 1
	fi

   ;;

   changeShell)

	if [ $# -ne 3 ]; then
		echo "Usage: ./userManager.sh changeShell <UserName> <Shell>"
		exit 1
	fi

	if id "$2" > /dev/null 2>&1; then
		if [ "$3" = "bash" ]; then
			sudo chsh -s /bin/bash "$2"
		elif [ "$3" = "zsh" ]; then
			sudo chsh -s /bin/zsh "$2"
		else
			echo "Invalid Shell"
		fi
	else 
		echo "User does not exist"
		exit 1
	fi
   ;;


   ls)

	if [ $# -ne 2 ]; then 
		echo  "Usage: ./userManager.sh ls <User> or <Team>"
		exit 1
	fi

	if [ "$2" = "User" ]; then
		cut -d: -f1 /etc/passwd
	elif [ "$2" = "Team" ]; then
		cut  -d: -f1 /etc/group
	else
		echo "invalid input"
		exit 1
	fi
   ;;

  	*)
 	echo "Invalid Command"
	;;
esac

