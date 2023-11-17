#!/bin/bash

case "$1" in
    add)
        echo "$2" >> /path/to/script_directory/repositories.txt
        ;;
    remove)
        sed -i "\|$2|d" /path/to/script_directory/repositories.txt
        ;;
    pause)
        sleep "$2"
        ;;
    update)
        case "$2" in
            interval)
                sed -i "s/^interval=.*/interval=$3/" /path/to/script_directory/config.txt
                ;;
            repositories_list)
                sed -i "s|^repositories_list=.*|repositories_list=$3|" /path/to/script_directory/config.txt
                ;;
            *)
                echo "Usage: git-sync update {interval|repositories_list} value"
                ;;
        esac
        ;;
    *)
        echo "Usage: git-sync {add|remove|pause|update}"
        ;;
esac
