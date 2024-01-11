#!/bin/bash

# Options
while getopts ":s:b:t:e:" opt; do
    case $opt in
        s)  # Source directory
            source_directory="$OPTARG"
            if ! [[ -d $source_directory ]] || [[ "$source_directory" == */ ]]; then
                 echo "The source directory is not valid."
                 exit 1;
            fi;;
        b)  # TimeUnix start
            if ! [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
                echo "The start date must contain only numbers."
                exit 1
            fi
            start_timestamp="$OPTARG"
            ;;
        e)  # TimeUnix end
            if ! [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
                echo "The end date must contain only numbers."
                exit 1
            fi
            end_timestamp="$OPTARG";;

        t)  # Target directory
            target_directory="$OPTARG"
            if ! [[ -d $target_directory ]] || [[ "$target_directory" == */ ]]; then
                 echo "The target directory is not valid."
                 exit 1;
            fi;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1;;

        :)
            echo "The option -$OPTARG need an argument." >&2
            exit 1;;
    esac
done

if [ ! -f "$DIARY" ]; then
    echo "The diary file does not exist."
    exit 1
fi

#Check if both dates are valid
if [[ $start_timestamp != "" ]] && [[ $end_timestamp != "" ]] && [[ $start_timestamp -ge $end_timestamp ]]; then
    echo "The end date can not be lower than the start date"
    exit 1
fi

#Print all synchronizations depending on the specified options
awk -v source="$source_directory" -v destination="$target_directory" -v start_timestamp="$start_timestamp" -v end_timestamp="$end_timestamp" '
    BEGIN { RS=""; FS="\n"; OFS="\n"; found=0 }
    {
        split($3, timestamp, "=");

         if (   (source != "" && destination == "" && ($1 ~ "source=" source || $2 ~ "destination=" source)            ) ||
                (source == "" && destination != "" && ($1 ~ "source=" destination || $2 ~ "destination=" destination)  ) ||
                (source != "" && destination != "" && ($1 ~ "source=" source || $2 ~ "destination=" source) && ($1 ~ "source=" destination || $2 ~ "destination=" destination)) ||
                (source == "" && destination == "") ) {

            if ( start_timestamp == "" &&  end_timestamp == "" || (start_timestamp != "" && end_timestamp == "" && timestamp[2] >= start_timestamp) || (start_timestamp == "" && end_timestamp != "" && timestamp[2] <= end_timestamp) || 
            (start_timestamp != "" &&  end_timestamp != "" && timestamp[2] >= start_timestamp && timestamp[2] <= end_timestamp) ) {
                found=1
                for (i=1; i<=3; i++) {
                    split($i, timestamp, "=")
                    if (timestamp[1] == "LastEdit") {
                        temps_unix = timestamp[2]
                        date_lisible = strftime("%Y-%m-%d %H:%M:%S", temps_unix)
                        print "Dernière modification : " date_lisible
                    }else{
                        print $i
                    }
                }
                print "Cette synchronisation comporte un total de " NF-3 " fichiers.\n"
            }
        }
    }
    END {
        if (found == 0) {
            print "No elements has been found with the specified options."
            exit
        }
    }
' "$DIARY"