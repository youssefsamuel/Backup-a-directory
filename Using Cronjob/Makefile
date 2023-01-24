working_dir="/home/youssef/Desktop/labs/6978-lab2/lab2bonus/"
source_dir_path="$(working_dir)dir"
backupdir_path="$(working_dir)backup-dir"
bashscript_path="$(working_dir)backup-cron.sh"
job="* * * * * /bin/bash $(bashscript_path) $(source_dir_path) $(backupdir_path)  2"

all: check addcron

check:
	mkdir -p $(backupdir_path); 

addcron:check
	crontab -l | { cat; echo ${job}; } | crontab -
