#!/bin/bash
source ./createtbl.sh
source ./insert.sh
function listTables {
	local db=$1
	local withExtension=${2:-0}
	for file in ./${db}/*.csv; do
		if [[ $withExtension -eq 1 ]]; then
			basename "$file"
		else
			basename "$file" .csv
		fi
	done
}
db="$1"
choices=("Create Table" "List Tables" "Insert Into Table" "Select From Table" "Delete From Table" "Update Table" "Disconnect")
PS3="Your choice: "
select choice in "${choices[@]}"; do
	case $REPLY in
	1)
		createTbl ${db}
		;;
	2)
		listTables ${db}
		;;
	3)
		tablesWithExt=$(listTables ${db} 1)
		insert ${db} "${tablesWithExt}"
		;;

	7)
		echo "Disconnected from ${db}."
		break
		;;
	esac
done
