function selectFromTbl {
    db=$1
    table=$2
    column=$3
    value=$4
    displayedColumns=$5

    if [ -z "$column" ]; then
        echo "Column name cannot be empty."
        return 1
    fi

    if [ ! -f "./${db}/${table}" ]; then
        echo "Table file './${db}/${table}' not found."
        return 1
    fi

    header=$(head -n 1 "./${db}/${table}")
    IFS=',' read -ra headerArr <<<"$header"

    if [ "$column" != "*" ]; then
        column_index=$(echo "$header" | awk -F, -v col="$column" '{
            for(i=1;i<=NF;i++) {
                if($i == col) {print i; exit}
            }
        }')

        if [ -z "$column_index" ]; then
            echo "Column '$column' not found in table '$table'."
            return 1
        fi
    fi

    local displayIndices=()
    if [ "$displayedColumns" = "*" ] || [ -z "$displayedColumns" ]; then
        for i in "${!headerArr[@]}"; do
            displayIndices+=($i)
        done
    else
        IFS=',' read -ra displayArr <<<"$displayedColumns"
        for col in "${displayArr[@]}"; do
            local found=0
            for i in "${!headerArr[@]}"; do
                if [ "${headerArr[$i]}" = "$col" ]; then
                    displayIndices+=($i)
                    found=1
                    break
                fi
            done
            if [ $found -eq 0 ]; then
                echo "Column '$col' not found in table"
                return 1
            fi
        done
    fi

    echo "─────────────────────────"
    local headerLine=""
    for i in "${displayIndices[@]}"; do
        if [ -z "$headerLine" ]; then
            headerLine="${headerArr[$i]}"
        else
            headerLine="${headerLine},${headerArr[$i]}"
        fi
    done
    echo "$headerLine" | column -t -s ','

    if [ "$column" = "*" ]; then
        tail -n +2 "./${db}/${table}" | while IFS=, read -r -a line; do
            local lineToPrint=""
            for i in "${displayIndices[@]}"; do
                if [ -z "$lineToPrint" ]; then
                    lineToPrint="${line[$i]}"
                else
                    lineToPrint="${lineToPrint},${line[$i]}"
                fi
            done
            echo "$lineToPrint" | column -t -s ','
        done
    else
        awk -F, -v col="$column_index" -v val="$value" '
        NR > 1 {
            if ($col == val || val == "*") {
                print $0
            }
        }' "./${db}/${table}" | cut -d',' -f"$(
            IFS=,
            # Increment each index by 1 since cut uses 1-based indexing
            for i in "${displayIndices[@]}"; do
                echo -n "$((i + 1)),"
            done | sed 's/,$//'
        )" | column -t -s ','
    fi
    echo "─────────────────────────"
}
function selectAllFromTbl {
    db=$1
    table=$2

    if [ ! -f "./${db}/${table}" ]; then
        echo "Table file './${db}/${table}' not found."
        return 1
    fi
    echo "─────────────────────────"
    header=$(head -n 1 "./${db}/${table}")
    echo "$header" | column -t -s ','
    tail -n +2 "./${db}/${table}" | column -t -s ','
    echo "─────────────────────────"

}

function selectWithCondition {
    db=$1
    table=$2
    column=$3
    value=$4
    conditionColumn=$5
    conditionValue=$6

    if [ -z "$column" ] || [ -z "$conditionColumn" ] || [ -z "$conditionValue" ]; then
        echo "Column name cannot be empty."
        return 1
    fi

    if [ ! -f "./${db}/${table}" ]; then
        echo "Table file './${db}/${table}' not found."
        return 1
    fi

    header=$(head -n 1 "./${db}/${table}")
    if [ "$column" = "*" ]; then
        echo "$header"
        tail -n +2 "./${db}/${table}"
    else
        if [ -z "$value"]; then
            awk -F, -v col="$column" '
        NR > 1 {
            if ($col == val) {
                print $0
            }
        }' "./${db}/${table}"
        else

            column_index=$(echo "$header" | awk -F, -v col="$column" '{
            for(i=1;i<=NF;i++) {
                if($i == col) {print i; exit}
            }
        }')
        fi
    fi

    if [ -z "$column_index" ]; then
        echo "Column '$column' not found in table '$table'."
        return 1
    fi

    echo "─────────────────────────"
    (
        echo "$header"
        awk -F, -v col="$column_index" -v val="$value" -v condCol="$conditionColumn" -v condVal="$conditionValue" '
    NR > 1 {
        if (col == "*") {
            # If column is *, check all fields
            for (i=1; i<=NF; i++) {
                if (val == "*" || $i ~ "^" val "$" || val ~ /\*/ && $i ~ val) {
                    if (condCol == "*" || $i ~ "^" condVal "$" || condVal ~ /\*/ && $i ~ condVal) {
                        print $0
                        break
                    }
                }
            }
        } else {
            # Check specific column
            if (val == "*" || $col ~ "^" val "$" || val ~ /\*/ && $col ~ val) {
                if (condCol == "*" || $col ~ "^" condVal "$" || condVal ~ /\*/ && $col ~ condVal) {
                    print $0
                }
            }
        }
    }
    ' "./${db}/${table}"
    ) | column -t -s ','
}
