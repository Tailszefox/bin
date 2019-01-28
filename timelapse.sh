#!/bin/bash

# This script is meant to be called by cron every minute
# It takes a screenshot every time it's called
# Every half hour, it then creates a video from all the screenshots it took,
# creating a nice timelapse video
# Requirements: xprintidle/xprintidle-ng, scrot, ffmpeg

cd ~/timelapse

# The recorded date from the last time the script was called
lastTimestamp=`cat lastTimestamp`

currentLocalDate=`date`
currentFullDate=`date +"%F"`
currentDay=`date +"%d"`
currentMinute=`date +"%-M"`
currentHour=`date +"%-H"`
currentTimestamp=`date +"%s"`

# The maximum system load allowed for making a video
maxLoad=1.00

# Check last time the script was called
secondsSinceLast=$(($currentTimestamp-$lastTimestamp))

# If last call was more than an hour ago, start a new session
if [[ $secondsSinceLast -gt 3600 ]]; then
    echo "" > ./log
    echo "Starting a new session"

    # Delete oldest screenshots
    find ./previous/3 -maxdepth 1 -name "*.jpg" -delete

    # Shift screenshots to previous day
    find ./previous/2 -maxdepth 1 -name "*.jpg" -execdir mv '{}' ../3  \;
    find ./previous/1 -maxdepth 1 -name "*.jpg" -execdir mv '{}' ../2  \;
    find ./ -maxdepth 1 -name "*.jpg" -execdir mv '{}' ./previous/1  \;
fi

echo "$currentLocalDate / ($currentTimestamp - $lastTimestamp) = $secondsSinceLast"

# Save new timestamp
echo $currentTimestamp > ./lastTimestamp

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

DISPLAY=:0 scrot -q 100 "%s.jpg"

# Every half hour, check to make the video
# if (( $currentMinute % 30 == 0 )); then
#     echo "Checking to make video..."
#     load=`cat /proc/loadavg | cut -d ' ' -f 2`
#     echo "Current load: $load"

#     # If the system is overloaded, don't try making the video
#     if (( $(echo "$load > $maxLoad " |bc -l) )); then
#         echo "$load > $maxLoad, not making video"
#         exit
#     fi

#     # Start ffmpeg with nice and 1 thread so it takes the least amount of resources possible
#     nice -n 19 ffmpeg -framerate 3 -pattern_type glob -i "$currentDate-*.jpg" -c:v libx264 -pix_fmt yuv420p -r 6 -y -threads 1 videos/video-$currentFullDate.mp4
#     echo "Video done"
# fi
