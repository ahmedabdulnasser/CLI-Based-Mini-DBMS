#!/usr/bin/bash
source ./dbutils.sh

PS3="Your choice: "
choices=("Create Database" "List Databases" "Connect to Database" "Drop Database")
select choice in "${choices[@]}"; do
	case $REPLY in
	1)
		echo "Database name:"
		read dbname
		createDB "${dbname}DB"
		;;
	2)
		listDB
		;;
	3)
		connectToDB
		;;
	4)
		dropDB
		;;
	esac
done
