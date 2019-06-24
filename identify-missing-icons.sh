#!/bin/bash

# Set default language english
lang=${lang:-en}

# Check if any optional language was passed and set it
while [ $# -gt 0 ]; do

	if [[ $1 == *"--"* ]]; then
				param="${1/--/}"
				declare $param="$2"
	fi

	shift
done

desktop_icons=(
	"/usr/share/applications"
	"$HOME/.local/share/applications"
	"$HOME/.local/share/flaptak/app"
	"/var/lib/snapd/desktop/applications/"
)

suffix=".desktop"
dest_file="my_request.txt"

read -p "Type icon pack path: " directory_icons

function printAppName() {
	local appName=$1;
	local appNameTranslated=$2;

	if [[ -z $appNameTranslated ]]	# Check if appNameTranslated is not set
		then 
			echo "- [ ] **$appName**" >> $dest_file
		else 
			if [ $appName == $appNameTranslated ]
				then echo
					echo "- [ ] **$appName**" >> $dest_file
				else echo
					echo "- [ ] **$appName**  | **$appNameTranslated**" >> $dest_file
			fi
	fi

	
}

if [ -d $directory_icons ]; then
	echo ""
	echo "Analysing ${directory_icons##*/}..."
	# Check if file already exists and remove them
	if [ -f $dest_file ]; then
		rm $dest_file
	fi

	for desktop_icons_folder in ${desktop_icons[@]}
	do
		# Check if folder that contains .desktop exists
		if [ -d $desktop_icons_folder ]; then
			# Loop in all .desktop in the folder
			for entry in "$desktop_icons_folder"/*
			do
				file="${entry%"$suffix"}.svg"
				fileName=${file##*/}
				iconName=$(sed -n '/^Icon=/p; /^Icon=/q' $entry)
				iconName="${iconName#"Icon="}.svg"
				fileCount=$(find $directory_icons -name $iconName | wc -l)
				if grep -q Icon= $entry; then						# Check if it have icon
					if [[ $fileCount == 0 ]]; then

						# Search name in entry file
						appName=$(sed -n '/^Name=/p; /^Name=/q' $entry)			
						# Get app name
						appName="${appName#"Name="}"

						if [ $lang != "en" ]
							then
								appNameTranslated=$(sed -n "/^GenericName\[${lang}\]=/p; /^GenericName\[${lang}\]=/q" $entry)
 								appNameTranslated="${appNameTranslated#"GenericName[it]="}"
						fi

						printAppName "$appName" "$appNameTranslated"

						sed -n '/^Comment=/p; /^Comment=/q' $entry >> $dest_file

						if [ $lang != "en" ]
							then
								sed -n "/^Comment\[${lang}\]=/p; /^Comment\[${lang}\]=/q" $entry >> $dest_file
						fi

						sed -n '/^Icon=/p; /^Icon=/q' $entry >> $dest_file
						echo "[Icon Link]()" >> $dest_file
						echo "" >> $dest_file
					fi
				fi
			done
		fi
	done
	echo ""
	echo "Your request file was generated correctly!"
	
	else
		echo ""
		echo "ERROR: The path you typed don't exist."
		echo "Please double-check the correct icon pack path."
fi
