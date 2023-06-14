#! /bin/bash
#
# Made by RandomGuy
# Started on 16-2-2022 - completed on 18-2-2022


## predefine
Version=2.5
# colors
Black="\e[30m" ; White="\e[37m"
Green="\e[32m" ; Red="\e[31m"
Yellow="\e[33m"; Blue="\e[34m"
Purple="\e[35m"; Aqua="\e[36m"
Noc="\e[0m"



pause_(){ read -t 2 -sn1 -p "Press any key to continue..."; }

draw_screen_(){
        clear

        board=( " ${xy[0]} | ${xy[1]} | ${xy[2]}"\
                "---|---|---"\
                " ${xy[3]} | ${xy[4]} | ${xy[5]}"\
                "---|---|---"\
                " ${xy[6]} | ${xy[7]} | ${xy[8]}")
        printf "\n"
        for (( i=0; i<5; i++ )); do echo -e "    ${board[$i]}"; done
        printf "\n\n"
}

who_wins_(){
        case "$PlayingMode" in
                1)
                        [[ "$Player1" == "X" ]] && ResultX="You win!" && ResultO="Better luck next time!"
                        [[ "$Player1" == "O" ]] && ResultO="You win!" && ResultX="Better luck next time!"
                ;;
                2)
                        [[ "$Player1" == "X" ]] && ResultX="${PName1} Wins!" && ResultO="${PName2} Wins!"
                        [[ "$Player1" == "O" ]] && ResultX="${PName2} Wins!" && ResultO="${PName1} Wins!"
                ;;
        esac
        ResultD="Match draw!"

        # Rules to win
        if [[ "${xy[1]}${xy[0]}" == "${xy[0]}${xy[2]}" || "${xy[3]}${xy[0]}" == "${xy[0]}${xy[6]}" ]]; then
                result="Result${xy[1]}";
        elif [[ "${xy[3]}${xy[4]}" == "${xy[4]}${xy[5]}" || "${xy[1]}${xy[4]}" == "${xy[4]}${xy[7]}" ]]; then
                result="Result${xy[4]}"
        elif [[ "${xy[6]}${xy[8]}" == "${xy[8]}${xy[7]}" || "${xy[2]}${xy[8]}" == "${xy[8]}${xy[5]}" ]]; then
                result="Result${xy[8]}"
        elif [[ "${xy[0]}${xy[4]}" == "${xy[4]}${xy[8]}" || "${xy[2]}${xy[4]}" == "${xy[4]}${xy[6]}" ]]; then
                result="Result${xy[4]}"
        elif [[ "${xy[@]}" != *[1-9]* ]]; then
                result="ResultD"
        fi

        if [[ ! -z "$result" ]]; then
                clear; sleep 0.4
                printf "${Green}${!result}$Noc\n\n"
                unset result
                pause_
                main_ "@"
        fi
}

bot_turn_(){
        printf "${Purple}thinking...$Noc"
        sleep 0.4
        while true; do
                rand=$((RANDOM%10))
                case "$rand" in
                        "9")    continue        ;;
                        *  )    [[ "${xy[$rand]}" == [XO] ]] && continue || xy[$rand]="${Orange}$Player2"       ;;
                esac
                break
        done
}

player_turn_(){
        unset Input
        # change title according to playing mode
        if [[ $PlayingMode == 1 ]]; then
                printf "\r${Blue}Your turn($Player1)> $Noc"
        elif [[ $PlayingMode == 2 ]]; then
                printf "\r${Purple}${PName1} ($Player1)> $Noc"
        fi

        while [[ "$Input" != [0-9] ]]; do
                read -sn1 Input
        done

        Input=$((Input - 1))
        [[ "${xy[$Input]}" == [XO] ]] && player_turn_ || xy[$Input]="$Player1"
}

player2_turn_(){
        unset Input
        printf "\r${Blue}${PName2} ($Player2)> $Noc"
        while [[ "$Input" != [0-9] ]]; do
                read -sn1 Input
        done
        Input=$((Input - 1))
        [[ "${xy[$Input]}" == [XO] ]] && player2_turn_ || xy[$Input]="$Player2"
}

main_(){
        clear
        unset xy

        # xy[0] = 1
        #   ...to
        # xy[8] = 9
        for (( i=1; i<10; i++ )); do
                xy+=( "${Aqua}${i}${Noc}" )
        done

        # Assign name to Player1
        [[ $((RANDOM%2)) -eq 0 ]] && Player1='X' || Player1='O'
        [[ "$1" == "-"[xX]* ]] && Player1='X'
        [[ "$1" == "-"[oO]* ]] && Player1='O'
        # Assign name to Player2
        [[ "$Player1" == "X" ]] && Player2='O' || Player2='X'

        printf "${Yellow} 1. Play with Bot\n 2. Play multiplayer\n 0. Exit\n${Noc}\n${Blue}> $White"
        read -sn1 Input
        case "$Input" in
                "1")
                        PlayingMode=1

                        # choose random turn
                        if [[ $((RANDOM%2)) -eq 0 ]]; then
                                for (( i=0; i<9; i++ )); do
                                        draw_screen_; player_turn_; who_wins_
                                        draw_screen_; bot_turn_   ; who_wins_
                                done
                        else
                                for (( i=0; i<9; i++ )); do
                                        draw_screen_; bot_turn_   ; who_wins_
                                        draw_screen_; player_turn_; who_wins_
                                done
                        fi
                ;;
                "2")
                        PlayingMode=2
                        printf "\r${Blue}Player1 Name > $White"; read PName1
                        printf "\r${Blue}Player2 Name > $White"; read PName2
                        PName1=${PName1:-"Player1"}
                        PName2=${PName2:-"Player2"}

                        # choose random turn
                        if [[ $((RANDOM%2)) -eq 0 ]]; then
                                for (( i=0; i<9; i++ )); do
                                        draw_screen_; player_turn_ ; who_wins_
                                        draw_screen_; player2_turn_; who_wins_
                                done
                        else
                                for (( i=0; i<9; i++ )); do
                                        draw_screen_; player2_turn_; who_wins_
                                        draw_screen_; player_turn_ ; who_wins_
                                done
                        fi
                ;;
                "0")
                        clear
                        exit
                ;;
                *  )
                        clear
                        echo -e "$Red ¯\_(oo)_/¯$Noc\n"
                        pause_
                ;;
        esac
}

while true; do main_ "$@"; done