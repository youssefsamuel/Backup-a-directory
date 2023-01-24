#!/bin/bash

if [ $# -lt 3 ] 
then
	echo "You should enter 3 arguments."
	echo "Argument 1: The directory you want to backup."
	echo "Argument 2: The destination directory."
	echo "Argument 3: The max number of backups to be reserved."
	exit
fi

echo "I run" >> abc.txt

original_dir=$1
backup_dir=$2
max_backups=$3

touch directory_info.last
touch directory_info.new
ls -lR $original_dir > directory_info.new

file=`cat directory_info.last`
if [ -z "$file" ]
then
	cp -r $original_dir "$backup_dir/"$(date +"%Y-%m-%d-%H-%M-%S")""
	cp directory_info.new directory_info.last
	exit
fi

is_identical=`cmp directory_info.last directory_info.new`

if [ "$is_identical" != "" ] 
then
	echo "Data Changed" >> abc.txt
	count=`ls $backup_dir | wc -l | head -n 1`
	echo $count >> abc.txt
	if (( $count >= $max_backups )) 
	then
		directory_to_remove=`ls $backup_dir | sort | head -1`
		rm -r $backup_dir/$directory_to_remove
	fi	
	echo "A new backup is created." >> abc.txt
	cp -r $original_dir "$backup_dir/"$(date +"%Y-%m-%d-%H-%M-%S")""
	cp directory_info.new directory_info.last
fi
