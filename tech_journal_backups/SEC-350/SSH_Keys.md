# SSH Keys

This page contains configurations/tips on working with the SSH Keys. **NOTE:** This page assumes that the users username is "olivermustoe", change accordingly.

**Table of contents**

1. [Generating basic SSH keys](#generating-basic-ssh-keys)

2. [Creating a passwordless user](#creating-a-passwordless-user)

3. [Transfering SSH keys](#transfering-ssh-keys)
   
   1. [Method 1: ssh-copy-id](#method-1-ssh-copy-id)
   
   2. [Method 2: sftp](#method-2-sftp)

4. [Sources](#sources)

# Generating basic SSH keys

The following commands can be used for passwordless SSH:

```bash
# Sets up basic RSA keys
ssh-keygen -t rsa -b 4096
```

Some other useful flags that can be used:

- `-f {KEYFILE}` = Manually specify a keyfile path, CAN USE RELATIVE PATHS (which you can't in the command)

- `-C {COMMENT}` = Specify a comment to use on the key

# Creating a passwordless user

It can be useful to create a user on a host that does not contain a password I.E it can only be accessed via SSH key authentication (or a sudo user switching to it.) The below command creates a fully functionting user without a password:

```bash
useradd -mk /etc/skel -s /bin/bash -d /home/{USERNAME} {USERNAME}
```

Some notes:

- Can add `-G wheel` or `-G sudo` between the `/home/{USERNAME}` and `{USERNAME}` to make the user a sudo/wheel user

# Transfering SSH keys

Below are 2 ways to exchange SSH keys between hosts. Both are done with the purpose of enabling SSH key authentication and the ability to do complete passwordless SSH.

#### Method 1: ssh-copy-id

The command below will deliver the key specified in the `-i` flag to the designated user on a host:

```bash
# Delivers keys to designated host
ssh-copy-id -i {PATH_TO_KEY} {USER}@{IP}
```

#### 

#### Method 2: sftp

The commands below will use a intermediate host to download the main hosts SSH keys and then forward them to the other hosts main directory. To make permissions easier, the other host will then `cat` redirect the file into its `~/.ssh/authorized_keys` file (this file indicates what hosts should be trusted by the system.)

```bash
# On intermediate host
## Download the SSH keys of the main host to the intermediate host
sftp {USER}@{IP_OF_MAIN_HOST}:{PATH_TO_SSH_PUB_KEY} {PATH}
## Send them to the other host
scp {PATH}/{SSH_PUB_KEY} {USER}@{IP_OF_OTHER_HOST}:

# On other host
## Copy the files to the directory of the user (if need be)
sudo cp {PATH}/{SSH_PUB_KEY} /home/{OTHER_USER}
## Change to the other user (if need be)
sudo su {OTHER_USER}
## Make the .ssh directory and cat redirect the contents of the pub file to the authorized keys file
mkdir .ssh && cat {PATH}/{SSH_PUB_KEY} >> .ssh/authorized_keys
```

Because this process can be kind of confusing, below is this same process executed from my MGMT01 system (intermediate host) to facilitate the SSH key process from RW01/10.0.17.25 (main host) and jump/172.16.50.4 (other host):

```bash
# On mgmt
mkdir temp_keys
sftp olivermustoe@10.0.17.25:/home/olivermustoe/keys/jump-oliver.pub temp_keys
scp ~/temp_keys/jump-oliver.pub olivermustoe@172.16.50.4:

# On jump (as olivermustoe)
sudo cp jump-oliver.pub /home/olivermustoe-jump/
sudo su olivermustoe-jump
mkdir .ssh && cat jump-oliver.pub >> .ssh/authorized_keys
```

# Sources

* https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Lab-2.2---Syslog-Organization-on-log01#ssh-keybased-authentication-setup

* https://github.com/Oliver-Mustoe/Oliver-Mustoe-Tech-Journal/wiki/Linux-Setup-Notes
