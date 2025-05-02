#!/bin/bash

# Interactive find command builder

echo "🔍 Interactive Find Command Helper"
echo "----------------------------------"

# 1. Directory to search
read -rp "📂 Enter directory to search (default: .): " dir
dir="${dir:-.}"

# 2. Name pattern
read -rp "📝 Enter filename pattern (e.g., *.txt), leave blank to skip: " name_pattern

# 3. File type
echo "📁 Choose file type:"
select ftype in "All" "Files (-type f)" "Directories (-type d)"; do
    case $REPLY in
        1) type_flag=""; break ;;
        2) type_flag="-type f"; break ;;
        3) type_flag="-type d"; break ;;
        *) echo "Invalid option, try again." ;;
    esac
done

# 4. Max depth
read -rp "🔢 Enter max depth (blank to skip): " maxdepth
[[ -n "$maxdepth" ]] && depth_flag="-maxdepth $maxdepth"

# 5. Time filter
read -rp "🕒 Find files modified in last N days (blank to skip): " days
[[ -n "$days" ]] && time_flag="-mtime -$days"

# Construct the command
cmd="find \"$dir\""
[[ -n "$depth_flag" ]] && cmd+=" $depth_flag"
[[ -n "$type_flag" ]] && cmd+=" $type_flag"
[[ -n "$name_pattern" ]] && cmd+=" -name \"$name_pattern\""
[[ -n "$time_flag" ]] && cmd+=" $time_flag"

# Show the final command
echo -e "\n🔧 Final command:"
echo "$cmd"

# Prompt to run it
read -rp "🚀 Run this command? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo "🔍 Running..."
    eval "$cmd"
else
    echo "❌ Cancelled."
fi
