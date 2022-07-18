#!/bin/bash
# The purpose of this script is to rebuild non-English language files to include missing key:values which are periodically added to en.js
# Requires package: dos2unix
# Made by github.com/mty22

# Variables
if [ "$2" == 'wip' ]; then
	basefile='../en.js'
else
	basefile='en.js'
fi
langfile="$1"
newlangfile="new_${langfile}"
changes="1"

# Check that we're doing things right.
if [ -z "$langfile" ]; then
	echo "Error. File usage: $0 langfile.js"
	exit 1
fi

if [ ! -s "$langfile" ]; then
	echo "Error. File usage: $0 langfile.js"
	exit 1
fi

if [ "$langfile" == "$basefile" ]; then
	echo "Error: You can't rebuild $basefile"
	exit 1
fi

# Confirmation before moving forward..
#read -p "Please note that if changes are detected, $langfile will be re-built, meaning any changes you've made will be lost (unless committed). Happy to proceed? [y/n] " verify
#if [[ "$verify" != [yY] ]]; then
#	echo "Aborting.."
#        exit 1
#fi

# Temp work space..
cat /dev/null > $newlangfile

# Loop through the base file line by line.
echo "Looping through: $basefile ..this will take a moment.."
while read -r line; do
	# If the line exists in both files, copy it across to the new file.
	key=$(echo $line | awk '{print$1}')
	if [ "$(grep -Ec "(^|\s)$key($|\s)" $langfile)" == "1" ]; then
		grep -ER "(^|\s)$key($|\s)" $langfile | dos2unix >> $newlangfile
	else
		# Add in missing key:value
		grep -ER "(^|\s)$key($|\s)" $basefile | dos2unix >> $newlangfile
		changes="0"
	fi
done < "$basefile"

# Clean up.
if [ "$changes" -eq "0" ]; then
	cat $newlangfile > $langfile
	echo "Changes were made, see diff: git diff $langfile"
	echo "To abort: git checkout $langfile"
else
	echo "No changes found between $basefile and $langfile"
fi

rm -f "$newlangfile"
