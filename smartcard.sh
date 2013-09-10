#!/usr/bin/env bash

DATABASE="./smartcard.db";
VERSION="v0.0.1";

__LoadAndCheckCard(){
	echo "Reading card...";

	if [ ! -f $DATABASE ]; then
		echo "Database does not exist, create? Y/n";
		read
	else
		echo "Loading database...";
		echo "Checking if card exists in database...";
	fi


}

__RegisterCard(){

	__LoadAndCheckCard

	# if($exists){
		echo "Card already registered...";
	# }else{
		echo "Registering card...";
	# }
	echo "Card Registered."
	#done

}

__UnregisterCard(){

	__LoadAndCheckCard

	# if(exists){
		echo "Unregistering card...";
		echo "Card's unregistered.";
	# }else{
		echo "Card was not registered beforehand.";
	# }

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
	            __RegisterCard
	            ;;
	        2)
	            echo "Unregister card"
	            __UnregisterCard
	            ;;
	        3)
	            echo "Run Service"
	            ;;
	        4)
	            echo "Exit"
	            ;;
	        5)
	            echo "Exit"
	            ;;
	    esac
	done;
}


__Main(){
	echo "+======== SMARTCARD MANAGER $VERSION ========+";
	__Menu
}

# Main part
__Main