#!/bin/bash

#TODO autoincrement id
uuid=0
db_name="q"
table_name=
column_length=8
column_length_with_asteriks=9
max_columns_number=4 
max_line_size=39

create_database() {
    echo "Enter database name:"
    read db_name

    if [ -d "${db_name}" ]; then 
        echo "Error! Database with name '${db_name}' already exists."; 
        return 1
    fi

    echo "Creating database with name ${db_name}..."
    mkdir "${db_name}"
}

create_table() {
    if [[ -z "$db_name" ]]; then
        echo "Error! Before creating table, you have to create database."
        return 1
    fi

    echo "Enter table name:"
    read  table_name    
    if [[ -f  "$db_name/$table_name.txt" ]]; then
        echo "Error! Table with name '$table_name' already exists!"
        return 1
    fi
    touch "$db_name/$table_name.txt"

    echo "Enter column names:"
    read -a columns_input 
    columns_number=${#columns_input[@]}
    if (($columns_number  > $max_columns_number)); then
        echo "Invalid input! Maximum number of columns is $max_columns_number."
        return 1
    fi

    insert_table_header "$columns_number"
    columns=${columns_input[@]}
    format_and_insert_line "${columns}"    
}

insert_table_header() {
    echo "$table_name" > "$db_name/$table_name.txt"
    columns_number=$1
    asteriks_line="***"
    for ((i =  0;  i < $((columns_number * column_length_with_asteriks));  i++)); do
        asteriks_line+="*"
    done
    echo "${asteriks_line}" >> "$db_name/$table_name.txt"
}

#TODO: select data by other columns
#Find asteriks number:
#sed -n '3p' "q/q.txt" | awk -F 'age' '{print gsub(/\*/, "", $1)}'
#grep -A1 "23" q/q.txt | awk -F '23' '{print gsub(/\*/, "", $1)}'
select_data() {
    query_param=$1
    echo "Executing command - SELECT * FROM ${table_name} where id = ${search_param}..."
    result=$(grep "^** ${query_param}" "$db_name/$table_name.txt" | tr -d "**")
    echo  "Search result: "
    echo  "${result}"
}

insert_data() {
    new_line="$@"
    table_columns_number=$(print_table_columns | xargs | wc -w )
    if (($# != $table_columns_number)); then
        echo "Invalid input! You have to input ${table_columns_number} values"
        return 1
    fi 
    
    format_and_insert_line "${new_line}"
}

delete_data_by_id() {
    echo  "Enter table name:"
    read table_name
    echo "Enter id of data you want to delete:"
    read id

    awk -v id="$id" '$2 != id' "$db_name/$table_name.txt" | sponge "$db_name/$table_name.txt"
}

print_table() {
    echo  "Enter table name:"
    read table_name
    content=$(cat "$db_name/$table_name.txt")
    echo -e "\n${content}\n"
}

print_table_columns() {
    columns=$(sed -n '3p' "$db_name/$table_name.txt" | tr -d  '*' | xargs)
    echo "${columns}"
}

format_and_insert_line()  {
    new_line="" 
    set -- junk $1
    shift
        new_line="*"
        for field; do
            field=$(echo "${field}" | xargs)
            new_column="* ${field}"
            new_column_length="${#new_column}"
            ((new_column_length-=1))    #asteriks on begginig of column are not counted
            if (( $new_column_length > $column_length)); then
                echo "Invalid  input! Maximum size of column is ${column_length}"
                return 1
            else    
                #add more spaces if needed
                for ((i = $new_column_length;  i < $column_length;  i++)); do
                    new_column+=" "
                done
                new_line+=$new_column
            fi    
    done
    new_line+="**"
    echo "${new_line}" >> "${db_name}/${table_name}.txt"
}

search() {
    line_before=$(sed -n '3p' "q/q.txt" | awk -F 'age' '{print gsub(/\*/, "", $1)}')
    line_with="23"
    count=$(grep -A1 "$line_with" q/q.txt | awk -F "$line_with" '{print gsub(/\*/, "", $1)}')

    echo "here"

    if [[ $(grep -A1 23 q/q.txt | awk -F 23 '{print gsub(/\*/, "", $1)}') -eq "$line_before" ]]; then
        grep -A1 23 q/q.txt | tail -n1
    fi

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
        0) 
            create_database
            ;;
        1)  
            create_table
            ;;
        2) #select data from table
            echo  "Enter name of table you want to search:"
            read table_name
            echo  "Enter id of data you are searching for:"
            read id
            select_data "$id"
            ;;
        3) #insert data
            echo "Enter table name:"
            read  table_name
            echo "Columns are:"
            print_table_columns "$table_name"
            echo "Insert values for columns above:" 
            read -a data
            insert_data "${data[@]}"
            ;;
        4) #delete data
            delete_data_by_id
            ;;
        5) 
            print_table
            ;;
        6)
            search
            ;;        
        *) 
            echo "Invalid choice!"
            ;;
    esac
done