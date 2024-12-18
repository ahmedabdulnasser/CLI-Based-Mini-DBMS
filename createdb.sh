#!/usr/bin/bash

if [ -z $1 ]
then
 	echo "You cannot leave the DB name field empty."
else
	if [ -d $1 ]
	then
		echo A database called $1 already exists.
	else
		mkdir $1
	fi
fi

