#!/bin/bash

DB_DIR="./databases"

mkdir -p "$DB_DIR"


function main_menu() {
	echo ""
	echo "====== Bash DBMS ======"
	echo "1) Create Database"
	echo "2) List Database"
	echo "3) Connect To Database"
	echo "4) Drop Database"
	echo "5) Exit"
	read -p "Choose an option: " choice
	echo ""
	case $choice in 
		1) create_database ;;
		2) list_database ;;
		3) connect_database ;;
		4) drop_database ;;
		5) exit 0 ;;
		*) echo "Invalid option"; main_menu ;;
	esac	
}


function create_database() {
	read -p "Enter database name: " db_name

	if [[ ! "$db_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
		echo "Invalid name! Only letters, numbers, and underscore allowed."
		main_menu
	fi

	if [[ -d "$DB_DIR/$db_name" ]]; then
		echo "Database already exists!"
	else
		mkdir "$DB_DIR/$db_name"
		echo "Database '$db_name' created successfully."
	fi
	main_menu
}

function list_database() {
	echo "Databases:"
	ls "$DB_DIR"
	main_menu
}



function connect_database() {
    read -p "Enter database name to connect: " db_name
	if [[ ! -d "$DB_DIR/$db_name" ]]; then
		echo "Database does not exist!"
		main_menu
	fi
	echo "Connected to database '$db_name'."
	. connection_operations.sh "$db_name"
    main_menu
}

function drop_database() {
    echo "Not implemented yet."
    main_menu
}

# Start the app
main_menu
