#!/bin/bash
 
# Tetris Game
 
#APP declaration
APP_NAME="${0##*[\\/]}"
APP_VERSION="1.0"
 
cRed=1
cGreen=2
cYellow=3
cBlue=4
cFuchsia=5
cCyan=6
cWhite=7
colorTable=($cRed $cGreen $cYellow $cBlue $cFuchsia $cCyan $cWhite)
 
iLeft=3
iTop=2
((iTrayLeft = iLeft + 2))
((iTrayTop = iTop + 1))
((iTrayWidth = 10))
((iTrayHeight = 15))
 
cBorder=$cGreen
cScore=$cFuchsia
cScoreValue=$cCyan
 
sigRotate=25
sigLeft=26
sigRight=27
sigDown=28
sigAllDown=29
sigExit=30
 
box0=(0 0 0 1 1 0 1 1)
box1=(0 2 1 2 2 2 3 2 1 0 1 1 1 2 1 3)
box2=(0 0 0 1 1 1 1 2 0 1 1 0 1 1 2 0)
box3=(0 1 0 2 1 0 1 1 0 0 1 0 1 1 2 1)
box4=(0 1 0 2 1 1 2 1 1 0 1 1 1 2 2 2 0 1 1 1 2 0 2 1 0 0 1 0 1 1 1 2)
box5=(0 1 1 1 2 1 2 2 1 0 1 1 1 2 2 0 0 0 0 1 1 1 2 1 0 2 1 0 1 1 1 2)
box6=(0 1 1 1 1 2 2 1 1 0 1 1 1 2 2 1 0 1 1 0 1 1 2 1 0 1 1 0 1 1 1 2)
box=(${box0[@]} ${box1[@]} ${box2[@]} ${box3[@]} ${box4[@]} ${box5[@]} ${box6[@]})
countBox=(1 2 2 2 4 4 4)
offsetBox=(0 1 3 5 7 11 15)
 
iScoreEachLevel=50        #be greater than 7
 
sig=0
iScore=0
iLevel=0
boxNew=()
cBoxNew=0
iBoxNewType=0 
iBoxNewRotate=0
boxCur=()     
cBoxCur=0    
iBoxCurType=0
iBoxCurRotate=0 
boxCurX=-1     
boxCurY=-1    
iMap=()      
 
for ((i = 0; i < iTrayHeight * iTrayWidth; i++)); do iMap[$i]=-1; done
 
 
function RunAsKeyReceiver()
{
        local pidDisplayer key aKey sig cESC sTTY
 
        pidDisplayer=$1
        aKey=(0 0 0)
 
        cESC=`echo -ne "\033"`
        cSpace=`echo -ne "\040"`
 
        sTTY=`stty -g`
 
        trap "MyExit;" INT TERM
        trap "MyExitNoSub;" $sigExit
 
        echo -ne "\033[?25l"
 
 
        while :
        do
                read -s -n 1 key
 
                aKey[0]=${aKey[1]}
                aKey[1]=${aKey[2]}
                aKey[2]=$key
                sig=0
 
                if [[ $key == $cESC && ${aKey[1]} == $cESC ]]
                then
                        MyExit
                elif [[ ${aKey[0]} == $cESC && ${aKey[1]} == "[" ]]
                then
                        if [[ $key == "A" ]]; then sig=$sigRotate
                        elif [[ $key == "B" ]]; then sig=$sigDown
                        elif [[ $key == "D" ]]; then sig=$sigLeft
                        elif [[ $key == "C" ]]; then sig=$sigRight
                        fi
                elif [[ $key == "W" || $key == "w" ]]; then sig=$sigRotate
                elif [[ $key == "S" || $key == "s" ]]; then sig=$sigDown
                elif [[ $key == "A" || $key == "a" ]]; then sig=$sigLeft
                elif [[ $key == "D" || $key == "d" ]]; then sig=$sigRight
                elif [[ "[$key]" == "[]" ]]; then sig=$sigAllDown       
                elif [[ $key == "Q" || $key == "q" ]]                  
                then
                        MyExit
                fi
 
                if [[ $sig != 0 ]]
                then
                       
                        kill -$sig $pidDisplayer
                fi
        done
}
 

