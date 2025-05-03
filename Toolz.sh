#!/bin/bash

# Toolz - Multi-tool Utility
# Description: Combines multiple system admin tools in one script
# Author: Dmitry Sapojnikov
# Course: BIU DevSecOps 19
# Lecturer: Yuval Shaul
# Date: 5.3.2025

error() { echo -e "$[ERROR] $1" >&2; }
info()  { echo -e "$[INFO] $1"; }
warn()  { echo -e "$[WARN] $1"; }

find_helper() {
    echo -e "Interactive Find Helper"
    read -rp "Enter directory to search: " dir
    read -rp "Enter filename pattern (e.g. *.log): " pattern
    read -rp "Enter additional find options (optional): " extra
    echo
    find "$dir" -name "$pattern" $extra
}

system_info() {
    echo -e "System Information"
    echo -e "Memory Usage:"; free -h
    echo -e "\nRunning Processes:"; ps -e --no-headers | wc -l
    echo -e "\nDisk Usage:"; df -h | grep -E "^/dev/"
}

process_mgmt() {
    echo -e "Top Processes"
    echo "Sort by: (1) CPU (2) Memory (3) Runtime"
    read -rp "Choose option: " sort
    case $sort in
        1) ps -eo pid,comm,%cpu --sort=-%cpu | head -n 10;;
        2) ps -eo pid,comm,%mem --sort=-%mem | head -n 10;;
        3) ps -eo pid,comm,etime --sort=etime | head -n 10;;
        *) error "Invalid option"; return;;
    esac
    echo -e "\nKill process? (y/n)"
    read -r confirm
    if [[ "$confirm" == "y" ]]; then
        read -rp "Enter PID: " pid
        kill "$pid" && info "Process $pid killed." || error "Failed to kill process."
    fi
}

user_mgmt() {
    echo -e "User Management"
    echo "(1) Logged in users"
    echo "(2) User account info"
    echo "(3) User resource usage"
    read -rp "Choose option: " opt
    case $opt in
        1) who;;
        2) read -rp "Enter username: " uname; id "$uname" && getent passwd "$uname";;
        3) ps -eo user,comm,%cpu,%mem --sort=-%cpu | grep "^$(whoami)" | head -n 10;;
        *) error "Invalid option";;
    esac
}

show_help() {
    cat << EOF
Toolz - Multi-Tool Utility Script
Usage: ./toolz.sh [option]

Options:
  -f        Interactive find helper
  -s        Show system information
  -p        Process management
  -u        User management
  -h        Display this help menu

Examples:
  ./toolz.sh -f        # Use the find helper interactively
  ./toolz.sh -s        # Display system metrics
  ./toolz.sh -p        # Manage and inspect processes
  ./toolz.sh -u        # View or manage user information
EOF
}

menu_interface() {
    echo -e "Welcome to Toolz Utility"
    select opt in "Find Helper" "System Info" "Process Management" "User Management" "Help" "Exit"; do
        case $REPLY in
            1) find_helper;;
            2) system_info;;
            3) process_mgmt;;
            4) user_mgmt;;
            5) show_help;;
            6) exit;;
            *) warn "Invalid selection";;
        esac
    done
}

if [[ $# -eq 0 ]]; then
    menu_interface
    exit 0
fi

while getopts ":fspuh" opt; do
    case ${opt} in
        f) find_helper;;
        s) system_info;;
        p) process_mgmt;;
        u) user_mgmt;;
        h) show_help;;
        :) error "Option -$OPTARG requires an argument.";;
        \?) error "Invalid option: -$OPTARG"; show_help; exit 1;;
    esac
done