#!/usr/bin/env bash

# Source a script to create bash variables from a YAML configuration.
source includes/yaml.sh

# Capture the full date for use in backup filenames.
date_full=$(date +%Y%m%d)

# Make a local directory for the date in which to store backups.
mkdir -p "${date_full}-db-files"

# Create variables from our host config file.
create_variables host-config.yml

# Loop through configured sites and create database backups.
for n in "${!sites__ssh_host[@]}"
do
	hostname=${sites__ssh_host[$n]}
	project=${sites__project[$n]}
	domain=${sites__domain[$n]}
	path=${sites__path[$n]}

	echo "Exporting ${project} at ${domain}"
	wp db export "${date_full}-${project}.sql" --ssh="${hostname}" --path="${path}"
	ssh $hostname "rm *.sql.gz"
	ssh $hostname "gzip ${date_full}-${project}.sql"
	scp $hostname:"${date_full}-${project}.sql.gz" "./${date_full}-db-files/"
done

# Synchronize DB backup with B2.
b2 sync "${date_full}-db-files" "b2://happy-prime-hosting/${date_full}-db-files/"