function MyExitNoSub()
{
        local y
 

        stty $sTTY
        ((y = iTop + iTrayHeight + 4))
 

        echo -e "\033[?25h\033[${y};0H"
        exit
}
 
 
function MyExit()
{

        kill -$sigExit $pidDisplayer
 
        MyExitNoSub
}
 
 

function RunAsDisplayer()
{
        local sigThis
        InitDraw
 

        trap "sig=$sigRotate;" $sigRotate
        trap "sig=$sigLeft;" $sigLeft
        trap "sig=$sigRight;" $sigRight
        trap "sig=$sigDown;" $sigDown
        trap "sig=$sigAllDown;" $sigAllDown
        trap "ShowExit;" $sigExit
 
        while :
        do

                for ((i = 0; i < 21 - iLevel; i++))
                do
                        sleep 0.02
                        sigThis=$sig
                        sig=0
 

                        if ((sigThis == sigRotate)); then BoxRotate; 
                        elif ((sigThis == sigLeft)); then BoxLeft;   
                        elif ((sigThis == sigRight)); then BoxRight;
                        elif ((sigThis == sigDown)); then BoxDown;  
                        elif ((sigThis == sigAllDown)); then BoxAllDown;
                        fi
                done
                #kill -$sigDown $$
                BoxDown
        done
}
 
 

function BoxMove()
{
        local j i x y xTest yTest
        yTest=$1
        xTest=$2
        for ((j = 0; j < 8; j += 2))
        do
                ((i = j + 1))
                ((y = ${boxCur[$j]} + yTest))
                ((x = ${boxCur[$i]} + xTest))
                if (( y < 0 || y >= iTrayHeight || x < 0 || x >= iTrayWidth))
                then

                        return 1
                fi
                if ((${iMap[y * iTrayWidth + x]} != -1 ))
                then

                        return 1
                fi
        done
        return 0;
}
 
 


function Box2Map()
{
        local j i x y xp yp line
 

        for ((j = 0; j < 8; j += 2))
        do
                ((i = j + 1))
                ((y = ${boxCur[$j]} + boxCurY))
                ((x = ${boxCur[$i]} + boxCurX))
                ((i = y * iTrayWidth + x))
                iMap[$i]=$cBoxCur
        done
 

        line=0
        for ((j = 0; j < iTrayWidth * iTrayHeight; j += iTrayWidth))
        do
                for ((i = j + iTrayWidth - 1; i >= j; i--))
                do
                        if ((${iMap[$i]} == -1)); then break; fi
                done
                if ((i >= j)); then continue; fi
 
                ((line++))
                for ((i = j - 1; i >= 0; i--))
                do
                        ((x = i + iTrayWidth))
                        iMap[$x]=${iMap[$i]}
                done
                for ((i = 0; i < iTrayWidth; i++))
                do
                        iMap[$i]=-1
                done
        done
 
        if ((line == 0)); then return; fi
 

        ((x = iLeft + iTrayWidth * 2 + 7))
        ((y = iTop + 11))
        ((iScore += line * 2 - 1))

        echo -ne "\033[1m\033[3${cScoreValue}m\033[${y};${x}H${iScore}         "
        if ((iScore % iScoreEachLevel < line * 2 - 1))
        then
                if ((iLevel < 20))
                then
                        ((iLevel++))
                        ((y = iTop + 14))

                        echo -ne "\033[3${cScoreValue}m\033[${y};${x}H${iLevel}        "
                fi
        fi
        echo -ne "\033[0m"
 
 

        for ((y = 0; y < iTrayHeight; y++))
        do
                ((yp = y + iTrayTop + 1))
                ((xp = iTrayLeft + 1))
                ((i = y * iTrayWidth))
                echo -ne "\033[${yp};${xp}H"
                for ((x = 0; x < iTrayWidth; x++))
                do
                        ((j = i + x))
                        if ((${iMap[$j]} == -1))
                        then
                                echo -ne "  "
                        else
                                echo -ne "\033[1m\033[7m\033[3${iMap[$j]}m\033[4${iMap[$j]}m[]\033[0m"
                        fi
                done
        done
}
 
 

