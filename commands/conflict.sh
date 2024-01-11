#! /bin/bash

conflict() {
    standardOutput=$(tty)
    
    if [ $# -ne 2 ]; then
        echo "Usage: $0 file1 file2" > $standardOutput
    fi

    # Number the lines of files
    nl_file1=$(mktemp)
    nl_file2=$(mktemp)

    nl -b a -w 1 "$1" > "$nl_file1"
    nl -b a -w 1 "$2" > "$nl_file2"
    
    while true ;do

        # Shows menu
        echo -e "\n\e[0;m" > $standardOutput
        echo "Compare of files $1 and $2 :" > $standardOutput
        echo -e "--------------------------------------------\n" > $standardOutput
        echo "1. Shows uniques lines of $1" > $standardOutput
        echo "2. Shows les lines of $2" > $standardOutput
        echo "3. Shows both uniques lines (compare)" > $standardOutput
        echo "4. Shows common lines" > $standardOutput
        echo "5. Cancel the synchronization and exit" > $standardOutput
        echo "S/D. Select the file to keep (S: "$1" , D: "$2")" > $standardOutput

        # Get answer of user
        echo -e "--------------------------------------------\n" > $standardOutput
        read -p "Select an option (1-5): " choice

        case $choice in
            1)
                #Red
                echo -e "\e[1;31m\n" > $standardOutput
                echo "Uniques lines of $1 :" > $standardOutput
                comm --total --nocheck-order -23 "$nl_file1" "$nl_file2" > $standardOutput;;
            2)
                #Blue
                echo -e "\e[1;34m\n" > $standardOutput
                echo "Uniques lines of $2 :" > $standardOutput
                comm --total --nocheck-order -13 "$nl_file1" "$nl_file2" > $standardOutput;;
            3)
                #Purple
                echo -e "\e[1;35m\nUniques lines of each file (Possible that they are spaced):" > $standardOutput
                echo $1 > $standardOutput
                echo $2 > $standardOutput
                comm --total --nocheck-order --output-delimiter ""  -3 "$nl_file1" "$nl_file2" > $standardOutput;;
            4) 
                #Green
                echo -e "\e[1;32m\nCommon lines :" > $standardOutput
                comm --total --nocheck-order -12 "$nl_file1" "$nl_file2" > $standardOutput;;
            5)
                echo -e "\nLeave the script." > $standardOutput
                break
                ;;
            S)
                echo -e "\nYou chose to keep the file : $1" > $standardOutput
                echo "1"
                break;;
            D)
                echo -e "\nYou chose to keep the file : $2" > $standardOutput
                echo "2"
                break;;
            *)
                echo -e "\nOption invalide." > $standardOutput;;
        esac
    done

    # Afficher la comparaison avec la commande comm
    #echo "Différences des fichiers $file1 et $file2 :"
    #echo "--------------------------------------------"
    #echo "nb|$1|$2|both"
    #comm --output-delimiter "|" --total --nocheck-order -3 "$1" "$2" | nl -s "|" -b a -w 1

    # Delete temporary file
    rm -f "$nl_file1" "$nl_file2"
}