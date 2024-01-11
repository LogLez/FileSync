#! /bin/bash
source ./commands/diary.sh
source ./commands/conflict.sh

 if [ $# -ne 3 ]; then
 	echo "Please make sure the command syntax is correct ! ./sync start '<Directory A>' '<Directory B>'"
 	exit 1;
 fi

if ! [[ -d $2 ]] || [[ "$2" == */ ]] || ! [[ -d $3 ]] || [[ "$3" == */ ]]; then
	 echo "Either $2 or $3 is not a directory. The synchronization cannot be done !"
	 exit 1;
fi

firstDirectory=$2
secondDirectory=$3
declare -a copiedFiles=() #array to list all files, and avoid to iterate thoses files again when we start the second copie_files

getDiaryParagraph() {

    # Create temporary file
    temp_file=$(mktemp)

    getFilesFromSynchronization "$firstDirectory" "$secondDirectory" > "$temp_file"

    # Set lines into array called lines
    readarray -t lines < "$temp_file"

    rm "$temp_file"

    echo "${lines[@]}"
}


copie_files() {
	local source=$1
	local target=$2

    # Create target directory if not exist
    if [ ! -d "$target" ]; then
        mkdir -p "$target"
        echo "Directory created : $target"
    fi

	local lines=($(getDiaryParagraph))

	# Check if result is null
	if [[ $lines == "-1" ]]; then
	    echo "Creation of the init bloc for $firstDirectory and $secondDirectory"
	    ./commands/init.sh $firstDirectory $secondDirectory
	    lines=($(getDiaryParagraph))
	fi

    #sed to remove return space at the top and the bottom of the file
	sed -i ':a;N;$!ba;s/\n\+$//' "$DIARY"

	#Check if directory is not empty
	if [ "$(ls -A $source)" ]; then
	    for fichier in "$source"/*
	    do
	    	#Is a directory
	        if [ -d "$fichier" ]; then
	            copie_files "$fichier" "$target/"$(basename "$fichier")""
	        else
	        #Is a file
	        	extractedFile=("$(echo "$fichier" | sed 's/^[^/]*\///')")

	            # Check if the file has already been iterated
	            local alreadyCopied=false
	            for copiedFile in "${copiedFiles[@]}"; do
	                if [ "$extractedFile" == "$copiedFile" ]; then
	                    alreadyCopied=true
	                    break
	                fi
	            done

	            if $alreadyCopied; then
	                continue 
	            fi
	        	copiedFiles+=("$extractedFile")

	        	echo -e "\nThe file "$fichier" is being iterated... \n"

				#Get informations from the diary if its exist for the specified file
				fileInfosFromDiary=$(getLineOfDiary "${lines[@]}" "$fichier")

	        	# If the file does not exist on the other directory
				if ! [[ -e "$target/$(basename "$fichier")" ]]; then
		            cp -a "$fichier" "$target/$(basename "$fichier")"
		            if [ -z "$fileInfosFromDiary" ]; then
		            	#echo not reported into the diary
					    insertIntoDiary $fichier
					else #The file is reported into the diary
						#echo Already into the diary
						updateDiary $fichier
					fi

		            echo "File copied : $fichier => $target/$(basename "$fichier") and updated into the diary !"
		           	continue;
		        fi

		        #The file already exist on the other directory

		        fileInfosFromSource=$(getFileInfos $fichier)
		        fileInfosFromDest=$(getFileInfos "$target/$(basename "$fichier")")

				#The file is on the diary AND the source File and dest File are different
				if ! [[ -z "$fileInfosFromDiary" ]] && [[ $fileInfosFromSource != $fileInfosFromDest ]]; then

					if [[ $fileInfosFromSource == $fileInfosFromDiary ]]; then
						echo "$fichier updated with the target directory..."
						cp -p "$target/$(basename "$fichier")" "$fichier"
					elif [[ $fileInfosFromDest == $fileInfosFromDiary ]]; then
						echo "$fichier updated with the source directory..."
						cp -p "$fichier" "$target/$(basename "$fichier")"						
					else
						echo "A conflict has been found !"
						local choix=$(conflict $fichier "$target/$(basename "$fichier")")
						if [[ $choix == 1 ]]; then
							cp -p "$fichier" "$target/$(basename "$fichier")"
						elif [[ $choix == 2 ]]; then
							cp -p "$target/$(basename "$fichier")" "$fichier"
						else
							echo "Conflict process cancelled, the file $fichier will be not synchronized"
							continue;
						fi	
					fi
					updateDiary $fichier

				#The source File and dest File are different	
				elif [[ $fileInfosFromSource != $fileInfosFromDest ]]; then
					IFS="," read -r fileName hash permission edited_at <<< "$fileInfosFromSource"
					IFS="," read -r fileNameDest hashDest permissionDest edited_atDest <<< "$fileInfosFromDest"

			        if [[ $edited_at -gt $edited_atDest ]]; then
			        	cp -p "$fichier" "$target/$(basename "$fichier")"
			        	if [ -z "$fileInfosFromDiary" ]; then
						    insertIntoDiary $fichier
						else #The file is reported into the diary
							updateDiary $fichier
						fi
			        else
			        	cp -p "$target/$(basename "$fichier")" "$fichier"
			        	if [ -z "$fileInfosFromDiary" ]; then
						    insertIntoDiary "$target/$(basename "$fichier")"
						else #The file is reported into the diary
							updateDiary "$target/$(basename "$fichier")"
						fi
			        fi

				    # Reset IFS
				    IFS=$' \t\n'

				#The source File and dest File are the same				
				else
					if [ -z "$fileInfosFromDiary" ]; then
					    insertIntoDiary $fichier
					else #The file is reported into the diary
						updateDiary $fichier
					fi
				fi				
	        fi
	    done
	    updateEditDiary
	fi
}

echo synchrozation processing...

copie_files $firstDirectory $secondDirectory
copie_files $secondDirectory $firstDirectory