function BoxDown()
{
        local y s
        ((y = boxCurY + 1))
        if BoxMove $y $boxCurX 
        then
                s="`DrawCurBox 0`"
                ((boxCurY = y))
                s="$s`DrawCurBox 1`"
                echo -ne $s
        else
              
                Box2Map  
                RandomBox 
        fi
}
 

function BoxLeft()
{
        local x s
        ((x = boxCurX - 1))
        if BoxMove $boxCurY $x
        then
                s=`DrawCurBox 0`
                ((boxCurX = x))
                s=$s`DrawCurBox 1`
                echo -ne $s
        fi
}
 

function BoxRight()
{
        local x s
        ((x = boxCurX + 1))
        if BoxMove $boxCurY $x
        then
                s=`DrawCurBox 0`
                ((boxCurX = x))
                s=$s`DrawCurBox 1`
                echo -ne $s
        fi
}
 
 

function BoxAllDown()
{
        local k j i x y iDown s
        iDown=$iTrayHeight
 

        for ((j = 0; j < 8; j += 2))
        do
                ((i = j + 1))
                ((y = ${boxCur[$j]} + boxCurY))
                ((x = ${boxCur[$i]} + boxCurX))
                for ((k = y + 1; k < iTrayHeight; k++))
                do
                        ((i = k * iTrayWidth + x))
                        if (( ${iMap[$i]} != -1)); then break; fi
                done
                ((k -= y + 1))
                if (( $iDown > $k )); then iDown=$k; fi
        done
 
        s=`DrawCurBox 0`  
        ((boxCurY += iDown))
        s=$s`DrawCurBox 1`   
        echo -ne $s
        Box2Map             
        RandomBox       
}
 
 

function BoxRotate()
{
        local iCount iTestRotate boxTest j i s
        iCount=${countBox[$iBoxCurType]}
 
      
        ((iTestRotate = iBoxCurRotate + 1))
        if ((iTestRotate >= iCount))
        then
                ((iTestRotate = 0))
        fi
 
     
        for ((j = 0, i = (${offsetBox[$iBoxCurType]} + $iTestRotate) * 8; j < 8; j++, i++))
        do
                boxTest[$j]=${boxCur[$j]}
                boxCur[$j]=${box[$i]}
        done
 
        if BoxMove $boxCurY $boxCurX  
        then
            
                for ((j = 0; j < 8; j++))
                do
                        boxCur[$j]=${boxTest[$j]}
                done
                s=`DrawCurBox 0`
 
           
                for ((j = 0, i = (${offsetBox[$iBoxCurType]} + $iTestRotate) * 8; j < 8; j++, i++))
                do
                        boxCur[$j]=${box[$i]}
                done
                s=$s`DrawCurBox 1`
                echo -ne $s
                iBoxCurRotate=$iTestRotate
        else
          
                for ((j = 0; j < 8; j++))
                do
                        boxCur[$j]=${boxTest[$j]}
                done
        fi
}
 
 

function DrawCurBox()
{
        local i j t bDraw sBox s
        bDraw=$1
 
        s=""
        if (( bDraw == 0 ))
        then
                sBox="\040\040"
        else
                sBox="[]"
                s=$s"\033[1m\033[7m\033[3${cBoxCur}m\033[4${cBoxCur}m"
        fi
 
        for ((j = 0; j < 8; j += 2))
        do
                ((i = iTrayTop + 1 + ${boxCur[$j]} + boxCurY))
                ((t = iTrayLeft + 1 + 2 * (boxCurX + ${boxCur[$j + 1]})))

                s=$s"\033[${i};${t}H${sBox}"
        done
        s=$s"\033[0m"
        echo -n $s
}
 
 

