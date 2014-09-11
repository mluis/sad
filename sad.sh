#!/usr/bin/env bash

DATABASE="sad.db";
VERSION="v0.0.1";
SADSCRIPTFILENAME="sadtmp.sh";
SADSCRIPT="/var/tmp/$SADSCRIPTFILENAME"
SADSCRIPTLOGFILE="/var/tmp/$SADSCRIPTFILENAME.log";
PIDFILE="/var/tmp/$SADSCRIPTFILENAME.pid";

SADSCRIPTCODE=$'
	#!/usr/bin/env bash

	echo $$ > $1

	while [ 1 ]
	do
		readFromCard=`opensc-tool -w -a &> '$SADSCRIPTLOGFILE' && pkcs15-tool -D 2> '$SADSCRIPTLOGFILE' | md5`;
		resultFromDB=`grep $readFromCard '$DATABASE'`;

		if [ -z "$resultFromDB" ]; then
			echo "[X] DO NOT OPEN DOOR FOR [ $readFromCard ] at [ `date` ]" >> '$SADSCRIPTLOGFILE'
		else
			echo "[O] OPEN DOOR TO [ $readFromCard ] at [ `date` ]" >> '$SADSCRIPTLOGFILE'
		fi
	done
';


# 'XXX'
__ReadCardFromReader(){
	
	readFromCard=`opensc-tool -w -a &> $SADSCRIPTLOGFILE 2>&1 && pkcs15-tool -D 2> $SADSCRIPTLOGFILE | md5`;
	echo "$readFromCard";

}

__RegisterCard(){

	echo "[+] Trying to read from card...";
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

__RunSAD(){
	if [ ! -f $DATABASE ]; then
		echo "Unable to start service: Database is missing."
	else

		if [ -e $PIDFILE ]; then
			echo "Another instance (`cat $PIDFILE`) still running?"
			echo "If you are sure that no other instance is running, delete the lockfile"
			echo "'${PIDFILE}' and try again."
			echo "Aborting now..."
		else
			# Create our new lockfile:
			echo $$ > $PIDFILE

			echo "$SADSCRIPTCODE" > $SADSCRIPT;
			run="bash $SADSCRIPT $PIDFILE";
			$run &
			echo "Running pid [ $! ]";
		fi
	fi
}

__StopSAD(){
	if [ -f $PIDFILE ]; then
		kill -3 `cat $PIDFILE`;
		rm $PIDFILE;
		echo "Service stoped.";
	fi
}

__ExitSAD(){
	exit="YES";
}

__Menu(){
	cmd=(dialog --keep-tite --menu "Select an option:" 12 26 22)

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
	            echo "Hit ENTER to proceed...";
	            read
	            ;;
	        2)
	            echo "	Unregister Card";
	            __UnregisterCard
	            echo "Hit ENTER to proceed...";
	            read
	            ;;
	        3)
	            echo "	Run Service"
	            __RunSAD
	            echo "Hit ENTER to proceed...";
	            read
	            ;;
	        4)
	            echo "	Stop Service"
	            __StopSAD
	    		echo -n "Hit ENTER to proceed...";
	    		read
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

