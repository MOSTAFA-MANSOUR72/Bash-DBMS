TABLES_DIR="tables"
db_name="$1"

mkdir -p "./databases/$db_name/$TABLES_DIR"

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
        1) create_table "$db_name" ;;
        2) list_tables "$db_name" ;;
        3) drop_table "$db_name" ;;
        4) insert_into_table "$db_name" ;;
        5) select_from_table "$db_name" ;;
        6) delete_from_table "$db_name" ;;
        7) update_table "$db_name" ;;
        8) . main.sh ;;
        *) echo "Invalid option"; list_options "$db_name" ;;
    esac 
}

function create_table() {
    echo "Not implemented yet."
    list_options "$db_name"
}

function list_tables() {
    echo "Tables in database '$db_name':"
    ls "./databases/$db_name/$TABLES_DIR"
    list_options "$db_name"
}

function drop_table() {
    echo "Not implemented yet."
    list_options "$db_name"
}

function insert_into_table() {
    echo "Not implemented yet."
    list_options "$db_name"
}

function select_from_table() {
    echo "Not implemented yet."
    list_options "$db_name"
}

function delete_from_table() {
    echo "Not implemented yet."
    list_options "$db_name"
}

function update_table() {
    echo "Not implemented yet."
    list_options "$db_name"
}


list_options "$db_name"
