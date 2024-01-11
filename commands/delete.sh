#!/bin/bash
source ./commands/diary.sh

getDiaryParagraph() {

    # Create temporary file
    temp_file=$(mktemp)

    getFilesFromSynchronization "$1" "$2" > "$temp_file"

    # Set lines into array called lines
    readarray -t lines < "$temp_file"

    rm "$temp_file"

    echo "${lines[@]}"
}

function removeSyncBlock() {
    local source="$1"
    local destination="$2"

    if [ ! -f "$DIARY" ]; then
        echo "The file does not exist."
        return 1
    fi

    local lines=$(getDiaryParagraph $1 $2)
    if [[ $lines == '-1' ]]; then
        echo "$source and $destination do not have synchronization yet"
        exit 0;
    fi

    #Remove specified synchronization block
    awk -v source="$source" -v destination="$destination" '
        BEGIN { RS="\n\n"; ORS="\n\n"; FS="\n"; OFS="\n" }
        {
            if (!((($1 ~ "source=" source && $2 ~ "destination=" destination) || ($1 ~ "source=" destination && $2 ~ "destination=" source)))) {
                print $0
            }
        }
    ' "$DIARY" > temp_journal.txt

    mv temp_journal.txt "$DIARY"

    #sed to remove return space at the top and the bottom of the file
    sed -i -e '/./,$!d' -e ':a;N;$!ba;s/\n\+$//' "$DIARY"

    echo "Bloc deleted for the synchronization between $source et $destination."
}

removeSyncBlock "$1" "$2"