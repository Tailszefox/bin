#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Change the current status in multiple IMs programs at the same time

import dbus
import sys
import subprocess

bus = dbus.SessionBus()

# Get current status from Skype
try:
    skype = bus.get_object("com.Skype.API", "/com/Skype")
    skypeMethod = skype.get_dbus_method("Invoke", "com.Skype.API")
    skypeMethod("NAME ChangeStatus")
    skypeMethod("PROTOCOL 8")
    currentStatus = skypeMethod("GET USERSTATUS")
except Exception as e:
    print "Error while getting Skype : {}".format(e)
    sys.exit()

# Online, we'll change to away
if "ONLINE" in currentStatus:
    isOnline = True
# Away, we'll change to online
elif "AWAY" in currentStatus:
    isOnline = False
# Unknown, give up
else:
    print "Unkown status : {}".format(currentStatus)
    sys.exit()

# Get Pidgin
try:
    pidgin = bus.get_object("im.pidgin.purple.PurpleService", "/im/pidgin/purple/PurpleObject")
    pidginStatuses = {}

    # Get list of statuses for Pidgin so we can change it correctly
    pidginMethodGetAll = pidgin.get_dbus_method("PurpleSavedstatusesGetAll", "im.pidgin.purple.PurpleInterface")
    pidginMethodGetTitle = pidgin.get_dbus_method("PurpleSavedstatusGetTitle", "im.pidgin.purple.PurpleInterface")
    for status in pidginMethodGetAll():
        title = str(pidginMethodGetTitle(status))
        pidginStatuses[title] = status
except Exception as e:
    print "Error while getting Pidgin: {}".format(e)
    pidgin = None

# Get Konversation
try:
    konversation = bus.get_object("org.kde.konversation", "/irc")
except Exception as e:
    print "Error while getting Konversation : {}".format(e)
    konversation = None

# Get Steam
# "steam://friends/status/away" 
# "steam://friends/status/online"
output = subprocess.check_output(["ps", "-e"])
if 'steam' in output:
    steam = True
else:
    steam = None

# Change the status
if isOnline:
    skypeMethod("SET USERSTATUS AWAY")

    if(konversation is not None):
        konversationMethod = konversation.get_dbus_method("setAway", "org.kde.konversation")
        konversationMethod("")

    if(pidgin is not None):
        pidginMethod = pidgin.get_dbus_method("PurpleSavedstatusActivate", "im.pidgin.purple.PurpleInterface")
        pidginMethod(pidginStatuses["Away"])

    if(steam is not None):
        subprocess.call(["steam", "steam://friends/status/away"])

else:
    skypeMethod("SET USERSTATUS ONLINE")

    if(konversation is not None):
        konversationMethod = konversation.get_dbus_method("setBack", "org.kde.konversation")
        konversationMethod()

    if(pidgin is not None):
        pidginMethod = pidgin.get_dbus_method("PurpleSavedstatusActivate", "im.pidgin.purple.PurpleInterface")
        pidginMethod(pidginStatuses["Available"])

    if(steam is not None):
        subprocess.call(["steam", "steam://friends/status/online"])
