#!/bin/bash
unset schema
unset schemaRepresentation
declare -A schema
schemaRepresentation=""
function createTbl {
    echo "Table Name: "
    read tableName
    db=$1
    if [[ -z $tableName ]]
    then
        echo "Invalid table name. Re-enter a valid name."
        createTbl $db # Recurses till getting a valid input.
    else 
        declare -i columnsNo
        echo "Columns Number: "
        columnsNo=$(readColumns)
        #schemaOutput=$(readSchema ${columnsNo} | tee /dev/tty)
        colNames=""
        readSchema ${columnsNo}
        colNames=$(getColNames $columnsNo ",")
        PK=$(readPK ${columnsNo})
        touch ./${db}/${tableName}.csv
        touch ./${db}/${tableName}.csvmeta
        echo $colNames > ./${db}/${tableName}.csv
        echo $schemaRepresentation > ./${db}/${tableName}.csvmeta
        echo "pk:$PK" >> ./${db}/${tableName}.csvmeta
    fi
}
function readColumns {
        declare -i columnsNo
        read columnsNo
        if [[ ! $columnsNo =~ ^[1-9][0-9]*$ ]]
        then
            readColumns
        else
            echo $columnsNo
        fi
}
function readSchema {
        #declare -A schema # Array in which table schema is saved { {colName, D.T, isUnique, isNotNull}, {...}, {...}, ...}
        columnsNo=$1
        schemaRepresentation=""
        for (( i=0; i < ${columnsNo}; i++ ))
        do
            echo "Col${i} Name: "
            read colName
            if [[ -z $colName ]]
            then
                echo "Invalid Column Name."
                readSchema
            else
                schema["${i},colName"]=$colName
                #Data Type
                PS3="Column Data Type: "
                select colDataType in "numeric" "varchar" "date"
                do
                    if [[ -n $colDataType ]]
                    then
                        schema["${i},colDataType"]=$colDataType
                        break
                    else
                        echo "Invalid selection. Choose again."
                    fi
                done 
                PS3="Your choice: "
                # Uniqueness
                echo "Is $colName unique?"
                select isUnique in "true" "false"
                do
                    if [[ -n $isUnique ]]
                    then
                        schema["${i},isUnique"]=$isUnique
                        break
                    else
                        echo "Invalid selection. Choose again."
                    fi
                done 
                # Not Null
                echo "Is $colName not null?"
                select isNotNull in "true" "false"
                do
                    if [[ -n $isNotNull ]]
                    then
                        schema["${i},isNotNull"]=$isNotNull
                        break
                    else
                        echo "Invalid selection. Choose again."
                    fi               
                done 
            fi
        done
        
        for (( i=0; i<$columnsNo; i++ ))
        do
            schemaRepresentation+="${schema["${i},colName"]},${schema["${i},colDataType"]},${schema["${i},isUnique"]},${schema["${i},isNotNull"]}"
            if [[ i -lt $((${columnsNo}-1)) ]]
            then
                schemaRepresentation+=":"
            fi
        done
}
function readPK {
    colNames=""
    PS3="Primary Key: "
    columnsNo=$1
    colNames=$(getColNames $columnsNo " ")
    select PK in $colNames
    do
        if [[ -n $PK && " ${colNames[@]} " =~ " $PK " ]]
        then
            echo $PK
            break
        fi 
    done
}
function getColNames {
    colNames=""
    columnsNo=$1
    delimiter=$2
    for (( i=1; i<=${columnsNo}; i++ ))
    do
        colNames+=$(echo $schemaRepresentation | cut -d : -f "${i}" | cut -d , -f 1)
        if [[ $i -lt $columnsNo ]]
        then
            colNames+=$delimiter
        fi
    done
    echo $colNames
}