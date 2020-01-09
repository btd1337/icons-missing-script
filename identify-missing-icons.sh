#!/bin/bash

case "$LANG" in
    de_*)
        msg_icon_path="Gib den Pfad des Icons-Themas:"
	msg_analysing="Zum analysieren"
	msg_generated="Deine nachgesuchte Datei wurde korrekt generiert!"
	msg_fail="FEHLER: Der gegebene Pfad existiert nicht."
	msg_double_click="Bitte überprüfe neu den korrekten Pfad des Icons-Themas."
        ;;
    es_*)
        msg_icon_path="Escriba la ruta del tema de iconos:"
	msg_analysing="Analizando"
	msg_generated="¡Su archivo solicitado se generó correctamente!"
	msg_fail="ERROR: La ruta que usted escribió no existe."
	msg_double_click="POr favor verifique nuevamente la ruta correcta del tema de iconos."
        ;;
    fr_*)
        msg_icon_path="Écrivez le chemin du thème d’icônes:"
	msg_analysing="En cours d’analyse"
	msg_generated="Votre fichier demandé a été généré correctement !"
	msg_fail="FAUTE : Le chemin que vous avez écrivez n’existe pas."
	msg_double_click="S’il vous plaît, vérifiez nouvellement le chemin correct du thème d’icônes."
        ;;
    it_*)
        msg_icon_path="Scrive il percorso del pacchetto di icone:"
	msg_analysing="Analizzando"
	msg_generated="Il tuo file richiesto è stato generato correttamente!"
	msg_fail="ERRORE: Il percorso che hai scritto non esiste."
	msg_double_click="Per favore ricontrolla il percorso corretto del pacchetto di icone."
        ;;
    nl_*)
        msg_icon_path="Scrijft het pad van het pictogrammenthema:"
	msg_analysing="Analyseren"
	msg_generated="Uw aangevraagde bestand is correct gegenereerd!"
	msg_fail="FOUTJE: Het pad dat u hebt geschreven bestaat niet."
	msg_double_click="Alstublieft controleer weer het juiste pad van het pictogrammenthema."
        ;;
    pt_BR*)
        msg_icon_path="Digite o caminho do pacote de ícones:"
	msg_analysing="Analisando"
	msg_generated="Seu arquivo solicitado foi gerado corretamente!"
	msg_fail="ERRO: O caminho digitado não existe."
	msg_double_click="Por favor, verifique novamente o caminho correto do pacote de ícones."
        ;;
    pt_PT*)
        msg_icon_path="Introduz o camainho do tema de ícones:"
	msg_analysing="Analisando"
	msg_generated="Seu ficheiro solicitado foi gerado correctamente!"
	msg_fail="FALHA: O caminho introduzido não existe."
	msg_double_click="Por favor, volte a verificar o caminho correcto do pacote de ícones."
        ;;
    *)
        # English as default
        msg_icon_path="Type icon pack path:"
	msg_analysing="Analysing"
	msg_generated="Your request file was generated correctly!"
	msg_fail="ERROR: The path you typed don't exist."
	msg_double_click="Please double-check the correct icon pack path."
        ;;
esac

_msg() {
    echo "=>" "$@" >&2
}

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

read -p "$msg_icon_path " directory_icons

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
	_msg "$msg_analysing ${directory_icons##*/}..."
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
	_msg "$msg_generated"
	
	else
		echo ""
		_msg "$msg_fail"
		_msg "$msg_double_click"
fi
