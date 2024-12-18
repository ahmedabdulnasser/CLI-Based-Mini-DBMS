#!/bin/bash
dbList=$(./listdb.sh)
if [[ -z $dbList ]]; then
	echo "No databases exist."
else
	echo "Select a database to connect to"
	select db in $dbList; do
		echo "Connected to ${db}."
		./showconnectionmenu.sh "${db}"
		break
	done
fi
