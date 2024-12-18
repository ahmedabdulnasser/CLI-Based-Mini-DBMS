#!/usr/bin/bash
choice1="Create Database"
choice2="List Databases"
choice3="Connect to Database"
choice4="Drop Database"
PS3="Your choice: "
select choice in "$choice1" "$choice2" "$choice3" "$choice4"; do
	case $choice in
	$choice1)
		echo "Database name:"
		read dbname
		./createdb.sh "${dbname}DB"
		;;
	$choice2)
		./listdb.sh
		;;
	$choice3)
		./connecttodb.sh
		;;
	$choice4)
		./dropdb.sh
		;;
	esac
done
