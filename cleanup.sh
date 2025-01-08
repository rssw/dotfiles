#!/bin/bash



# Ensure .gitmodules exists

if [[ ! -f .gitmodules ]]; then

    echo "No .gitmodules file found. Exiting."

    exit 1

fi



## Backup the current .gitmodules file
#
#cp .gitmodules .gitmodules.bak
#
#
#
## Prepare a new .gitmodules file for external submodules
#
#new_gitmodules=$(mktemp)
#
#
#
## Retain only external submodules in the new .gitmodules
#
#while IFS= read -r line; do
#
#    if [[ "$line" =~ ^\[submodule\ \"(.*)\"\]$ ]]; then
#
#        # Start of a new submodule block, reset tracking variables
#
#        submodule_name="${BASH_REMATCH[1]}"
#
#        include_submodule=false
#
#        pending_submodule_header="$line"
#
#        pending_submodule_path=""
#
#        echo "Processing submodule: $submodule_name" >&2
#
#        # Handle malformed submodule entries
#
#        if [[ -z "$submodule_name" ]]; then
#
#            echo "Warning: Found an empty or invalid submodule name. Skipping." >&2
#
#            continue
#
#        fi
#
#    elif [[ "$line" =~ ^[[:space:]]+path[[:space:]]=[[:space:]](.*)$ ]]; then
#
#        pending_submodule_path="$line"
#
#        if $include_submodule; then
#
#            echo "$pending_submodule_header" >> "$new_gitmodules"
#
#            echo "$line" >> "$new_gitmodules"
#
#            pending_submodule_header=""
#
#        fi
#
#    elif [[ "$line" =~ ^[[:space:]]+url[[:space:]]=[[:space:]](.*)$ ]]; then
#
#        submodule_url="${BASH_REMATCH[1]}"
#
#        # Check if the URL is external (not doronbehar's)
#
#        if [[ "$submodule_url" != https://github.com/doronbehar/* ]]; then
#
#            include_submodule=true
#
#            echo "Keeping submodule: $submodule_name (URL: $submodule_url)" >&2
#
#            echo "$pending_submodule_header" >> "$new_gitmodules"
#
#            echo "$line" >> "$new_gitmodules"
#
#            pending_submodule_header=""
#
#            if [[ -n "$pending_submodule_path" ]]; then
#
#                echo "$pending_submodule_path" >> "$new_gitmodules"
#
#                pending_submodule_path=""
#
#            fi
#
#        else
#
#            include_submodule=false
#
#            echo "Deleting submodule: $submodule_name (URL: $submodule_url)" >&2
#
#        fi
#
#    elif $include_submodule; then
#
#        # Write other lines of external submodules
#
#        echo "$line" >> "$new_gitmodules"
#
#    fi
#
#
#
#done < .gitmodules
#
#
#
## Replace the original .gitmodules with the new one
#
#mv "$new_gitmodules" .gitmodules



# Clean up removed submodules

removed_submodules=()

while IFS= read -r submodule; do

    if ! grep -qw "path = $submodule" .gitmodules; then

        removed_submodules+=("$submodule")

    fi

done < <(git config --file .gitmodules.bak --get-regexp path | awk '{print $2}')



# Remove references to removed submodules but retain their files

for submodule_path in "${removed_submodules[@]}"; do

    echo "Breaking link for submodule: $submodule_path"

    git submodule deinit -f "$submodule_path" || {

        echo "Staging changes to .gitmodules and stashing before retrying..."

        git add .gitmodules

        git stash push -m "Stashed changes for submodule cleanup"

        git submodule deinit -f "$submodule_path"

        git stash pop

    }

    git rm --cached "$submodule_path"

    rm -rf ".git/modules/$submodule_path"

    # Do not delete the submodule directory to retain its files

    echo "Retained files in $submodule_path"

done



# Commit the changes

if [[ ${#removed_submodules[@]} -gt 0 ]]; then

    echo "Committing changes to retain only external submodules..."

    git add .gitmodules

    git commit -m "Removed internal submodules and retained only external ones"

else

    echo "No changes to commit. All submodules are external."

fi



# Cleanup

echo "Cleanup complete. Remaining submodules are listed in .gitmodules."


