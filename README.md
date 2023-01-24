# Backup a Directory

This project helps the user to backup a specific directory of his choice by checking it every certain period of time.

## Project Directories and Files
1. backupd.sh: which is the bash script file
2. dir: it is the source directory that we need to backup, inside this directory you will find five text files (file1.txt --> file5.txt) and a subdirectory called "subdir" which contains three files: "fileA.txt", "fileB.txt", "fileC.txt".
3. backup_dir: it is the destination directory, it may not be present before that the program runs, but once it runs for the first time, it will be created. It contains all the backups that occured, but must be less than the maximum number of allowed backups.
4. makefile: it is used to run the bash script.
5. directory_info.last: this file will be created once the script executes for the first. It contains the information of the source directory when it was last checked.
6. directory_info.new: same as the last file, but it contains the current information of the source directory

## Running the code
To run this you need first to choose the directory that you want to backup. Then, place the makefile and  the bashscript file in the directory containing the one that you want to backup. Finally, go to the terminal and let it your current working directory. 

For example, if the directory is in the desktop.
```bash
$ cd /home/{username}/Desktop/
```
To get your username, you can run "whoami" command
```bash
$ whoami
```
Then, type "make" to begin the execution of the makefile. Inside the makefile, the bash script will be called and begin to run.
```bash
$ make
```
Please note that your script file must be executable.
```bash
$ chmod +x ./backupd.sh
```

## Expected Output
Once the user runs the code, a backup will be immediately created inside the backup directory. This backup is also a directory. The name of a backup is just the current date and time when this backup is created, taking the following format; 'YYYY-MM-DD-hh-mm-ss'. And after the selected period of time, if any change occurred in the source directory, a new backup will be created. Note that according to the maximum number of backups passed as argument to the script file, so new directory to be created causing the total number of backups to exceed the maximum, the oldest backup will be automatically removed and replaced by the new one.

## Explanation of the Code

### MakeFile

The first part of code in the makefile is simply an initialization of some variables that are needed. Those variables are the arguments that will be passed to the bash script.
```bash
original_directory=./dir
backup_directory=./backup_dir
interval_secs=5
max_backups=2
```
The MakeFile here consists of two main targets: 'check' and 'run'. These two targets must be executed sequentially, that's why 'all' is used, to begin with the check target, then the 'run' target which depend on 'check'.
The target 'check' is considered a pre-build step that must execute before running the script. It executes only one command that checks whether the backup_directory is already created or not, if not created, mkdir command will do this job.
The 'run' target simply runs the bash script file giving him the four arguments needed to run this program.
```bash
all:check run

check:
	mkdir -p $(backup_directory)

run:check
	./backupd.sh $(original_directory) $(backup_directory) $(interval_secs) $(max_backups)
```
### Bash Script File

First, a simple if statement is included to check whether the makefile had successfully transmitted the four arguments to the script, and these arguments are then stored in variables to be used later.
```bash
if [ $# -lt 4 ] 
then
	echo "You should enter 4 arguments."
	echo "Argument 1: The directory you want to backup."
	echo "Argument 2: The destination directory."
	echo "Argument 3: The waiting time between checks."
	echo "Argument 4: The max number of backups to be reserved."
	exit
fi

original_dir=$1
backup_dir=$2
waiting_time=$3
max_backups=$4
```
Then, the information of the source directory is stored in a file called 'directory_info.last' using ls -lR command for long listing format. This command give us the last time each directory or file inside that directory was modified. This will help when we need to check whether the directory has been changed after a period of time.
``` bash
ls -lR $original_dir > directory_info.last
```
Now, the first backup of our directory need to be stored. 
A check is done, suppose that the last time the program run, the makefile specified that the max number of backups is 5, and the backup directory contains now 5 backups. But, the next time, the makefile said that the maximum number of backups is 2, so 4 backups need to be removed, so we can add the new backup, and finally 2 backups will be present.
To do this, first we need to count the number of backup directories.
```bash
count=`ls $backup_dir | wc -l`
```
In the last command, piping is used, 'ls' get the backup directories and passes them to 'wc' which count the number of lines.
When the count value is greater than or equal to the maximum, as mentioned some backups need to be removed equals to the count - max + 1.
num_removals is computed using 'expr' expression command.
Then, we have a for loop, which continue to remove the backups by listing the directories, sorting them from oldest to newest and removing the oldest ones.
```bash
if (( $count >= $max_backups )) 
then
	num_removals=`expr $count - $max_backups + 1`
	for (( i=0;i<$num_removals;i++ ))
	do
		directory_to_remove=`ls $backup_dir | sort | head -1`
		rm -r $backup_dir/$directory_to_remove
	done

fi	
```
After handling the last case, the first backup is ready to be stored and named by the current time and date. So 'cp -r' command is used to recursively copy the original directory. 
```bash
cp -r $original_dir "$backup_dir/"$(date +"%Y-%m-%d-%H-%M-%S")""
```
Finally, the bash script begin executing an infinite loop. The goal of this loop is that every a specific time interval the source directory is checked, if any change occurs in it, a new backup is created in our backup directory, if not iterate again. 
To exit the program just type ctrl + C in terminal.

