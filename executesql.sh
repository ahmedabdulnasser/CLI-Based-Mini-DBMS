#!/usr/bin/bash

PS3="Your choice: "
function executeSQL {
    local db=$1
    local sql=$2

    if [ -z "$sql" ]; then
        echo "SQL query cannot be empty."
        return 1
    fi

    if [ ! -d "./${db}" ]; then
        echo "Database '${db}' not found."
        return 1
    fi

    command=$(echo "$sql" | awk '{print tolower($1)}')
    case $command in
    "select")
        # Extract basic parts
        column=$(echo "$sql" | awk '{print $2}')
        from=$(echo "$sql" | awk '{print tolower($3)}')
        table=$(echo "$sql" | awk '{print $4 ".csv"}')
        where=$(echo "$sql" | awk '{print tolower($5)}')

        # Validate basic syntax
        if [[ -z "$column" ]] || [[ -z "$from" ]] || [[ -z "$table" ]]; then
            echo "Syntax error: Expected 'SELECT column FROM table'"
            return 1
        fi

        if [[ "$from" != "from" ]]; then
            echo "Syntax error: Expected 'FROM' keyword"
            return 1
        fi

        # Handle WHERE clause if present
        if [[ "$where" == "where" ]]; then
            condition=$(echo "$sql" | awk '{print $6}')
            conditionColumn=$(echo "$condition" | awk -F= '{print $1}')
            value=$(echo "$condition" | awk -F= '{print $2}')
            selectFromTbl "$db" "$table" "$conditionColumn" "$value"
        else
            selectFromTbl "$db" "$table" "$column" "*"
        fi
        ;;
    "update")
        table=$(echo "$sql" | awk '{print $2 ".csv"}')
        set=$(echo "$sql" | awk '{print tolower($3)}')
        update_pair=$(echo "$sql" | cut -d' ' -f4)
        where=$(echo "$sql" | awk '{print tolower($5)}')
        condition=$(echo "$sql" | cut -d' ' -f6)

        if [[ -z "$table" ]] || [[ "$set" != "set" ]] || [[ -z "$update_pair" ]] || [[ "$where" != "where" ]] || [[ -z "$condition" ]]; then
            echo "Syntax error in UPDATE statement."
            return 1
        fi

        if [ ! -f "./${db}/${table}" ]; then
            echo "Table '${table}' not found in database '${db}'."
            return 1
        fi

        columntoUpdate=$(echo "$update_pair" | awk -F= '{print $1}')
        updateValue=$(echo "$update_pair" | awk -F= '{print $2}')
        conditionColumn=$(echo "$condition" | awk -F= '{print $1}')
        conditionValue=$(echo "$condition" | awk -F= '{print $2}')

        update "$db" "$table" "$conditionColumn" "$conditionValue" "$columntoUpdate" "$updateValue"
        ;;

    "delete")
        from=$(echo "$sql" | awk '{print tolower($2)}')
        table=$(echo "$sql" | awk '{print $3 ".csv"}')
        where=$(echo "$sql" | awk '{print tolower($4)}')
        condition=$(echo "$sql" | awk '{print $5}')
        conditionColumn=$(echo "$condition" | awk -F= '{print $1}')
        value=$(echo "$condition" | awk -F= '{print $2}')

        if [ -z "$from" ] || [ -z "$table" ] || [ -z "$where" ] || [[ ! "$from" == "from" ]] || [[ ! "$where" == "where" ]]; then
            echo "Syntax error in DELETE statement."
            return 1
        fi

        if [ ! -f "./${db}/${table}" ]; then
            echo "Table '${table}' not found in database '${db}'."
            return 1
        fi

        deleteFromTbl "${db}" "${table}" "${conditionColumn}" "${value}"
        ;;
    "drop")
        table=$(echo "$sql" | awk '{print $2 ".csv"}')
        if [ -z "$table" ]; then
            echo "Syntax error in DROP statement."
            return 1
        fi

        if [ ! -f "./${db}/${table}" ]; then
            echo "Table '${table}' not found in database '${db}'."
            return 1
        fi

        read -p "Are you sure you want to drop table ${table}? (y/n): " confirm
        if [ "$confirm" != "y" ]; then
            echo "Table ${table} not dropped."
        else
            rm -f "./${db}/${table}"
            rm -f "./${db}/${table}meta"
            echo "Table ${table} dropped."
        fi
        ;;

    "insert")
        into=$(echo "$sql" | awk '{print tolower($2)}')
        table=$(echo "$sql" | awk '{print $3}')
        columnsInserted=$(echo "$sql" | awk '{print $4}')
        columns=$(echo "$columnsInserted" | cut -d'(' -f2 | cut -d')' -f1)
        valuesKeyword=$(echo "$sql" | awk '{print tolower($5)}')
        valuesInserted=$(echo "$sql" | awk '{print $6}')
        values=$(echo "$valuesInserted" | cut -d'(' -f2 | cut -d')' -f1)

        if [ -z "$into" ] || [ -z "$table" ] || [ -z "$columns" ] || [ -z "$values" ] || [ -z "$valuesKeyword" ] || [[ ! "$into" == "into" ]] || [[ ! "$valuesKeyword" == "values" ]]; then
            echo "Syntax error in INSERT statement."
            return 1
        fi

        insertWithoutGUI "${db}" "${table}" "${columns}" "${values}"
        ;;

    esac

}
