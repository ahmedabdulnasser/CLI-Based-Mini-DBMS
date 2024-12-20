#!/bin/bash
function insert {
    local db=$1
    local tablesWithExt=$2

    select table in $tablesWithExt; do
        if [[ -n $table ]]; then
            pk=$(awk 'NR == 2' ./${db}/${table}meta | cut -d : -f 2)
            IFS=',' read -ra columns <"./${db}/${table}"
            local dataToAppend=""
            for ((i = 0; i < ${#columns[@]}; i++)); do
                local col="${columns[$i]}"
                local isOk=0
                while [[ $isOk -eq 0 ]]; do
                    echo -n "Enter value for ${col}: "
                    read cell
                    local isDTValid=$(doDTCheck "${db}" "${table}" "${col}" "${pk}" "${cell}")

                    if [[ $isDTValid -eq 1 ]]; then
                        if [[ $col == $pk ]]; then
                            local isPKValid=$(doPKCheck "${db}" "${table}" "${col}" "${pk}" "${cell}")
                            if [[ $isPKValid -eq 1 ]]; then
                                isOk=1
                            else
                                echo "Error: Primary key value must be unique"
                            fi
                        else
                            local isUniqueValid=$(doUniqueCheck "${db}" "${table}" "${col}" "${pk}" "${cell}")
                            local isNotNullValid=$(doNotNullCheck "${db}" "${table}" "${col}" "${pk}" "${cell}")

                            if [[ $isUniqueValid -eq 1 ]] && [[ $isNotNullValid -eq 1 ]]; then
                                isOk=1
                            else
                                [[ $isUniqueValid -eq 0 ]] && echo "Error: Value must be unique"
                                [[ $isNotNullValid -eq 0 ]] && echo "Error: Value cannot be null"
                            fi
                        fi
                    fi
                done

                if [[ $i -eq 0 ]]; then
                    dataToAppend="${cell}"
                else
                    dataToAppend="${dataToAppend},${cell}"
                fi
            done

            echo "${dataToAppend}" >>"./${db}/${table}"
            echo "Record successfully inserted"
            break
        else
            echo "Invalid Selection. Please choose again."
        fi
    done
}

function insertWithoutGUI {
    local db=$1
    local table=$2
    table+=".csv"
    local columns=$3
    local values=$4
    local pk=$(awk 'NR == 2' ./${db}/${table}meta | cut -d : -f 2)
    local dataToAppend=""
    local header=$(head -n 1 "./${db}/${table}")

    if [ ! -d "./${db}" ]; then
        echo "Database '${db}' does not exist '${db}'."
        return 1
    fi

    if [ ! -f "./${db}/${table}" ]; then
        echo "Table '${table}' not found in database '${db}'."
        return 1
    fi
    IFS=',' read -ra columnsArr <<<"$columns"
    IFS=',' read -ra valuesArr <<<"$values"
    IFS=',' read -ra headerColumns <<<"$header"

    if [ ${#columnsArr[@]} -ne ${#valuesArr[@]} ]; then
        echo "Number of columns and values do not match."
        return 1
    fi

    local finalValues=()
    for i in "${!headerColumns[@]}"; do
        finalValues[i]=""
    done

    for ((i = 0; i < ${#columnsArr[@]}; i++)); do
        local col="${columnsArr[$i]}"
        local cell="${valuesArr[$i]}"
        local colIdx=-1

        for j in in "${!headerColumns[@]}"; do
            if [[ "${headerColumns[$j]}" == "${col}" ]]; then
                colIdx=$j
                break
            fi
        done

        if [[ $colIdx -eq -1 ]]; then
            echo "Column '${col}' not found in table '${table}'."
            return 1
        fi

        local isDTValid=$(doDTCheck "${db}" "${table}" "${col}" "${pk}" "${cell}")
        if [[ $isDTValid -eq 1 ]]; then
            if [[ $col == $pk ]]; then
                local isPKValid=$(doPKCheck "${db}" "${table}" "${col}" "${pk}" "${cell}")
                if [[ $isPKValid -eq 0 ]]; then
                    echo "Error: Primary key value must be unique"
                    return 1
                fi
            else
                local isUniqueValid=$(doUniqueCheck "${db}" "${table}" "${col}" "${pk}" "${cell}")
                local isNotNullValid=$(doNotNullCheck "${db}" "${table}" "${col}" "${pk}" "${cell}")

                if [[ $isUniqueValid -eq 0 ]]; then
                    echo "Error: Value must be unique"
                    return 1
                fi

                if [[ $isNotNullValid -eq 0 ]]; then
                    echo "Error: Value cannot be null"
                    return 1
                fi
            fi
        else
            echo "Error: Invalid data type"
            return 1
        fi

        finalValues[$colIdx]="${cell}"
    done
    for i in "${!finalValues[@]}"; do
        if [[ $i -eq 0 ]]; then
            dataToAppend="${finalValues[$i]}"
        else
            dataToAppend="${dataToAppend},${finalValues[$i]}"
        fi
    done

    if [ ! -z "$dataToAppend" ]; then
        echo "${dataToAppend}" >>"./${db}/${table}"
        echo "Record successfully inserted"
    else
        echo "Error: Record not inserted."
    fi

}

function doDTCheck {
    local db=$1
    local table=$2
    local col=$3
    local pk=$4
    local cell=$5

    local columnTypes=$(awk 'NR == 1' ./${db}/${table}meta)
    local dataType=$(echo "$columnTypes" | awk -F':' -v col="$col" '
    {
        for(i=1; i<=NF; i++) {
            split($i, fields, ",")
            if (fields[1] == col) {
                print fields[2]
                exit
            }
        }
    }')

    case "$dataType" in
    "varchar")
        echo 1
        ;;
    "numeric")
        if [[ "$cell" =~ ^[0-9]+$ ]]; then
            echo 1
        else
            echo "Error: Invalid numeric value" >&2
            echo 0
        fi
        ;;
    "date")
        if [[ "$cell" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && date -d "$cell" >/dev/null 2>&1; then
            echo 1
        else
            echo "Error: Invalid date format (use YYYY-MM-DD)" >&2
            echo 0
        fi
        ;;
    *)
        echo "Warning: Unknown data type '$dataType'" >&2
        echo 1
        ;;
    esac
}

function doPKCheck {
    local db=$1
    local table=$2
    local col=$3
    local pk=$4
    local cell=$5

    if [[ "$col" == "$pk" ]]; then
        if [[ -z "$cell" ]]; then
            echo "Error: Primary key cannot be null" >&2
            echo 0
            return
        fi

        if grep -q "^${cell}," "./${db}/${table}" || grep -q ",${cell}," "./${db}/${table}"; then
            echo "Error: Primary key must be unique" >&2
            echo 0
        else
            echo 1
        fi
    else
        echo 1
    fi
}

function doUniqueCheck {
    local db=$1
    local table=$2
    local col=$3
    local pk=$4
    local cell=$5

    local colMeta=$(awk -F: -v col="$col" '$1 == col {print $0}' "./${db}/${table}meta")
    local isUnique=$(echo "$colMeta" | cut -d : -f 3)

    if [[ "$isUnique" == "true" ]]; then
        if grep -q "^${cell}," "./${db}/${table}" || grep -q ",${cell}," "./${db}/${table}"; then
            echo 0
        else
            echo 1
        fi
    else
        echo 1
    fi
}

function doNotNullCheck {
    local db=$1
    local table=$2
    local col=$3
    local pk=$4
    local cell=$5

    local colMeta=$(awk -F: -v col="$col" '$1 == col {print $0}' "./${db}/${table}meta")
    local isNotNull=$(echo "$colMeta" | cut -d : -f 4)

    if [[ "$isNotNull" == "true" && -z "$cell" ]]; then
        echo 0
    else
        echo 1
    fi
}
