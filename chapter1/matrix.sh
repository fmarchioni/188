#!/bin/bash
N_LINE=$(( $(tput lines) - 1));
N_COLUMN=$(tput cols);

function get_char {
    RANDOM_U=$(echo $(( (RANDOM % 9) + 0)));
    RANDOM_D=$(echo $(( (RANDOM % 9) + 0)));
    
    #https://unicode-table.com/en/#kangxi-radicals
    CHAR_TYPE="\u04"

    printf "%s" "$CHAR_TYPE$RANDOM_D$RANDOM_U";
}


function cursor_position {
    echo "\033[$1;${RANDOM_COLUMN}H";
}

function write_char {
    CHAR=$(get_char);
    print_char $1 $2 $CHAR
}

function erase_char { 
    CHAR="\u0020" #Space char
    print_char $1 $2 $CHAR
}

function print_char {
    CURSOR=$(cursor_position $1);
    echo -e "$CURSOR$2$3";
}


function draw_line {    
    RANDOM_COLUMN=$[RANDOM%N_COLUMN];
    RANDOM_LINE_SIZE=$(echo $(( (RANDOM % $N_LINE) + 1)));
    SPEED=0.05

    COLOR="\033[32m"; #GREEN
    COLOR_HEAD="\033[37m"; #WHITE

    #Draw Line
    for i in $(seq 1 $N_LINE ); do 
        write_char $[i-1] $COLOR;
        write_char $i $COLOR_HEAD;
        sleep $SPEED;
        if [ $i -ge $RANDOM_LINE_SIZE ]; then 
            erase_char $[i-RANDOM_LINE_SIZE]; 
        fi;
    done;

    #Erase Line
    for i in $(seq $[i-$RANDOM_LINE_SIZE] $N_LINE); do 
        erase_char $i
        sleep $SPEED;
    done
}

function matrix {
    tput setab 000 #Background Black
    clear
    start_time=$(date +%s) # Registra il tempo di inizio
    while true; do
        draw_line & #Parallel
        sleep 0.5
        current_time=$(date +%s) # Ottieni il tempo attuale
        if (( current_time - start_time >= 10 )); then
            break # Esci dal loop dopo 10 secondi
        fi
    done
}


matrix;

    echo "####################################"         
    echo "#                                  #"          
    echo "#  Benvenuto nella Struttura       #"          
    echo "#  Questa è solo un'illusione...   #"           
    echo "#                                  #"          
    echo "####################################"          
    
exec bash
