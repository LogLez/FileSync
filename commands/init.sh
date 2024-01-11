#! /bin/bash
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

createBloc() {
    local source=$1
    local destination=$2

    if [ ! -f "$DIARY" ]; then
        echo "The diary file does not exist."
        return 1
    fi

    local lines=$(getDiaryParagraph $1 $2)
    if [[ $lines != '-1' ]]; then
        echo "$source and $destination already init"
        exit 0;
    fi

    #sed to remove return space at the top and the bottom of the file
    sed -i ':a;N;$!ba;s/\n\+$//' "$DIARY"

    #add synchronization block after the last line
    lastLine=$(awk 'NF{print $0}' "$DIARY" | tail -n 1)
    if [ -n "$lastLine" ]; then
        { cat "$DIARY"; echo -e "\nsource=$source"; echo "destination=$destination"; echo "LastEdit=$(date +%s)"; } > temp_diary.synchro

        mv temp_diary.synchro "$DIARY"

        echo "Bloc added successfully."
    fi
    return 0
}

createBloc $1 $2
