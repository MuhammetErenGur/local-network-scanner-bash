#! /bin/bash

log_file="./log_file.log"

base_private_network="255.255.255"
declare -a ip_arr=()
function get_private_network(){
    read -p 'Özel ağınızı giriniz örn(192.168.1): ' private_network
    char_number_base_private_network=$(echo -n "$base_private_network" | wc -c)
    char_number_private_network=$(echo -n "$private_network" | wc -c)
    if (((char_number_base_private_network == char_number_private_network) || ((char_number_base_private_network > char_number_private_network) && (char_number_private_network > 8))));then
        echo "Ip adresleri taranıyor ..."
    
    else
        echo "Hatalı giriş"
        exit 2
    fi
}


function get_online_devices(){
    echo "Çevrimiçi cihazlar tespit ediliyor"
    for i in {1..255}; do {
        ip="$private_network.$i"
        if ping -c 1 -W 1 "$ip" &> /dev/null;then
            ip_arr+=($ip)
        fi
    }
    done
    
}


function get_open_ports(){
    echo "Çevrimiçi cihazlar"
    select ip in ${ip_arr[@]}
    do
        for port in {1..65535};do
            nc -zvw1 $ip $port > /dev/null 2>&1
            if [ $? -eq 0 ];then
                echo "Port $port open on $ip" >> $log_file
            fi
        done  
    done
    
}

function main(){
    get_private_network
    get_online_devices
    get_open_ports
}

main