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
    echo "Not implemented yet."
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
