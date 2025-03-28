#!/bin/sh
# Filename: fidupe.sh
# Description: Identifies duplicate files using md5sum and removes all but one instance of each duplicate set.

# List files sorted by size, compute md5sum, and identify duplicates
ls -l | awk 'NR>1 {print $9}' | while read -r file; do
    if [ -f "$file" ]; then
        md5sum "$file"
    fi
done | sort | uniq -D -w 32 | awk '{print $2}' > duplicate_files

# Keep one sample of each duplicate set
cat duplicate_files | xargs -I {} md5sum "{}" | sort | uniq -u -w 32 | awk '{print $2}' > duplicate_sample

# Remove duplicates, keeping one sample
echo "Removing duplicate files..."
comm -23 duplicate_files duplicate_sample | tee /dev/stderr | xargs rm -f

echo "Duplicate files removed successfully."