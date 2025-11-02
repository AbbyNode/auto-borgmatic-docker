#!/bin/bash

# Delete old chunks based on a combination of
# LastUpdated
# InhabitedTime

# Load configuration from YAML file
OPTIONS_FILE=/config/mcaselector-options.yaml

if [[ ! -f "$OPTIONS_FILE" ]]; then
    echo "Error: Configuration file not found: $OPTIONS_FILE"
    exit 1
fi

# Parse YAML and build delete_chunks array
declare -a delete_chunks=()

# Extract delete_chunks section from YAML
yaml_content=$(sed -n '/^delete_chunks:/,/^[^ ]/p' "$OPTIONS_FILE" | sed '$ d')

if [[ -z "$yaml_content" ]]; then
    echo "Error: delete_chunks configuration not found in $OPTIONS_FILE"
    exit 1
fi

# Parse each condition from YAML
while IFS= read -r line; do
    if [[ $line =~ ^[[:space:]]*-[[:space:]]]]; then
        # Extract LastUpdated value
        last_updated=$(echo "$line" | sed 's/.*last_updated:[[:space:]]*["'"'"']\?\([^"'"'"']*\).*/\1/')
        
        # Read next line for InhabitedTime
        IFS= read -r next_line
        inhabited_time=$(echo "$next_line" | sed 's/.*inhabited_time:[[:space:]]*["'"'"']\?\([^"'"'"']*\).*/\1/')
        
        if [[ ! -z "$last_updated" && ! -z "$inhabited_time" ]]; then
            delete_chunks+=("$last_updated|$inhabited_time")
        fi
    fi
done <<< "$yaml_content"

# create group string based on array
group_string=""
for condition in "${delete_chunks[@]}"; do
    IFS='|' read -r last_updated inhabited_time <<< "$condition"
    group_string+="(LastUpdated >= $last_updated AND InhabitedTime >= $inhabited_time) OR "
done
group_string=${group_string% OR }

java -jar /mcaselector/MCASelector.jar \
    --mode delete \
    --world /world \
    --query "$group_string"
