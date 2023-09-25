#!/bin/bash

# Read configuration values from the config.txt file
source config.txt

# Create log files if the y don't exist
touch "$changes_log"
touch "$errors_log"

while true; do
    # Read repository paths from the input file
    while IFS= read -r repo_path; do
        # Navigate to the repository directory
        cd "$repo_path" || continue

        # Check for changes in the local repository
        if [[ -n $(git status -s) ]]; then
            # Get current date, time, and OS information
            current_date=$(date +"%Y-%m-%d %H:%M:%S")
            os_info=$(uname -a)

            # Commit and push changes
            git add .
            git commit -m "Git-Sync on $current_date from $os_info"
            git push origin master

            # Log the commit and push in changes.log
            echo "[$current_date] Commit and push in $repo_path" >> "$changes_log"
        fi

        # Check for changes in the upstream repository
        git remote update
        if [[ -n $(git rev-list HEAD..origin/"$master_branch" --count) ]]; then
            # Pull changes from the upstream repository
            git pull origin master

            # Log the pull in changes.log
            echo "[$(date +"%Y-%m-%d %H:%M:%S")] Pull in $repo_path" >> "$changes_log"
        fi
    done < "$repo_list"

    sleep "$interval"  # Sleep for the configured interval
done #2>> "$errors_log"  # Redirect errors to errors.log
