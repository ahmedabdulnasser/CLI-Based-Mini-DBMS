#!/bin/bash
source ./createtbl.sh
db="$1"
choices=( "Create Table" "List Tables" "Insert Into Table" "Select From Table" "Delete From Table" "Update Table" "Disconnect")
PS3="Your choice: "
select choice in "${choices[@]}"
do
	case $REPLY in
		1)
			createTbl ${db}
			;;
		2)	
			for file in ./${db}/*.csv
			do
			basename "$file" .csv
			done
			;;



		7)
			echo "Disconnected from ${db}."
			break
			;;
	esac
done
