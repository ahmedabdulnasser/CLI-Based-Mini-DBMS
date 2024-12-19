function update {
    db=$1
    table=$2
    column=$3
    value=$4
    columnToUpdate=$5
    updateValue=$6

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

    doesValueExist=$(awk -F, -v col="$column_index" -v val="$value" '
        NR > 1 {
            if ($col == val) {
                print "true"
                exit
            }
        }' "./${db}/${table}")

    if [ -z "$doesValueExist" ]; then
        echo "Row with $column=$value not found in table $table."
        return 1
    fi

    columnToUpdate_index=$(head -n 1 "./${db}/${table}" | awk -F, -v col="$columnToUpdate" '{
        for(i=1;i<=NF;i++) {
            if($i == col) {print i; exit}
        }
    }')

    if [ -z "$columnToUpdate_index" ]; then
        echo "Column '$columnToUpdate' not found in table '$table'."
        return 1
    fi

    temp_file=$(mktemp)
    head -n 1 "./${db}/${table}" >"$temp_file"
    awk -F, -v OFS=, -v col="$column_index" -v val="$value" -v colToUpdate="$columnToUpdate_index" -v updateVal="$updateValue" '
        NR > 1 {
            if ($col == val) {
                $colToUpdate = updateVal
            }
            print $0
        }

' "./${db}/${table}" >>"$temp_file"

    mv "$temp_file" "./${db}/${table}"
    rm -rf "$temp_file"

    echo "Rows with $column=$value updated in table $table."
}
