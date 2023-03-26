#!/bin/bash
# DONT RUN AS SUDO!
read -e -p "Please enter the name of the Windows User to retieve SSH keys from: " Username

keyname="$Username-jump-keys.pub"
sftp $Username@10.0.17.25:.ssh/$keyname /tmp
scp /tmp/$keyname olivermustoe@172.16.50.4:
# SSH authorized_keys already made, just have to append
ssh olivermustoe@172.16.50.4 "sudo su -c 'cat $keyname >> /home/olivermustoe-jump/.ssh/authorized_keys'"