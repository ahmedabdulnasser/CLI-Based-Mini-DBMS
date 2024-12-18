#!/usr/bin/bash
echo "Name of the DB you'd like to delete:"
read dbName
if [[ -d "$dbName" && "$dbName" == *DB ]]
then
	echo "Are you sure that you want to delete ${dbName}? [Y-N]"
	read agreement
	case $agreement in
		yes|y|Y)
			rm -rf $dbName
			;;
		*)
			echo "Operation cancelled."
			;;
	esac
else
	echo "This database does not exist."
fi

