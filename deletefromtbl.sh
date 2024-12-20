function deleteFromTbl {
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

    column_index=$(head -n 1 "./${db}/${table}" | awk -F, -v col="$column" '{
        for(i=1;i<=NF;i++) {
            if($i == col) {print i; exit}
        }
    }')

    if [ -z "$column_index" ]; then
        echo "Column '$column' not found in table '$table'."
        return 1
    fi

    temp_file=$(mktemp)
    head -n 1 "./${db}/${table}" >"$temp_file"
    awk -F, -v col="$column_index" -v val="$value" '
        NR > 1 {
            if ($col != val) {
                print $0
            }
        }
    ' "./${db}/${table}" >>"$temp_file"

    mv "$temp_file" "./${db}/${table}"
    rm -rf "$temp_file"

    echo "Row with $column=$value deleted from table $table."
}
