#! /bin/bash

log_file="./log_file.log"
declare -a ip_add=()
base_private_network="255.255.255"

function get_private_network(){
    read -p 'Özel ağınızı giriniz örn(192.168.1): ' private_network
    char_number_base_private_network=$(echo -n "$base_private_network" | wc -c)
    char_number_private_network=$(echo -n "$private_network" | wc -c)
    if (((char_number_base_private_network == char_number_private_network) || ((char_number_base_private_network > char_number_private_network) && (char_number_private_network > 8))));then
        echo "Ip adresleri taranıyor ..."
    
    else
        echo "Hatalı giriş"
        exit 1
    fi
}


function get_online_devices(){
    echo "Çevrimiçi cihazlar tespit ediliyor"
    subnet="$private_network.0/24"
    nmap_result="$(nmap -sn "$subnet" | grep -o -E -w "[0-9][0-9][0-9]\.[0-9][0-9][0-9]\.[0-9][0-9][0-9]\.[0-9]*" )"
    mapfile -t ip_add <<< "$nmap_result"
}

function get_open_ports(){
    echo "Çevrimiçi cihazlar"
    select ip in ${ip_add[@]}
    do
        nmap_port_scan="$(nmap -p 1-65535 -T4 -A -v $ip | grep -E "port .*[0-9]\/tcp")"
        echo "$nmap_port_scan" >> $log_file
        break
    done
}

function main(){
    get_private_network
    get_online_devices
    get_open_ports
}

main