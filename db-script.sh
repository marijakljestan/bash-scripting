#!/bin/bash

uuid=0
db_name=

create_database() {
    table_name=$1
    echo "Creating table with name ${table_name}..."
    touch "${table_name}"
    echo "$table_name" > ${table_name}
    echo "*****************" >> ${table_name}
}

create_columns() {
    columns="$@"
    echo "${columns}" >> ${db_name}
}

select_data() {
    query_param=$1
    echo "Executing command - SELECT * FROM ${db_name} where id = ${search_param}..."
    result=$(grep -n "^** ${query_param}" ${db_name}   | tr -d "**")
    echo  "Search result: "
    echo  "${result}"
}

insert_data() {
    echo "Inserting  new line in table ${db_name}..."
    new_line="$@"
    echo "${new_line}" >> ${db_name}
}

delete_data() {
    query_param=$1
    echo "Deleting row where id = ${query_param}..."
    grep -v "^** ${query_param}" ${db_name} > data.txt
    mv data.txt ${db_name}
}

print_table() {
    echo -e "\n"
    cat $1
    echo -e "\n"
}

get_columns_for_table() {
    columns=$(grep -A 1 '^\*' ${db_name}  | tr -d  '*' |  tr " " "\n")
    echo -e "Columns are:"
    echo ${columns}
}

while true 
do
    echo -e "\n\n Choose an option:\n"
    echo "0. Create database"
    echo "1. Create a table"
    echo "2. Select data from table"
    echo "3. Insert data in table"
    echo "4. Delete data"
    echo "5. Print  table"
    echo -e  "\n"
    read choice
    case "$choice" in 
        0)  #create database with single table
            echo  "Enter database name:"
            read db_name
            create_database "$db_name"
            ;;
        1)  #create table with provided arguments as columns
            echo "Enter table name:"
            read  db_name
            echo "Enter column names:"
            read -a columns
            create_columns "${columns[@]}"
            ;;
        2) #select data from table
            echo  "Enter name of table you want to search:"
            read db_name
            echo  "Enter id of data you are searching for:"
            read id
            select_data "$id"
            ;;
        3) #insert data
            echo "Enter table name:"
            read  db_name
            get_columns_for_table "$db_name"
            echo "Insert values for columns above:" 
            read -a data
            insert_data "${data[@]}"
            ;;
        4) #delete data
            echo  "Enter table name:"
            read db_name
            echo "Enter id of data you want to delete:"
            read id
            delete_data "$id"
            ;;
        5) #print table
            echo  "Enter table name:"
            read table_name
            print_table "$table_name"
            ;;    
        *) 
            echo "Invalid choice!"
            ;;
    esac
done