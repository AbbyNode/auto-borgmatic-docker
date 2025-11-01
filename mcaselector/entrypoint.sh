#!/bin/bash

# Give user option on what to do between:
# Delete chunks
# Configure options

options=(
    "Delete Chunks"
    "Configure Options"
    "Exit"
)

PS3="Select an option: "
select opt in "${options[@]}"; do
    case $opt in
        "Delete Chunks")
            exec /mcaselector/mcaselector.sh
            ;;
        "Configure Options")
            exec /mcaselector/configure_options.sh
            ;;
        "Exit")
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done
