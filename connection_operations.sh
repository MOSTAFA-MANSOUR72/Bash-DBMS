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
    echo "7) Update Table"
    echo "8) Back to Main Menu"
    read -p "Choose an option: " choice
    echo ""
    case $choice in 
        1) create_table  ;;
        2) list_tables  ;;
        3) drop_table  ;;
        4) insert_into_table  ;;
        5) select_from_table  ;;
        6) delete_from_table  ;;
        7) update_table  ;;
        8) main_menu ;;
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
    echo "Not implemented yet."
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
    echo "Not implemented yet."
    list_options 
}

function delete_from_table() {
    echo "Not implemented yet."
    list_options 
}

function update_table() {
    echo "Not implemented yet."
    list_options 
}


list_options