function RandomBox()
{
        local i j t
 

        iBoxCurType=${iBoxNewType}
        iBoxCurRotate=${iBoxNewRotate}
        cBoxCur=${cBoxNew}
        for ((j = 0; j < ${#boxNew[@]}; j++))
        do
                boxCur[$j]=${boxNew[$j]}
        done
 
 

        if (( ${#boxCur[@]} == 8 ))
        then

                for ((j = 0, t = 4; j < 8; j += 2))
                do
                        if ((${boxCur[$j]} < t)); then t=${boxCur[$j]}; fi
                done
                ((boxCurY = -t))
                for ((j = 1, i = -4, t = 20; j < 8; j += 2))
                do
                        if ((${boxCur[$j]} > i)); then i=${boxCur[$j]}; fi
                        if ((${boxCur[$j]} < t)); then t=${boxCur[$j]}; fi
                done
                ((boxCurX = (iTrayWidth - 1 - i - t) / 2))
 

                echo -ne `DrawCurBox 1`
 

                if ! BoxMove $boxCurY $boxCurX
                then
                        kill -$sigExit ${PPID}
                        ShowExit
                fi
        fi
 
 
 

        for ((j = 0; j < 4; j++))
        do
                ((i = iTop + 1 + j))
                ((t = iLeft + 2 * iTrayWidth + 7))
                echo -ne "\033[${i};${t}H        "
        done
 

        ((iBoxNewType = RANDOM % ${#offsetBox[@]}))
        ((iBoxNewRotate = RANDOM % ${countBox[$iBoxNewType]}))
        for ((j = 0, i = (${offsetBox[$iBoxNewType]} + $iBoxNewRotate) * 8; j < 8; j++, i++))
        do
                boxNew[$j]=${box[$i]};
        done
 
        ((cBoxNew = ${colorTable[RANDOM % ${#colorTable[@]}]}))
 

        echo -ne "\033[1m\033[7m\033[3${cBoxNew}m\033[4${cBoxNew}m"
        for ((j = 0; j < 8; j += 2))
        do
                ((i = iTop + 1 + ${boxNew[$j]}))
                ((t = iLeft + 2 * iTrayWidth + 7 + 2 * ${boxNew[$j + 1]}))
                echo -ne "\033[${i};${t}H[]"
        done
        echo -ne "\033[0m"
}
 
 

function InitDraw()
{
        clear
        RandomBox   
        RandomBox  
        local i t1 t2 t3
 
      
	echo -ne "\033[1m               Tetris by LinuxScriptsHub"
        echo -ne "\033[1m"
        echo -ne "\033[3${cBorder}m\033[4${cBorder}m"
 
        ((t2 = iLeft + 1))
        ((t3 = iLeft + iTrayWidth * 2 + 3))
        for ((i = 0; i < iTrayHeight; i++))
        do
                ((t1 = i + iTop + 2))
                echo -ne "\033[${t1};${t2}H||"
                echo -ne "\033[${t1};${t3}H||"
        done
 
        ((t2 = iTop + iTrayHeight + 2))
        for ((i = 0; i < iTrayWidth + 2; i++))
        do
                ((t1 = i * 2 + iLeft + 1))
                echo -ne "\033[${iTrayTop};${t1}H=="
                echo -ne "\033[${t2};${t1}H=="
        done
        echo -ne "\033[0m"
 
 
     
        echo -ne "\033[1m"
        ((t1 = iLeft + iTrayWidth * 2 + 7))
        ((t2 = iTop + 10))
        echo -ne "\033[3${cScore}m\033[${t2};${t1}HScore"
        ((t2 = iTop + 11))
        echo -ne "\033[3${cScoreValue}m\033[${t2};${t1}H${iScore}"
        ((t2 = iTop + 13))
        echo -ne "\033[3${cScore}m\033[${t2};${t1}HLevel"
        ((t2 = iTop + 14))
        echo -ne "\033[3${cScoreValue}m\033[${t2};${t1}H${iLevel}"
        echo -ne "\033[0m"
}
 
 

function ShowExit()
{
        local y
        ((y = iTrayHeight + iTrayTop + 3))
        echo -e "\033[${y};0HGameOver!\033[0m"
        exit
}
 
 

function Usage
{
        cat << EOF
Usage: $APP_NAME
Start tetris game. (linuxscriptshub.com)
 
  -h, --help              display this help and exit
      --version           output version information and exit
EOF
}
 
 

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        Usage
elif [[ "$1" == "--version" ]]; then
        echo "$APP_NAME $APP_VERSION"
elif [[ "$1" == "--show" ]]; then

        RunAsDisplayer
else
        bash $0 --show&  
        RunAsKeyReceiver $! 
fi
