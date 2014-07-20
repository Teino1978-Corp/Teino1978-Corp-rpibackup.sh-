#!/bin/bash

#this script backs up files from various locations in a remote computer.
#using scp to SFTP the files from remote. 
#files are stored as they are to / in $backupdir (hierarchy preserved), either specify absolute path for backupdir, or use $rootdir as a container
#in future this script will be run as a cronjob
#have to provide password everytime, TODO setup keys (although this has nothing to do with the script)

#usage: files that are to be backed up from pi (mainly configs and server settings)

#get rootdir
function get_rootdir() { #the dir the script is in, every files is stored relative to this dir, else in /tmp/
	#get rootdir
	filepath=`readlink -f $0`;
	rootdir="${filepath%/*}";
	echo $rootdir;
}
rootdir=`get_rootdir`;
#echo $rootdir;

backupdir="$rootdir/backup"; #path relative to $rootdir

#device
dev_user="pi"; #username in remote machine
dev_host="xxx.xxx.xxx.xxx" #ip of remote machine
dev_port="xx" #default 22 for sftp

scplist=( #absolute paths of files to be that are to be backed up
#example
	"/home/pi/.bashrc" #file
	"/home/pi/.config" #dir
)

#clean before copy, if uncommented, the backupdir will be deleted everytime before backing up, and created during.
#rm -rf "$backupdir";

#copying the files to $backupdir
for index in ${!scplist[*]};
do
	dotpath="${scplist[$index]}";
	#echo $dotpath;
	dotfilename="${dotpath##*/}";
	dotlocation="${dotpath%/*}";
	if [ ! -d "$backupdir/$dotlocation/" ]; #preserve folder hierarchy, create folders as they exist in remote machine
	then
		echo "Creating $backupdir$dotlocation/";
		mkdir -p "$backupdir$dotlocation/";
	fi
	echo "Copying"
	echo "src=$src:$dotlocation/$dotfilename";
	echo "dst=$backupdir$dotlocation/";
	scp -r -4 -c blowfish -P "$dev_port" "$dev_user@$dev_host:$dotlocation/$dotfilename" "$backupdir$dotlocation/"; # -6 for ipv6
	echo;echo; #gap between entries
done;
