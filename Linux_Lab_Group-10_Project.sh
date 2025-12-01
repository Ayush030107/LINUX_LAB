#!/bin/bash

FILE="records.txt"
touch "$FILE"

phone_exists() {
    local phone="$1"
    grep -qF "|$phone|" "$FILE"
}

add_record() {
    echo "Enter customer name:"
    read name

    while true; do
        echo "Enter phone number:"
        read phone

        if phone_exists "$phone"; then
            echo "A customer is already registered with this phone number. Please enter a different one."
        else
            break
        fi
    done

    echo "Enter address:"
    read address
    echo "Enter bill amount:"
    read bill

    echo "$name|$phone|$address|$bill" >> "$FILE"
    echo "Record Added Successfully!"
}

view_records() {
    if [ ! -s "$FILE" ]; then
        echo "No records found!"
        return
    fi

    echo "---Customer Records---"
    while IFS="|" read -r name phone address bill
    do
        echo "Name   : $name"
        echo "Phone  : $phone"
        echo "Address: $address"
        echo "Bill   : Rs $bill"
        echo "---------------------"
    done < "$FILE"
}

search_record() {
    echo "Enter phone number to search:"
    read search

    grep -F "|$search|" "$FILE" > temp.txt

    if [ -s temp.txt ]; then
        echo "Record Found:"
        cat temp.txt
    else
        echo "No matching record found"
    fi

    rm -f temp.txt
}

delete_record()  {
    echo "Enter phone number to delete:"
    read del

    grep -Fv "|$del|" "$FILE" > temp.txt
    mv temp.txt "$FILE"
    echo "Record deleted (if it existed)"
}

modify_record() {
    echo "Enter phone number to modify:"
    read mod

    record=$(grep -F "|$mod|" "$FILE")

    if [ -z "$record" ]; then
        echo "Record not found"
        return
    fi

    old_name=$(echo "$record"    | cut -d "|" -f 1)
    old_phone=$(echo "$record"   | cut -d "|" -f 2)
    old_address=$(echo "$record" | cut -d "|" -f 3)
    old_bill=$(echo "$record"    | cut -d "|" -f 4)

    grep -Fv "|$mod|" "$FILE" > temp.txt
    mv temp.txt "$FILE"

    echo "Enter new name (leave blank to keep: $old_name):"
    read name
    [ -z "$name" ] && name="$old_name"

    while true; do
        echo "Enter new phone (leave blank to keep: $old_phone):"
        read phone

        if [ -z "$phone" ]; then
            phone="$old_phone"
        fi

        if [ "$phone" = "$old_phone" ]; then
            break
        fi

        if phone_exists "$phone"; then
            echo "A customer is already registered with this phone number. Please enter a different one."
        else
            break
        fi
    done

    echo "Enter new address (leave blank to keep: $old_address):"
    read address
    [ -z "$address" ] && address="$old_address"

    echo "Enter new bill amount (leave blank to keep: $old_bill):"
    read bill
    [ -z "$bill" ] && bill="$old_bill"

    echo "$name|$phone|$address|$bill" >> "$FILE"
    echo "Record Modified Successfully"
}

view_payment() {
    echo "Enter phone number:"
    read num

    record=$(grep -F "|$num|" "$FILE")

    if [ -z "$record" ]; then
        echo "Record not found"
        return
    fi

    name=$(echo "$record"   | cut -d "|" -f 1)
    phone=$(echo "$record"  | cut -d "|" -f 2)
    address=$(echo "$record"| cut -d "|" -f 3)
    bill=$(echo "$record"   | cut -d "|" -f 4)

    echo "----Payment Details----"
    echo "Customer    : $name"
    echo "Phone       : $phone"
    echo "Address     : $address"
    echo "Pending Bill: Rs $bill"
    echo "------------------------"
}

while true
do
    echo "
TELECOM BILLING SYSTEM
1. Add new record
2. View Records
3. Modify record
4. View Payment
5. Search record
6. Delete record 
7. Exit
...........................
Enter your choice:"
    read choice
    case $choice in
        1) add_record ;;
        2) view_records ;;
        3) modify_record ;;
        4) view_payment ;;
        5) search_record ;;
        6) delete_record ;;
        7) exit ;;
        *) echo "Invalid choice!" ;;
    esac
done