Let's pass through the content of that loop:
```bash
for (( ; ; ))
do
	sleep $waiting_time
	ls -lR $original_dir > directory_info.new
	
	#Checking whether the two files are identical
	is_identical=`cmp directory_info.last directory_info.new`

	if [ "$is_identical" != "" ] 
	then
		count=`ls $backup_dir | wc -l`
		if (( $count == $max_backups )) 
		then
			directory_to_remove=`ls $backup_dir | sort | head -1`
			rm -r $backup_dir/$directory_to_remove
		fi	
		cp -r $original_dir "$backup_dir/"$(date +"%Y-%m-%d-%H-%M-%S")""
		cp directory_info.new directory_info.last
	fi
done
```
1. sleep: allow the currently running process to sleep for a certain duration specified by the variable "$waiting_time". After, it wakes up the execution continues.
2. ls -lR: as mentioned before it displays a long listing format of the content of our source directory to know the last time it was modified.
3. At this moment the directory_info.last file contains the information of the directory before sleeping, and directory_info.new contains the current information of the directory. So the next step is to compare those two files. If they are different, backup is needed.
4. "cmp" command is used here and its output is stored in $is_identical variable. This command compare the two files byte by byte and it returns the location of the first mismatch. So if they are identical, its output is just empty "", which means no backup is needed and we just loop again.
5. When the two files are not identical, the number of backups is counted. If the number of backups equals to the maximum, the oldest backup is removed.
6. Then a backup is created by copying the source directory and storing a copy of it in the backup directory with name containing current date and time.
7. Finally the current information of the directory is copied to the file called "directory_info.last" to be ready for the next iteration.
8. The infinite loop will continue, until the user press Ctrl+c from the terminal to stop the program.

# Bonus Part (Cron Job)
## Configuration
To set the cron job to run in your system follow the following steps:

In the directory "lab2bonus" you will find a makefile. At the beginning of this file you will see five declarations.
To run the cron job on your system, just change the path assigned to the variable "working_dir" to the path of your own directory which contains the makefile, the source directory and the bash script file.

The last variable is for the cron job entry that will be added to the crontab, so that the cron can begin executing. You do not need to change anything in this cron job entry. It identifies the cron job by telling that it will execute every 1 minute, at any hour, day, month or year. and it is given the arguments that will be passed to the script including the maximum number of backups.
```bash
working_dir="/home/youssef/Desktop/labs/6978-lab2/lab2bonus/"
source_dir_path="$(working_dir)dir"
backupdir_path="$(working_dir)backup-dir"
bashscript_path="$(working_dir)backup-cron.sh"
job="* * * * * /bin/bash $(bashscript_path) $(source_dir_path) $(backupdir_path)  2"
```
So the main job of the make file is to set the cron job by adding in it to the cron tab. It has two targets.

1. Checking whether the backup directory already exists, in this case leave it as it is, or not so create it.
2. Appending the cron job to the cron tab.

```bash
all: check addcron

check:
	mkdir -p $(backupdir_path); 

addcron:check
	crontab -l | { cat; echo ${job}; } | crontab -
```
## Running the cron job 
To run the cron job for the first time, just open the terminal from the directory containing the makefile and type make. This will cause the 2 targets to run.

## Script File
The main difference between this script file and the one before is that no infinite loop is needed it, that's why the time interval argument is not passed here. Because the cron job main idea is that it runs every minute, so it execute the script file for a single time, stops, and the minute after it reruns again.

When the code runs, we first add the information of the directory to the directory_info.new file, then we compare the directory_info.last with directory info.new, if they are different, make a new backup.

A final thing need to be explained, when the cron job runs for the first time, the directory_info.last will be empty, so the script will always check if that file is empty. If empty, just create a new backup, copy directory_info.new to directory_info.last and exit.

## Answer of Lab Question
### What should be the cron expression if I need to run this backup every 3rd Friday of the month at 12:31 am?
```bash
"31 0 15-21 * 5 /bin/bash $(bashscript_path) $(source_dir_path) $(backupdir_path)  2"
```
As shown here:

31: stands for the minutes, 0: stands for the hours. So the cron job will run at 12:31 am because the hours range from 0 to 23. 

15-21 * 5: * means that it will run every year. 5 stands for Friday (Days range from 0-6, where 0 is Sunday), finally 15-21 means that the cron job can execute at any day of the month from 15-21, which is the third week of the month.

So combined, we can say that the cron job will run every 3rd Friday of the month at 12:31 am.

