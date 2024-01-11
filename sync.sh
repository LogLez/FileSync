#! /bin/bash
if [[ -z "${DIARY}" ]]; then
    export DIARY="C:\Users\rmors\diary.synchro"
fi

if [ $# == 0 ]; then
 	echo "############################################################################################
#   _______           _        _______       _______ _________ _        _______  _______   #
#  (  ____ \|\     /|( (    /|(  ____ \     (  ____ \\__   __/( \      (  ____ \(  ____ \'  #
#  | (    \/( \   / )|  \  ( || (    \/     | (    \/   ) (   | (      | (    \/| (    \/  #
#  | (_____  \ (_) / |   \ | || |           | (__       | |   | |      | (__    | (_____   #
#  (_____  )  \   /  | (\ \) || |           |  __)      | |   | |      |  __)   (_____  )  #
#        ) |   ) (   | | \   || |           | (         | |   | |      | (            ) |  #
#  /\____) |   | |   | )  \  || (____/\ _   | )      ___) (___| (____/\| (____/\/\____) |  #
#  \_______)   \_/   |/    )_)(_______/(_)  |/       \_______/(_______/(_______/\_______)  #
#                                                                                          #
############################################################################################    

Welcome to File Synchronizer ! This program allows you to synchronize 2 differents directories and merge files in case of conflicts.
Here you can find all the commands and its description.
 "
 	sh ./commands/help.sh
 	exit 1;
 fi

#Start the script with the specified command
 case $1 in
 	init) sh ./commands/init.sh "${@:2}";;
	start) sh ./commands/start.sh $@;;
	infos) sh ./commands/infosDiary.sh "${@:2}";;
	remove) sh ./commands/delete.sh "${@:2}";;
	help) sh ./commands/help.sh;;
	*) echo Unknown command, please type ./sync help
 esac
