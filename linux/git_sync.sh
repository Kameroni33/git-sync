#!/bin/bash

# global variables
config_file="./config.txt"
repo_list_file="./repos.txt"
log_folder="./logs"

# update configuration file
function update_config() {
  local variable_to_update="$1"
  local new_value="$2"
  sed -i.bak "s/^\($variable_to_update[[:space:]]*=\)\([^[:space:]]*\)/\1$new_value/" "$config_file"
}

# handling all logging details
function log() {
  local level="$1"
  local message="$2"
  local date=$(date '+%Y-%m-%d')
  local time=$(date '+%H:%M:%S')
  local log_file="$log_folder/${date}.log"
  echo "| $time | $level | $message" >> "$log_file"
}

# remove element from a list
function remove_element() {
  local -n list="$1"
  local element="$2"
  local temp_list=()
  for item in "${list[@]}"; do
    if [ "$item" != "$element" ]; then
      temp_list+=("$item")
    fi
  done
  list=("${temp_list[@]}")
}

# load config file
if [ -f "$config_file" ]; then
  source "$config_file"
else
  echo "Config file not found: $config_file"
  exit 1
fi

# load repos list
if [ -f "$repo_list_file" ]; then
  mapfile -t repo_list < "$repo_list_file"
else
  echo "Repo list file not found: $repo_list_file"
  exit 1
fi

# process command line arguments
while [ $# -gt 0 ]; do
  case "$1" in
    -h|--help)
      echo "Usage: git-sync [OPTIONS]"
      echo
      echo "Options:"
      echo "  -h, --help     Display this help message"
      echo "  -u, --update   Update configuration. Usage: -u [CONFIG] [VALUE]"
      echo "  -c, --clear    Remove all log files."
      exit 0
      ;;
    -u|--update)
      if [[ $# -gt 2 ]]; then
        update_config "$2" "$3"
        shift 3
      else
        echo "Error: Not enough arguments. Usage: -u [CONFIG] [VALUE]"
        exit 1
      fi
      ;;
    -c|--clear)
      rm -f "$log_folder/*.log"
      shift 1
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# do git sync
while true; do
  for repo in "${repo_list[@]}"; do
    if [ -d "$repo/.git" ]; then
      # perform: git add -A
      add_result=$(git -C "$repo" add -A 2>&1)
      if [ $? -ne 0 ]; then
        log "ERROR" "$add_result"
      else
        log "INFO" "$add_result"
      fi
      # perform: git commit -m "message"
      message="Git-Sync at $(date '+%Y-%m-%d %H:%M:%S %Z')"
      commit_result=$(git -C "$repo" commit -m "$message" 2>&1)
      if [ $? -ne 0 ]; then
        log "ERROR" "$commit_result"
      else
        log "INFO" "$commit_result"
      fi
      # perform: git pull
      pull_result=$(git -C "$repo" pull 2>&1)
      if [ $? -ne 0 ]; then
        if [[ $pull_result != *"branch is up to date"* ]]; then
          log "ERROR" "$pull_result"
        fi
      fi
      # perform: git push
      push_result=$(git -C "$repo" push 2>&1)
      if [ $? -ne 0 ]; then
        log "ERROR" "$push_result"
      else
        log "INFO" "$push_result"
      fi
    else
      log "WARNING" "$repo is not a .git repository"
      remove_element repo_list "$repo"
    fi
  done
  sleep "$INTERVAL"
done
