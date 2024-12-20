#!/bin/bash
source ./createtbl.sh
source ./insert.sh
source ./select.sh
source ./deletefromtbl.sh
source ./update.sh
source ./executesql.sh
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
choices=("Create Table" "List Tables" "Insert Into Table" "Select From Table" "Select All From Table" "Delete From Table" "Update Table" "Drop Table" "SQL Query" "Disconnect")
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
	4)

		tablesWithExt=$(listTables ${db} 1)
		select tbl in ${tablesWithExt}; do
			read -p "Enter column name: " column
			read -p "Enter value: " value
			selectFromTbl ${db} "${tbl}" ${column} ${value}
			break
		done
		;;
	5)
		tablesWithExt=$(listTables ${db} 1)
		select tbl in ${tablesWithExt}; do
			selectAllFromTbl ${db} "${tbl}"
			break
		done
		;;
	6)
		tablesWithExt=$(listTables ${db} 1)
		select tbl in ${tablesWithExt}; do
			read -p "Enter column name: " column
			read -p "Enter value: " value
			deleteFromTbl ${db} "${tbl}" ${column} ${value}
			break
		done
		;;
	7)
		tablesWithExt=$(listTables ${db} 1)
		select tbl in ${tablesWithExt}; do
			read -p "Enter search column name: " column
			read -p "Enter search value: " value
			read -p "Enter column name to be updated: " columnToUpdate
			read -p "Enter new value: " updateValue
			update ${db} "${tbl}" ${column} ${value} ${columnToUpdate} ${updateValue}
			break
		done
		;;
	8)
		tablesWithExt=$(listTables ${db} 1)
		select tbl in ${tablesWithExt}; do
			read -p "Are you sure you want to drop table ${tbl}? (y/n): " confirm
			if [ "$confirm" != "y" ]; then
				echo "Table ${tbl} not dropped."
			else
				rm -f "./${db}/${tbl}"
				rm -f "./${db}/${tbl}meta"
				echo "Table ${tbl} dropped."
			fi
			break
		done
		;;
	9)
		read -p "Enter SQL Query: " sql
		executeSQL "${db}" "${sql}"
		;;
	10)
		echo "Disconnected from ${db}."
		break
		;;
	esac
done
