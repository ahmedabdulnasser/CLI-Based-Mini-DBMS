#!/usr/bin/bash
source ./showconnectionmenu.sh
function createDB {
	if [ -z $1 ]; then
		echo "You cannot leave the DB name field empty."
	else
		if [ -d $1 ]; then
			echo A database called $1 already exists.
		else
			mkdir $1
		fi
	fi
}

function listDB {
	find . -type d -name "*DB" | cut -d/ -f2
}

function dropDB {
	echo "Name of the DB you'd like to delete:"
	read dbName
	if [[ -d "$dbName" && "$dbName" == *DB ]]; then
		echo "Are you sure that you want to delete ${dbName}? [Y-N]"
		read agreement
		case $agreement in
		yes | y | Y)
			rm -rf $dbName
			;;
		*)
			echo "Operation cancelled."
			;;
		esac
	else
		echo "This database does not exist."
	fi

}
function connectToDB {
	PS3="Your choice: "
	dbList=$(listDB)
	if [[ -z $dbList ]]; then
		echo "No databases exist."
	else
		echo "Select a database to connect to"
		select db in $dbList; do
			echo "Connected to ${db}."
			showMenu "${db}"
			break
		done
	fi
}
