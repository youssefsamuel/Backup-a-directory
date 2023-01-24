original_directory=./dir
backup_directory=./backup_dir
interval_secs=5
max_backups=2

all:check run

check:
	mkdir -p $(backup_directory)

run:check
	./backupd.sh $(original_directory) $(backup_directory) $(interval_secs) $(max_backups)
	
	
	
