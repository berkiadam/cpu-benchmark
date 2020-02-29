#!/usr/bin/gnuplot --persist
reset
set terminal png size 700, 800



print "CPU type     : ", ARG1
print "Duration     : ", ARG2
print "Thread count    : ", ARG3
print "Load    : ", ARG4


#####Közös résza multiplot-hoz########xx
set key below
set grid

set output 'output.png'

set multiplot layout 2,1 rowsfirst title "{/:Bold Adam's CPU benchmark} \n CPU type: " . ARG1 . "\n Duration: " . ARG2 . "(s), Threads: " . ARG3 . ", Load: " . ARG4 . "%"


#######Első gráf: fan seed###############

set title "Fan speed"

set xlabel "Time (in seconds)"
set ylabel "Fan speed (RPM)"




plot "output.txt" using 1:($4) title "Fan speed" axis x1y1 smooth csplines


######Második gráf: freq és temp ######### 

set title "Frequency and temperature"

set xlabel "Time (in seconds)"

set ylabel "CPU Frequency (Hz)"

set y2label "CPU Temperature (C)"
set y2tics 0, 5


set ytics nomirror

plot "output.txt" using 1:($2) title "Freq" axis x1y1 smooth csplines, "" using 1:($3) title "Temp" axis x1y2 smooth csplines





