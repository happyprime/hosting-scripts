#!/usr/bin/env bash

# Source a script to create bash variables from a YAML configuration.
source includes/yaml.sh

# Create variables from our host config file.
create_variables host-config.yml

# Loop through configured sites and check the current WordPress version.
for n in "${!sites__ssh_host[@]}"
do
	hostname=${sites__ssh_host[$n]}
	domain=${sites__domain[$n]}
	path=${sites__path[$n]}

	echo "${domain} version check"
	wp core version --ssh="${hostname}" --path="${path}"
	wp plugin list --update=available --ssh="${hostname}" --path="${path}"
	wp theme list --update=available --ssh="${hostname}" --path="${path}"
done
