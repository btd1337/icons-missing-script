#!/bin/bash

desktop_icons=/usr/share/applications
directory_icons=/home/arch/.icons/GNOME++
suffix=.desktop
dest_file=my_request.txt

# Check if file already exists and remove them
if [ -f $dest_file ]; then
	rm $dest_file
fi

for entry in "$desktop_icons"/*
do
	file="${entry%"$suffix"}.svg"
	filename=${file##*/}
	iconname=$(sed -n '/^Icon=/p; /^Icon=/q' $entry)
	iconname="${iconname#"Icon="}.svg"
	file_count=$(find $directory_icons -name $iconname | wc -l)
	if grep -q Icon= $entry; then						# Check if it have icon
		if [[ $file_count == 0 ]]; then
			appname=$(sed -n '/^Name=/p; /^Name=/q' $entry)
			appname="${appname#"Name="}"
			echo "- [ ] **$appname**" >> $dest_file
			sed -n '/^Comment=/p; /^Comment=/q' $entry >> $dest_file
			sed -n '/^Icon=/p; /^Icon=/q' $entry >> $dest_file
			echo "[Icon Link]()" >> $dest_file
			echo "" >> $dest_file
		fi
	fi
done
