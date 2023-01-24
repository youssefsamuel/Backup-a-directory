#!/usr/bin/bash

# This shell script backups a directory if any change occured 
# during specific time intervals.

# Checking that the 4 arguments needed are passed successfully.
if [ $# -lt 4 ] 
then
	echo "You should enter 4 arguments."
	echo "Argument 1: The directory you want to backup."
	echo "Argument 2: The destination directory."
	echo "Argument 3: The waiting time between checks."
	echo "Argument 4: The max number of backups to be reserved."
	exit
fi
# Storing the arguments in variables.
original_dir=$1
backup_dir=$2
waiting_time=$3
max_backups=$4

# Copying the directory information into a text file.
ls -lR $original_dir > directory_info.last

# Checking if the current number of backups is greater than the maximum.
count=`ls $backup_dir | wc -l` 
if (( $count >= $max_backups )) 
then
	num_removals=`expr $count - $max_backups + 1`
	for (( i=0;i<$num_removals;i++ ))
	do
		directory_to_remove=`ls $backup_dir | sort | head -1`
		rm -r $backup_dir/$directory_to_remove
	done

fi	

# Creating a new backup.
cp -r $original_dir "$backup_dir/"$(date +"%Y-%m-%d-%H-%M-%S")""

# Infinite loop
for (( ; ; ))
do
	sleep $waiting_time
	ls -lR $original_dir > directory_info.new
	
	#Checking whether the two files are identical
	is_identical=`cmp directory_info.last directory_info.new`

	if [ "$is_identical" != "" ] 
	then
		echo "Data changed, a new backup is created."
		count=`ls $backup_dir | wc -l`
		if (( $count == $max_backups )) 
		then
			directory_to_remove=`ls $backup_dir | sort | head -1`
			rm -r $backup_dir/$directory_to_remove
		fi	
		cp -r $original_dir "$backup_dir/"$(date +"%Y-%m-%d-%H-%M-%S")""
		cp directory_info.new directory_info.last
	else
		echo "No change in data."
	fi
done
