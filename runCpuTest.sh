#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


########Get argument##################

MAX_TIME=600
SCALE=15
CPU_COUNT=3
LOAD=80
HELP=false
UNKOWN=false


POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -d|--duration)
    MAX_TIME="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--scale)
    SCALE="$2"
    shift # past argument
    shift # past value
    ;;
    -c|--cpu)
    CPU_COUNT="$2"
    shift # past argument
    shift # past value
    ;;
    -l|--load)
    LOAD="$2"
    shift # past argument
    shift # past value
    ;;
    -h|--help)
    HELP=true
    shift # past argument    
    ;;
    *)    # unknown option
    POSITIONAL+=("$1") # save it in an array for later
    echo "Unknown options: $1. Please check the help for valid options (--help)"
    shift # past argument
    ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters








############ HELP ##################x

if [ "$HELP" = true ] ; then
    printf "
#####################################
#  Welcome to Adam's cpu benchmark  #
#####################################

Adam's CPU Benchmark is a simple tool for executing load test on your CPU.
You can adjust the extent of the load and also the number of threads (cores) to use during the test.
The app will record the CPU speed, temperature and fan speed changes in time. The result is a multiplot graph.

Usage: 
sudo runCpuTest.sh [options]

Options: 
-d|--duration
Duration of the test (in seconds). Default is 600s

-s|--scale
Sample taking frequency. Default: 15s. (The app will record the CPU temperature, frequency and fan speed in every 15 seconds)

-c|--cpu
Number of CPU threads to use. Default 3.

-l|--load
CPU load. Default 80%%. Don't use 100%% for an extended period. 

-h|--help
Display the help message.

Example: sudo runCpuTest.sh --duration 500 --cpu 3 --load 80
"
    exit
fi





###########Start the benchmark#########


echo ""
echo "#####################################"
echo "#  Welcome to Adam's cpu benchmark  #"
echo "#####################################"
echo ""
echo "Checking dependencies:"

if [ ! -f "/usr/bin/lscpu" ]
then
    echo "/usr/bin/lscpu MISSING"
    exit 0
else
    echo "/usr/bin/lscpu OK"
fi

if [ ! -f "/usr/bin/stress-ng" ]
then
    echo "/usr/bin/stress-ng MISSING"
    exit 0
else
    echo "/usr/bin/stress-ng OK"
fi

if [ ! -f "/usr/bin/sensors" ]
then
    echo "/usr/bin/sensors MISSING"
    exit 0
else
    echo "/usr/bin/sensors OK"
fi

if [ ! -f "/usr/bin/gnuplot" ]
then
    echo "/usr/bin/gnuplot MISSING"
    exit 0
else
    echo "/usr/bin/gnuplot OK"
fi

echo ""


CPU_NAME=$(/usr/bin/lscpu | grep "Model name:" | sed 's/Model name:          //' | sed 's/ /-/g')



i="0"




/usr/bin/stress-ng -c $CPU_COUNT -l $LOAD --tz --timeout $MAX_TIME &



echo "" > output.txt


echo "Time | Freq | Temp | Fan"


while [ $i -lt $MAX_TIME ]
do



	

	TEMP=$(/usr/bin/sensors | grep "CPU:" | sed 's/[^0-9\.]*//g')
   	FREQ=$(/usr/bin/lscpu | grep "CPU MHz:" | sed 's/[^0-9\.]*//g')
	FAN=$(/usr/bin/sensors | grep "Processor Fan:" | sed 's/[^0-9]*//g')
   	TIME=$i

   	echo "$TIME $FREQ $TEMP $FAN" 
	echo "$TIME $FREQ $TEMP $FAN" >> output.txt


	sleep $SCALE
	
	i=$[$i+$SCALE]

done


/usr/bin/gnuplot -c plot.sh $CPU_NAME $MAX_TIME $CPU_COUNT $LOAD


/usr/bin/shotwell output.png &
