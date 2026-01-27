#!/bin/bash


db_name="$1"
DB_PATH="./databases/$db_name"
TABLES_DIR="$DB_PATH/tables"
META_DIR="$DB_PATH/metadata"


mkdir -p "$TABLES_DIR" "$META_DIR"

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

    read -p "Enter number of columns: " col_count

    if ! [[ "$col_count" =~ ^[1-9][0-9]*$ ]]; then
	    echo "Invalid number of columns!"
	    list_options
	    return
    fi

    declare -a columns
    declare -a types

    for (( i=1; i<= col_count; i++ )); do
	    read -p "Enter name for column $i: " col_name

	    if [[ ! "$col_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
		 echo "Invalid column name! Only letters, numbers, and underscore"
		 ((i--))
		 continue
	    fi
	    columns+=("$col_name")

	    read -p "Enter datatype for column '$col_name' (int/string): " dtype
	    while [[ "$dtype" != "int" && "$dtype" != "string" ]]; do
		    echo "Datatype must be 'int' or 'string'."
		    read -p "Enter datatype for column '$col_name' (int/string): " dtype
	    done
	    types+=("$dtype")
    done

    echo "Columns: ${columns[*]}"
    read -p "Choose primary key column: " pk
    if [[ ! " ${columns[*]} " =~ "$pk"  ]]; then
	echo "Primary key must be one of the columns."
        list_options
        return
    fi

    META_FILE="$META_DIR/$table_name.meta"
    echo "columns=${columns[*]}" > "$META_FILE"
    echo "types=${types[*]}" >> "$META_FILE"
    echo "primary_key=$pk" >> "$META_FILE"

    TABLE_FILE="$TABLES_DIR/$table_name"
    touch "$TABLE_FILE"

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
    echo "Not implemented yet."
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
