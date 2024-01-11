#! /bin/bash

# Check if file exist
if [ ! -f "$DIARY" ]; then
    echo "The diary file does not exist."
    exit 1
fi

#Get a specific line from the diary related to the specified file
getLineOfDiary() {
    local lines=("$@")  # Use "$@" to access to everything
    local file=${lines[${#lines[@]}-1]}
    file=$(echo "$file" | sed 's/^[^/]*\///')
    unset lines[${#lines[@]}-1]
    global_line=""

    for line in "${lines[@]}"; do
        IFS="," read -r fileName hash permission edited_at <<< "$line"

        if [ "$fileName" ] && [ "$fileName" = "$file" ] ; then
            global_line="$line"
            IFS=$' \t\n'
            break 
        fi
    done

    # Reset IFS
    IFS=$' \t\n'

    echo "$global_line"
}

#Get file's informations in a string
getFileInfos() {
    local file="$1"
    infos=""

    if [ -f $file ]; then
        filePath=$(echo "$file" | sed 's/^[^/]*\///') #Sed for removing the first directory of the path ( /A/test/file.txt --> /test/file.txt)
        permissions=$(stat -c "%a" "$file")
        hash=$(echo "$(sha256sum "$file")" | awk '{print $1}')
        creationDate=$(stat -c '%w' "$file")
        modificationDate=$(stat -c %y "$file")

        infos="$filePath,$hash,$permissions,$(date --date="$modificationDate" +"%s")"
    fi

    echo "$infos"
}

#get all files related in the diary for the specified 2 directories
getFilesFromSynchronization(){
    local repertoire_source="$1"
    local repertoire_destination="$2"

    awk -v source="$repertoire_source" -v destination="$repertoire_destination" '
         BEGIN { RS=""; FS="\n"; OFS="\n"; found=0 }
        ($1 ~ "source=" source && $2 ~ "destination=" destination) || ($1 ~ "source=" destination && $2 ~ "destination=" source) {
            found=1;
            if ( NF > 3 ){
                for (i=4; i<=NF; i++) {
                    print $i
                }
            }
        }
        END {
            if (found == 0) {
                print "-1"
            }
        }
    ' "$DIARY"
}

#Update the file's informations in the diary
updateDiary() {
    local file="$1"

    permissions=$(stat -c "%a" "$file")
    hash_result=$(sha256sum "$file")
    hash=$(echo "$hash_result" | awk '{print $1}')
    modificationDate=$(stat -c %y "$file")

    awk -v source="$firstDirectory" -v cible="$secondDirectory" -v file="$(echo "$file" | sed 's/^[^/]*\///')" \
        -v permissions="$permissions" -v hash="$hash" \
        -v modificationDate="$(date --date="$modificationDate" +"%s")" \
        'BEGIN { RS="\n\n"; ORS="\n\n"; FS="\n"; OFS="\n" }
        {
           
            if (($1 == "source=" source && $2 == "destination=" cible) || ($1 == "source=" cible && $2 == "destination=" source) && NF > 3) {
                for (i = 4; i <= NF; i++) {
                    split($i, fields, ",");               
                    if (fields[1] == file) {
                        fields[2] = hash;
                        fields[3] = permissions;
                        fields[4] = modificationDate;
                        $i = fields[1] "," fields[2] "," fields[3] "," fields[4];
                        break;
                    }          
                }
            }
        }
        { print }
    ' "$DIARY" > temp_journal.txt

    mv temp_journal.txt "$DIARY"
}

#Insert the file's informations into the diary
insertIntoDiary() {
    #Sed for remove spaces before and after the first and last paragraph
    sed -i -e '/./,$!d' -e ':a;N;$!ba;s/\n\+$//' "$DIARY"

    local file="$1"

    permissions=$(stat -c "%a" "$file")
    hash_result=$(sha256sum "$file")
    hash=$(echo "$hash_result" | awk '{print $1}')
    modificationDate=$(stat -c %y "$file")

    awk -v source="$firstDirectory" -v destination="$secondDirectory" -v file="$(echo "$file" | sed 's/^[^/]*\///')" \
        -v permissions="$permissions" -v hash="$hash" \
        -v modificationDate="$(date --date="$modificationDate" +"%s")" \
        'BEGIN { RS="\n\n"; ORS="\n\n"; FS="\n"; OFS="\n"; count=0 }
        {
            if (($1 == "source=" source && $2 == "destination=" destination) || ($1 == "source=" destination && $2 == "destination=" source) ) {
                    
                while ($(NF-count) == "") {
                    count++
                }

                $(NF-count) = $(NF-count) "\n" file "," hash "," permissions  "," modificationDate;
            }
        }
        { print $0 }
    ' "$DIARY" > temp_journal.txt
    
    mv temp_journal.txt "$DIARY"
}

#Update the last modification date to now in the diary
updateEditDiary() {

    awk -v source="$firstDirectory" -v destination="$secondDirectory" -v edit="$(date +%s)"  \
        'BEGIN { RS="\n\n"; ORS="\n\n"; FS="\n"; OFS="\n" }
        {
            if ($1 == "source=" source && $2 == "destination=" destination) {  
                $3 = "LastEdit="edit;      
            }
        }
        { print $0 }
    ' "$DIARY" > temp_journal.txt
    
    mv temp_journal.txt "$DIARY"

}