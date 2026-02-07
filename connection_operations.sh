#!/bin/bash


db_name="$1"
DB_PATH="./databases/$db_name"
TABLES_DIR="$DB_PATH/tables"


mkdir -p "$TABLES_DIR"

function list_options() {
    echo ""
    echo "====== Database Operations on $db_name ======"
    echo "1) Create Table"
    echo "2) List Tables"
    echo "3) Drop Table"
    echo "4) Insert into Table"
    echo "5) Select from Table"
    echo "6) Delete from Table"
    echo "7) Alter Table"
    echo "8) Update Table"
    echo "9) Back to Main Menu"
    read -p "Choose an option: " choice
    echo ""
    case $choice in 
        1) create_table  ;;
        2) list_tables  ;;
        3) drop_table  ;;
        4) insert_into_table  ;;
        5) select_from_table  ;;
        6) delete_from_table  ;;
        7) alter_table  ;;
        8) update_table  ;;
        9) main_menu ;;
        *) echo "Invalid option"; list_options  ;;
    esac 
}

function create_table() {
    read -p "Enter table name: " table_name

    if [[ ! "$table_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
	    echo "Invalid table name! Only letters, numbers, and underscores allowed."
            list_options
	   return
    fi

    if [[ -f "$TABLES_DIR/$table_name" ]]; then
	  echo "Table '$table_name' already exists!"
	  list_options
	 return
    fi 


    declare -a columns
    declare -a types

    while true; do
        read -p "Enter name for column $i: " col_name

	    if [[ ! "$col_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
		 echo "Invalid column name! Only letters, numbers, and underscore"
		 continue
	    fi
        
        if [[ " ${columns[*]} " =~ " $col_name " ]]; then
            echo "Column '$col_name' already exists. Choose a different name."
            continue
        fi 

	    columns+=("$col_name")

	    read -p "Enter datatype for column '$col_name' (number/string): " dtype

	    while [[ "$dtype" != "number" && "$dtype" != "string" ]]; do
		    echo "Datatype must be 'number' or 'string'."
		    read -p "Enter datatype for column '$col_name' (number/string): " dtype
	    done

	    types+=("$dtype")
	    
        read -p "Add another column? (y/n): " ans
        if [[ "$ans" != "y" ]]; then
            break
        fi
    done

    echo "Columns: ${columns[*]}"
    read -p "Choose primary key column: " pk
    
    #loop until the pk entered is one of the columns in columns array
    while [[ ! " ${columns[*]} " =~ " $pk " ]]; do
        echo "Primary key must be one of the defined columns."
        read -p "Choose primary key column: " pk
    done
    
    TABLE_DIR="$TABLES_DIR/$table_name"
    TABLE_FILE="$TABLE_DIR/$table_name"
    META_FILE="$TABLE_DIR/meta.meta"

    mkdir -p "$TABLE_DIR"
    touch "$TABLE_FILE"
    touch "$META_FILE"

    echo "columns=${columns[*]}" > "$META_FILE"
    echo "types=${types[*]}" >> "$META_FILE"
    echo "primary_key=$pk" >> "$META_FILE"

    echo "Table '$table_name' created successfully."
    list_options    
}

function list_tables() {
    echo "Tables in database '$db_name':"
    if [ -z "$(ls -A "$TABLES_DIR")" ]; then
	    echo "No tables found."
    else
	    ls -1 "$TABLES_DIR"
    fi
    list_options
}

function drop_table() {
    read -p "Enter table name to drop: " table_name
    TABLE_DIR="$TABLES_DIR/$table_name"
    if [[ ! -d "$TABLE_DIR" ]]; then
        echo "Table '$table_name' does not exist!"
        list_options
        return
    fi
    echo "Are you sure you want to drop table '$table_name'? This action cannot be undone."
    read -p "Confirm (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        rm -rf "$TABLE_DIR"
        echo "Table '$table_name' dropped successfully."
    else
        echo "Table '$table_name' was not dropped."
    fi
    list_options 
}

function insert_into_table() {
    read -p "Enter table name to insert into: " table_name
    if [[ ! -f "$TABLES_DIR/$table_name/$table_name" ]]; then
        echo "Table '$table_name' does not exist!"
        list_options
        return
    fi

    meta_file="$TABLES_DIR/$table_name/meta.meta"
    TABLE_FILE="$TABLES_DIR/$table_name/$table_name"

    col_line=$(grep "^columns=" "$meta_file")
    type_line=$(grep "^types=" "$meta_file")
    pk_line=$(grep "^primary_key=" "$meta_file")


    COL_NUM=$(echo "$col_line" | cut -d'=' -f2 | wc -w)
    TYPES=($(echo "$type_line" | cut -d'=' -f2))
    COL_NAMES=($(echo "$col_line" | cut -d'=' -f2))

    PRIMARY_KEY=$(echo "$pk_line" | cut -d'=' -f2)

    declare -a values

    for (( i=0; i<COL_NUM; i++ )); do
        col_name=${COL_NAMES[i]}
        col_type=${TYPES[i]}
        while true; do
            read -p "Enter value for column '$col_name' (type: $col_type): " value
            if [[ "$col_type" == "number" ]]; then
                if ! [[ "$value" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
                    echo "Invalid input! Please enter a valid number."
                    continue
                fi
            fi
            
            if [[ "$col_name" == "$PRIMARY_KEY" ]]; then
                if grep -q "^$value\b" "$TABLE_FILE"; then
                    echo "Primary key violation! Value '$value' for column '$col_name' already exists."
                    continue
                fi
            fi

            values+=("$value")
            break
        done
    done

    echo "${values[*]}" >> "$TABLE_FILE"
    echo "Record inserted successfully into table '$table_name'."
    list_options 
}

function select_from_table() {
    read -p "Enter table name to select from: " table_name

    TABLE_FILE="$TABLES_DIR/$table_name/$table_name"
    META_FILE="$TABLES_DIR/$table_name/meta.meta"

    if [[ ! -f "$TABLE_FILE" ]]; then
	    echo "Table '$table_name' does not exists!"
            list_options
	    return
    fi

    COL_NAMES=($(grep "^columns=" "$META_FILE" | cut -d'=' -f2))

    echo ""
    echo "1) Select all columns"
    echo "2) Select specific columns"
    read -p "Choose option: " opt
    echo ""

    if [[ "$opt" == "1" ]]; then
	   printf "%-15s" "${COL_NAMES[@]}"
	   echo
	   echo "-------------------------------------------"

	   awk '{
	        for(i=1;i<=NF;i++) printf "%-15s", $i;
		print ""
	    }' "$TABLE_FILE"
    elif [[ "$opt" == "2" ]]; then
        echo "Available columns: ${COL_NAMES[*]}"
        read -p "Enter column names separated by space: " selected_cols
        
	declare -a indexes=()

        for col in $selected_cols; do
	    found=false	
	    for i in "${!COL_NAMES[@]}"; do
	        if [[ "${COL_NAMES[$i]}" == "$col" ]]; then
	            indexes+=($((i+1)))
		    found=true
		    break
                fi
            done

	    if [[ "$found" == false ]]; then
		    echo "Column '$col' does not exist!"
		    list_options
		    return
	    fi	    
        done
        

        for idx in "${indexes[@]}"; do
	    printf "%-15s" "${COL_NAMES[$((idx-1))]}"
        done
        echo
        echo "-------------------------------------------"
        
        awk -v idxs="${indexes[*]}" '
	BEGIN{
            n =  split(idxs, arr, " ")
        }
	{
	    for(i=1;i<=n;i++){
		 printf "%-15s", $arr[i]
	    }
	    print ""
        }' "$TABLE_FILE"    
    else
	echo "Invalid option!"
    fi
    list_options
}    


function delete_from_table() {
    read -p "Enter table name to delete from: " table_name

    TABLE_FILE="$TABLES_DIR/$table_name/$table_name"
    META_FILE="$TABLES_DIR/$table_name/meta.meta"

    if [[ ! -f "$TABLE_FILE" ]]; then
        echo "Table '$table_name' does not exist!"
        list_options
        return
    fi

    # ===== Helper function to trim whitespace/newline =====
    trim() {
        local var="$*"
        var="${var#"${var%%[![:space:]]*}"}"  # remove leading spaces
        var="${var%"${var##*[![:space:]]}"}"  # remove trailing spaces
        echo -n "$var"
    }

    # ===== Read metadata safely =====
    PRIMARY_KEY=$(awk -F= '$1=="primary_key"{print $2}' "$META_FILE")
    PRIMARY_KEY=$(trim "$PRIMARY_KEY")

    COL_NAMES=()
    read -r cols_line < <(awk -F= '$1=="columns"{print $2}' "$META_FILE")
    for col in $cols_line; do
        COL_NAMES+=("$(trim "$col")")
    done

    # ===== Find primary key index =====
    PK_INDEX=0
    for i in "${!COL_NAMES[@]}"; do
        if [[ "${COL_NAMES[$i]}" == "$PRIMARY_KEY" ]]; then
            PK_INDEX=$((i+1))
            break
        fi
    done

    if [[ $PK_INDEX -eq 0 ]]; then
        echo "Primary key not found in metadata!"
        list_options
        return
    fi

    # ===== Ask for primary key value =====
    read -p "Enter primary key value to delete: " pk_value

    # ===== Check if record exists =====
    if ! awk -v pk="$pk_value" -v idx="$PK_INDEX" '$idx == pk {found=1} END{exit !found}' "$TABLE_FILE"; then
        echo "Record with primary key '$pk_value' not found!"
        list_options
        return
    fi

    # ===== Confirm deletion =====
    read -p "Are you sure you want to delete this record? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "Delete cancelled."
        list_options
        return
    fi

    # ===== Delete the record =====
    awk -v pk="$pk_value" -v idx="$PK_INDEX" '$idx != pk { print }' "$TABLE_FILE" > "$TABLE_FILE.tmp" && mv "$TABLE_FILE.tmp" "$TABLE_FILE"

    echo "Record deleted successfully."
    list_options
}


function alter_table() {
    # ===== Helper function to trim whitespace/newline =====
    trim() {
        local var="$*"
        var="${var#"${var%%[![:space:]]*}"}"  # remove leading spaces
        var="${var%"${var##*[![:space:]]}"}"  # remove trailing spaces
        echo -n "$var"
    }

    read -p "Enter table name: " table_name
    TABLE_DIR="$TABLES_DIR/$table_name"
    TABLE_FILE="$TABLE_DIR/$table_name"
    META_FILE="$TABLE_DIR/meta.meta"

    if [[ ! -f "$META_FILE" ]]; then
        echo "Table '$table_name' does not exist."
        list_options
        return
    fi

    # Read columns and types
    columns_line=$(grep '^columns=' "$META_FILE")
    types_line=$(grep '^types=' "$META_FILE")
    columns=(${columns_line#columns=})
    types=(${types_line#types=})

    
    echo "Choose operation:"
    echo "1) Add column"
    echo "2) Delete column"
    echo "3) Update column datatype"
    read -p "Enter option: " op

    case $op in
        1)
            echo "Columns: ${columns[*]}"
            read -p "Enter new column name: " new_col
            if [[ " ${columns[*]} " =~ " $new_col " ]]; then
                echo "Column already exists."
                list_options
                return
            fi

            read -p "Enter datatype for '$new_col' (number/string): " new_type
            while [[ "$new_type" != "number" && "$new_type" != "string" ]]; do
                echo "Datatype must be 'number' or 'string'."
                read -p "Enter datatype for '$new_col' (number/string): " new_type
            done
            columns+=("$new_col")
            types+=("$new_type")

            # Update meta file
            sed -i "s/^columns=.*/columns=${columns[*]}/" "$META_FILE"
            sed -i "s/^types=.*/types=${types[*]}/" "$META_FILE"

            # Add null to all rows
            awk -v OFS=" " '{print $0, "null"}' "$TABLE_FILE" > "$TABLE_FILE.tmp" && mv "$TABLE_FILE.tmp" "$TABLE_FILE"
            echo "Column '$new_col' added."
            ;;
        2)
            echo "Columns: ${columns[*]}"
            read -p "Enter column name to delete: " del_col
            
            PRIMARY_KEY=$(awk -F= '$1=="primary_key"{print $2}' "$META_FILE")
            PRIMARY_KEY=$(trim "$PRIMARY_KEY")
            if [[ "$del_col" == "$PRIMARY_KEY" ]]; then
                echo "Cannot delete primary key column."
                list_options
                return
            fi

            idx=-1
            for i in "${!columns[@]}"; do
                if [[ "${columns[$i]}" == "$del_col" ]]; then
                    idx=$i
                    break
                fi
            done
            if [[ $idx -eq -1 ]]; then
                echo "Column not found."
                list_options
                return
            fi
            unset 'columns[idx]'
            unset 'types[idx]'

            columns=("${columns[@]}")
            types=("${types[@]}")
            sed -i "s/^columns=.*/columns=${columns[*]}/" "$META_FILE"
            sed -i "s/^types=.*/types=${types[*]}/" "$META_FILE"
            # Remove column from all rows
            awk -v del_idx=$((idx+1)) '{for(i=1;i<=NF;i++) if(i!=del_idx) printf $i (i<NF?OFS:""); print ""}' "$TABLE_FILE" > "$TABLE_FILE.tmp" && mv "$TABLE_FILE.tmp" "$TABLE_FILE"
            echo "Column '$del_col' deleted."
            ;;
        3)
            echo "Columns: ${columns[*]}"
            read -p "Enter column name to update datatype: " upd_col

            PRIMARY_KEY=$(awk -F= '$1=="primary_key"{print $2}' "$META_FILE")
            PRIMARY_KEY=$(trim "$PRIMARY_KEY")
            if [[ "$upd_col" == "$PRIMARY_KEY" ]]; then
                echo "Cannot update datatype of primary key column."
                list_options
                return
            fi

            idx=-1
            for i in "${!columns[@]}"; do
                if [[ "${columns[$i]}" == "$upd_col" ]]; then
                    idx=$i
                    break
                fi
            done

            if [[ $idx -eq -1 ]]; then
                echo "Column not found."
                list_options
                return
            fi

            read -p "Enter new datatype (number/string): " new_type
            while [[ "$new_type" != "number" && "$new_type" != "string" ]]; do
                echo "Datatype must be 'number' or 'string'."
                read -p "Enter new datatype (number/string): " new_type
            done
            
            types[$idx]="$new_type"
            sed -i "s/^types=.*/types=${types[*]}/" "$META_FILE"
            # Set all values in that column to null
            awk -v upd_idx=$((idx+1)) '{for(i=1;i<=NF;i++) if(i==upd_idx) printf "null" (i<NF?OFS:""); else printf $i (i<NF?OFS:""); print ""}' "$TABLE_FILE" > "$TABLE_FILE.tmp" && mv "$TABLE_FILE.tmp" "$TABLE_FILE"
            echo "Datatype for '$upd_col' updated and all values set to null."
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
    list_options
}

function update_table() {
    read -p "Enter table name to update: " table_name

    TABLE_FILE="$TABLES_DIR/$table_name/$table_name"
    META_FILE="$TABLES_DIR/$table_name/meta.meta"

    if [[ ! -f "$TABLE_FILE" ]]; then
        echo "Table '$table_name' does not exist!"
        list_options
        return
    fi

    # ===== Helper function to trim whitespace/newline =====
    trim() {
        local var="$*"
        var="${var#"${var%%[![:space:]]*}"}"  # remove leading spaces
        var="${var%"${var##*[![:space:]]}"}"  # remove trailing spaces
        echo -n "$var"
    }

    # ===== Read metadata safely =====
    PRIMARY_KEY=$(awk -F= '$1=="primary_key"{print $2}' "$META_FILE")
    PRIMARY_KEY=$(trim "$PRIMARY_KEY")

   # Read columns and types
    columns_line=$(grep '^columns=' "$META_FILE")
    types_line=$(grep '^types=' "$META_FILE")
    columns=(${columns_line#columns=})
    types=(${types_line#types=})


    # ===== Ask for primary key value =====
    read -p "Enter primary key value to update: " pk_value

    # ===== Check if record exists =====
    if ! awk -v pk="$pk_value" '$1 == pk {found=1} END{exit !found}' "$TABLE_FILE"; then
        echo "Record with primary key '$pk_value' not found!"
        list_options
        return
    fi

    # ===== Ask which column to update =====
    while true; do
        echo "Columns: ${columns[*]}"
        read -p "Enter column name to update: " upd_col

        if [[ "$upd_col" == "$PRIMARY_KEY" ]]; then
            echo "Cannot update primary key column."
            continue
        fi

        idx=-1
        for i in "${!columns[@]}"; do
            if [[ "${columns[$i]}" == "$upd_col" ]]; then
                idx=$i
                break
            fi
        done

        if [[ $idx -eq -1 ]]; then
            echo "Column not found."
            continue
        fi

        read -p "Enter new value for '$upd_col': " new_value

        # Validate datatype
        col_type=${types[$idx]}
        if [[ "$col_type" == "number" ]]; then
            if ! [[ "$new_value" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
                echo "Invalid input! Please enter a valid number."
                continue
            fi
        fi

        # Update the column of index idx  the record  with (id)primary key pk_value to new_value using begin body end
        awk -v pk="$pk_value" -v idx=$((idx+1)) -v new_val="$new_value" -v OFS=" " '{
            if($1 == pk) {
                $idx = new_val 
            }
            print
        }' "$TABLE_FILE" > "$TABLE_FILE.tmp" && mv "$TABLE_FILE.tmp" "$TABLE_FILE"

        echo "Record updated successfully."
        break
    done
    list_options
}


list_options
