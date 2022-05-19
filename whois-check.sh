#!/usr/bin/env bash

# Source a script to create bash variables from a YAML configuration.
source includes/yaml.sh

# Create variables from our host config file.
create_variables host-config.yml

declare -A uniq_roots

sorted_unique_ids=($(echo "${sites__domain[@]}" | tr ' ' '\n' | awk -F . '{print $(NF-1)"."$NF}' | sort -u | tr '\n' ' '))

for d in "${sorted_unique_ids[@]}"
do
	expires=`whois ${d} | egrep -i "Expiration Date:|Expires on|Expiry" | head -1 | awk '{print $NF}'`
	echo "${d} ${expires}"
done
