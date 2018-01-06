#!/bin/bash

# This script is meant to be called by cron every minute
# It takes a screenshot every time it's called
# Every half hour, it then creates a video from all the screenshots it took,
# creating a nice timelapse video
# Requirements: xprintidle/xprintidle-ng, scrot, ffmpeg

cd ~/timelapse

date

# The recorded date from the last time the script was called
recordedDate=`cat date`

currentDate=`date +"%d"`
currentMinute=`date +"%-M"`
currentHour=`date +"%-H"`
currentFullDate=`date +"%F"`

# The maximum system load allowed for making a video
maxLoad=1.00

# From midnight to 6 AM, continue working on yesterday's video rather than making a new one
if [[ $currentHour -lt 6 ]]; then
    currentDate=$recordedDate
    currentFullDate=`date +"%F" -d "yesterday"`
fi

# The script is called for the first time after 6 AM
if [[ ${recordedDate#0} -ne ${currentDate#0} ]]; then
    echo "" > ./log

    # Delete archived screenshots
    find ./yesterday -maxdepth 1 -name "*.jpg" -delete

    # Archive current screenshots
    find -maxdepth 1 -name "*.jpg" -execdir mv '{}' ./yesterday \;

    # Delete old videos
    find ./videos -maxdepth 1 -name "*.mp4" -ctime +7 -delete

    echo $currentDate > ./date
    exit
fi

# Get how long the user has been idle
idle=`DISPLAY=:0 /usr/local/bin/xprintidle-ng`
(( idleMinute=($idle/1000)/60 ))
echo "Idle time: $idle (${idleMinute}m)"

# If the user has been idle for more than 15 minutes, only take a screenshot every five minutes
if (( $idleMinute >= 15 )); then
    echo "Idle, reducing frequency"

    if (( $currentMinute % 5 != 0 )); then
        echo "Not taking screenshot"
        exit
    fi
fi

DISPLAY=:0 scrot -q 100 "$currentDate-%s.jpg"

# Every half hour, check to make the video
if (( $currentMinute % 30 == 0 )); then
    echo "Checking to make video..."
    load=`cat /proc/loadavg | cut -d ' ' -f 2`
    echo "Current load: $load"

    # If the system is overloaded, don't try making the video
    if (( $(echo "$load > $maxLoad " |bc -l) )); then
        echo "$load > $maxLoad, not making video"
        exit
    fi

    # Start ffmpeg with nice and 1 thread so it takes the least amount of resources possible
    nice -n 19 ffmpeg -framerate 3 -pattern_type glob -i "$currentDate-*.jpg" -c:v libx264 -pix_fmt yuv420p -r 6 -y -threads 1 videos/video-$currentFullDate.mp4
    echo "Video done"
fi
