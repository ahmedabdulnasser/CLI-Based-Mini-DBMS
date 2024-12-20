function selectFromTbl {
    db=$1
    table=$2
    column=$3
    value=$4

    if [ -z "$column" ]; then
        echo "Column name cannot be empty."
        return 1
    fi

    if [ ! -f "./${db}/${table}" ]; then
        echo "Table file './${db}/${table}' not found."
        return 1
    fi
    header=$(head -n 1 "./${db}/${table}")

    if [ "$column" = "*" ]; then
        echo "─────────────────────────"
        (
            echo "$header"
            tail -n +2 "./${db}/${table}"
        ) | column -t -s ','
        echo "─────────────────────────"
    else
        column_index=$(echo "$header" | awk -F, -v col="$column" '{
        for(i=1;i<=NF;i++) {
            if($i == col) {print i; exit}
        }
    }')
        if [ -z "$column_index" ]; then
            echo "Column '$column' not found in table '$table'."
            return 1
        fi

        echo "─────────────────────────"
        (
            # Show only header for the specific column
            echo "$header" | cut -d',' -f"$column_index"
            if [ -z "$value" ]; then
                # If no value provided, show all rows for the specific column
                tail -n +2 "./${db}/${table}" | cut -d',' -f"$column_index"
            else
                # Filter by value and show only the specific column
                awk -F, -v col="$column_index" -v val="$value" '
        NR > 1 {
            if ($col == val || val == "*") {
                print $col
            }
        }' "./${db}/${table}"
            fi
        ) | column -t -s ','
        echo "─────────────────────────"
    fi
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
