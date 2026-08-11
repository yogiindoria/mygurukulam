# Linux User and Team Manager - Assignment 2

> A Bash script for managing Linux users and teams using groups, permissions, and shared directories.

---

## Assignment Overview

The task was to create a utility called `userManager.sh` for managing users and teams on Linux.

The script supports:

- Creating and deleting teams
- Creating and deleting users
- Managing user passwords and shells
- Setting permissions on user home directories
- Creating shared `team` and `ninja` directories

### Permission Requirements

- Users should have full access to their own home directory.
- Users from the same team should be able to read and access each other's home directories.
- Other users should only have execute access to a user's home directory.
- Each user's home directory should contain:
  - `team` - shared directory for users of the same team
  - `ninja` - shared directory for users across all teams

---

## Project Structure

```text
.
├── userManager.sh
├── screenshots/
│   ├── 01-setup-addteam.png
│   ├── 02-adduser-permissions.png
│   ├── 03-ls-changepasswd-changeshell.png
│   ├── 04-changeshell-invalid-deluser.png
│   ├── 05-deluser-delteam-verify.png
│   └── 06-permissions-lsteam.png
└── README.md
```

---

## Setup

Give execute permission to the script:

```bash
chmod +x userManager.sh
```

Run the script using:

```bash
./userManager.sh <command> <arguments>
```

For example:

```bash
./userManager.sh addTeam amigo
```

The script also checks invalid commands and missing arguments.

```bash
./userManager.sh abc
./userManager.sh addTeam
```

![Add team](screenshots/01-setup-addteam.png)

---

## Team Commands

| Command | Description |
|---|---|
| `addTeam <TeamName>` | Creates a new Linux group as a team |
| `delTeam <TeamName>` | Deletes an existing team |
| `ls Team` | Lists the groups on the system |

### Examples

```bash
./userManager.sh addTeam amigo
./userManager.sh addTeam amigo
./userManager.sh delTeam amigo
./userManager.sh delTeam amigo
./userManager.sh ls Team
```

The script checks whether a team already exists before creating or deleting it.

---

## User Commands

| Command | Description |
|---|---|
| `addUser <UserName> <TeamName>` | Creates a user and adds the user to the given team |
| `delUser <UserName>` | Deletes a user and their home directory |
| `changePasswd <UserName>` | Changes the user's password |
| `changeShell <UserName> <bash\|zsh>` | Changes the user's login shell |
| `ls User` | Lists users on the system |

### Examples

```bash
./userManager.sh addUser Rakesh abc
./userManager.sh addUser Rakesh amigo
./userManager.sh addUser Rakesh amigo
```

When a user is created, the script:

1. Creates the user with the selected team as the primary group.
2. Adds the user to the `ninja` group.
3. Creates `team` and `ninja` directories inside the user's home directory.
4. Sets the required permissions.

![Add user and permissions](screenshots/02-adduser-permissions.png)

---

## Permissions

The script uses the following permissions:

| Path | Permissions | Purpose |
|---|---|---|
| `/home/<user>` | `751` | Owner has full access, team members have read/execute access, others have execute access |
| `/home/<user>/team` | `2770` | Shared directory for the user's team |
| `/home/<user>/ninja` | `2770` | Shared directory for users across teams |

The `setgid` permission on the shared directories helps keep the group ownership of new files consistent.

---

## Password and Shell Management

Change a user's password:

```bash
./userManager.sh changePasswd Rakesh
```

Change the user's shell:

```bash
./userManager.sh changeShell Rakesh bash
```

Check the user's entry:

```bash
grep "^Rakesh:" /etc/passwd
```

![Password and shell changes](screenshots/03-ls-changepasswd-changeshell.png)

The script also validates the requested shell:

```bash
./userManager.sh changeShell Rakesh zsh
./userManager.sh changeShell Rakesh fish
```

![Shell validation and user deletion](screenshots/04-changeshell-invalid-deluser.png)

---

## Delete User and Team

Delete a user:

```bash
./userManager.sh delUser Rakesh
```

Delete a team:

```bash
./userManager.sh delTeam amigo
```

The script checks whether the user or team exists before trying to delete it.

![Delete user and team](screenshots/05-deluser-delteam-verify.png)

---

## Check Permissions

The permissions can be checked using:

```bash
ls -ld /home/Rakesh/team
ls -ld /home/Rakesh/ninja
ls -ld /home/Rakesh
```

To list teams:

```bash
./userManager.sh ls Team
```

![Permission checks](screenshots/06-permissions-lsteam.png)

---

## Additional Features

Apart from the basic requirements, the script also includes:

- `changeShell` to change the user's shell between supported shells.
- `changePasswd` to change a user's password.
- `delUser` to remove a user and their home directory.
- `delTeam` to remove a team.
- `ls User` and `ls Team` to list users and groups.
- A global `ninja` group for sharing files between users from different teams.
- Validation for arguments and existing users/groups.
- Handling of invalid commands.

---

## Linux Commands Used

- `groupadd`
- `groupdel`
- `useradd`
- `userdel`
- `usermod`
- `passwd`
- `chsh`
- `chown`
- `chmod`
- `grep`
- `cut`
- `id`

---

## Concepts Practiced

- Bash scripting
- Command line arguments
- Case statements
- Linux users and groups
- File and directory permissions
- `chmod` and `chown`
- Setgid permissions
- User and group management
- Input validation
- Basic Linux administration

---

## Requirements

- Linux system
- Bash
- `sudo` or root privileges
- Tested on Ubuntu using WSL

---

## Author

** Yogesh Indoria **

