# Bash-DBMS – Lightweight Database Management System in Bash

A simple **command-line Database Management System (DBMS)** built entirely using **Bash scripting**.

This project simulates core database operations without relying on external database engines.  
All data is stored directly in the file system, making it a great educational project to understand how databases work internally.

---

## 🚀 Features

### 📦 Database Operations
- Create Database
- List Databases
- Connect to Database
- Drop Database

### 📑 Table Operations
- Create Table (with columns, datatypes, and primary key)
- List Tables
- Drop Table
- Insert Records (with datatype validation & primary key constraint)
- Select Records (all columns or specific columns)
- Update Records (with validation & PK protection)
- Delete Records (by primary key)
- Alter Table:
  - Add Column
  - Delete Column (except primary key)
  - Update Column Datatype

---

## 🏗️ How It Works

- Each **database** is a directory inside `./databases/`
- Each **table** has:
  - A data file containing records
  - A metadata file (`meta.meta`) storing:
    - Column names
    - Datatypes (`number` / `string`)
    - Primary key definition

Records are stored as **space-separated values** inside table files.

---

## 🛠️ Technologies Used

- Bash Scripting
- File System as Storage Engine
- `awk` for record processing
- `sed` for metadata updates
- `grep` for validation

---

## ▶️ How to Run

```bash
chmod +x main.sh
chmod +x connection_operations.sh
./main.sh
```

## 📌 Validation & Constraints

- Names (databases & tables): letters, numbers, and underscores only.
- Primary Key:
  - Must be a defined column
  - Must be unique
  - Cannot be updated or deleted
- Datatypes:
  - `number` → numeric values only
  - `string` → text values

---

## 📁 Project Structure
```
├── main.sh
├── connection_operations.sh
└── databases/
    └── <database_name>/
        └── tables/
            └── <table_name>/
                ├── <table_name>   (data file)
                └── meta.meta      (metadata)

```
---

## 🎯 Learning Goals

- Understand metadata handling in databases  
- Implement primary key constraints  
- Build CRUD operations from scratch  
- Practice file-based persistence with Bash  

---

## 🔮 Future Improvements

- Add `WHERE` support in `select`
- Implement indexing
- Add foreign key constraints
- Improve formatting
- Add logging & basic transaction simulation
