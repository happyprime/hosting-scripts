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
	client=${sites__ssh_host[$n]}
	domain=${sites__domain[$n]}

	echo "Exporting ${client} at ${domain}"
	wp db export "${date_full}-${client}.sql" --ssh="${client}" --path="www/${domain}/public_html"
	ssh $client "rm *.sql.gz"
	ssh $client "gzip ${date_full}-${client}.sql"
	scp $client:"${date_full}-${client}.sql.gz" "./${date_full}-db-files/"
done
