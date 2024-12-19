function selectFromTbl {
    db=$1
    table=$2
    column=$3
    value=$4

    if [ -z "$column" ] || [ -z "$value" ]; then
        echo "Column name and value cannot be empty."
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
        column_index=$(echo "$header" | awk -F, -v col="$column" '{
            for(i=1;i<=NF;i++) {
                if($i == col) {print i; exit}
            }
        }')
    fi

    if [ -z "$column_index" ]; then
        echo "Column '$column' not found in table '$table'."
        return 1
    fi

    echo "─────────────────────────"
    (
        echo "$header"
        awk -F, -v col="$column_index" -v val="$value" '
    NR > 1 {
        if (col == "*") {
            # If column is *, check all fields
            for (i=1; i<=NF; i++) {
                if (val == "*" || $i ~ "^" val "$" || val ~ /\*/ && $i ~ val) {
                    print $0
                    break
                }
            }
        } else {
            # Check specific column
            if (val == "*" || $col ~ "^" val "$" || val ~ /\*/ && $col ~ val) {
                print $0
            }
        }
    }' "./${db}/${table}"
    ) | column -t -s ','
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
