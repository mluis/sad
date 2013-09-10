#!/usr/bin/env bash

DATABASE="sad.db";
VERSION="v0.0.1";

# 'XXX'
__ReadCardFromReader(){
	# local cardId="FOO";

	readFromCard=`opensc-tool -w -a 2>/dev/null`;
	echo "$readFromCard";
	# echo "Exit status: $?";
	# read
}

__RegisterCard(){

	echo "[+] Reading from card...";
	local cardId="$(__ReadCardFromReader)";

	if [ ! -f $DATABASE ]; then
		echo -n "[+] Database does not exist, create? (Y/n) ";
		read choice

		if [ "$choice" == 'Y' ] || [ "$choice" == 'y' ] || [ -z "$choice" ]; then
			echo "[+] Creating database...";
			touch $DATABASE;

			echo "[+] Registering card..."
			echo "$cardId" >> $DATABASE;
		fi

	else
		# echo "[+] Checking if card exists in database...";
		result=`grep "$cardId" "$DATABASE"`;

		if [ "$result" == "$cardId" ]; then
			echo "[+] Card already registered.";
		else
			echo "[+] Registering card...";
			echo "$cardId" >> $DATABASE;
			
		fi
	fi

	echo "[+] Card Registered."
}

__UnregisterCard(){

	echo "[+] Reading card...";
	local cardId="$(__ReadCardFromReader)";

	if [ ! -f $DATABASE ]; then
		echo "[+] Can't find database.";
	else
		echo "[+] Unregistering card...";
		unregister=`grep -v "$cardId" "$DATABASE" > $DATABASE.tmp && mv $DATABASE.tmp $DATABASE`;
		echo "[+] Card's unregistered.";
	fi

}

__ExitSAD(){
	exit="YES";
}

__Menu(){
	cmd=(dialog --keep-tite --menu "Select an option:" 13 22 22)

	options=(1 "Register Card"
	         2 "Unregister Card"
	         3 "Run Service"
	         4 "Stop Service"
	         5 "Exit")

	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)

	for choice in $choices
	do
	    case $choice in
	        1)
				echo "	Register Card";
	            __RegisterCard
	            read
	            ;;
	        2)
	            echo "	Unregister Card";
	            __UnregisterCard
	            read
	            ;;
	        3)
	            echo "	Run Service"
	            ;;
	        4)
	            echo "	Stop Service"
	            ;;
	        5)
	            echo "	Exit";
	            __ExitSAD
	            ;;
	    esac
	done;
}


__Main(){
	echo "+======== SMARTCARD AUTHENTICATION DAEMON MANAGER $VERSION ========+";
	while [ 1 ]
	do
		__Menu;
		if [ "$exit" == "YES" ]; then
			break
		fi
	done
}

# Main part
__Main
exit





# Run service
# PIDFILE=/var/tmp/$(basename $0).pid

# # Check for existing lockfile:
# if [ -e $PIDFILE ]; then
#   echo "Another instance (`cat $PIDFILE`) still running?"
#   echo "If you are sure that no other instance is running, delete the lockfile"
#   echo "'${PIDFILE}' and re-start this script."
#   echo "Aborting now..."
#   exit 1
# else
#   # Create our new lockfile:
#   echo $$ > $PIDFILE
# fi
