#!/bin/bash



# Check if .gitmodules exists

if [[ ! -f .gitmodules ]]; then

    echo "No .gitmodules file found. Exiting."

    exit 1

fi



# Initialize variables

submodule_path=""

submodule_url=""



# Read .gitmodules file line by line

while IFS= read -r line; do

    # Detect a new submodule block

    if [[ "$line" =~ ^\[submodule\ \"(.*)\"\]$ ]]; then

        # Clear variables for the new submodule

        submodule_name="${BASH_REMATCH[1]}"

        submodule_path=""

        submodule_url=""

        continue

    fi



    # Extract submodule path

    if [[ "$line" =~ path[[:space:]]=\ (.*) ]]; then

        submodule_path="${BASH_REMATCH[1]}"

        continue

    fi



    # Extract submodule URL

    if [[ "$line" =~ url[[:space:]]=\ (.*) ]]; then

        submodule_url="${BASH_REMATCH[1]}"

    fi



    # Ensure both path and URL are set before proceeding

    if [[ -n "$submodule_path" && -n "$submodule_url" ]]; then

        # Match the URL against doronbehar's GitHub

        if [[ "$submodule_url" == https://github.com/doronbehar/* ]]; then

            echo "Processing submodule: $submodule_name"

            echo "Path: $submodule_path"

            echo "URL: $submodule_url"



            # Ensure the submodule directory exists

            if [[ -d "$submodule_path" ]]; then

                echo "Backing up submodule content from: $submodule_path"



                # Step 1: Back up submodule content to a temporary directory

                temp_backup_dir="/tmp/submodule_backup_$submodule_name"

                mkdir -p "$temp_backup_dir"

                cp -r "$submodule_path"/* "$submodule_path"/.??* "$temp_backup_dir" 2>/dev/null || true



                # Step 2: Deinitialize the submodule

                echo "Deinitializing submodule..."

                git submodule deinit -f "$submodule_path"

                rm -rf ".git/modules/$submodule_path"

                rm -rf "$submodule_path"



                # Step 3: Restore content from the backup to the original submodule directory

                echo "Restoring submodule content to: $submodule_path"

                mkdir -p "$submodule_path"

                mv "$temp_backup_dir"/* "$temp_backup_dir"/.??* "$submodule_path" 2>/dev/null || true

                rm -rf "$temp_backup_dir"



                # Step 4: Remove the .git file to fully unlink the submodule

                if [[ -f "$submodule_path/.git" ]]; then

                    echo "Removing .git file from: $submodule_path"

                    rm -f "$submodule_path/.git"

                fi

            else

                echo "Submodule path does not exist: $submodule_path. Skipping..."

            fi

        else

            echo "Skipping submodule: $submodule_name (URL does not match)"

        fi



        # Clear variables for safety before processing the next submodule

        submodule_path=""

        submodule_url=""

    fi

done < .gitmodules



# Cleanup: Remove .gitmodules if all submodules are processed

if ! git submodule | grep -q .; then

    echo "All submodules processed. Removing .gitmodules..."

    rm -f .gitmodules

fi



echo "Done!"


