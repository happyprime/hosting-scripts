#!/usr/bin/env bash

# Source a script to create bash variables from a YAML configuration.
source includes/yaml.sh

# Create variables from our host config file.
create_variables host-config.yml

# Loop through configured sites and create database backups.
for n in "${!sites__ssh_host[@]}"
do
	auto=${sites__auto[$n]}
	hostname=${sites__ssh_host[$n]}
	project=${sites__project[$n]}
	path=${sites__path[$n]}

	if [ true == $auto ];
	then
		echo "Updating plugins on ${project}"
		wp plugin update --all --ssh=${hostname} --path=${path}
	fi
done
