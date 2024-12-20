#!/usr/bin/bash

PS3="Your choice: "
choices=("Create Database" "List Databases" "Connect to Database" "Drop Database")
select choice in "${choices[@]}"; do
	case $REPLY in
	1)
		echo "Database name:"
		read dbname
		./createdb.sh "${dbname}DB"
		;;
	2)
		./listdb.sh
		;;
	3)
		./connecttodb.sh
		;;
	4)
		./dropdb.sh
		;;
	esac
done
