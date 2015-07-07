#!/usr/bin/env python
# -*- coding: utf-8 -*-

import dbus
import sys

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

    # Get ID of current status for Pidgin so we can change it correctly
    pidginMethodCurrent = pidgin.get_dbus_method("PurpleSavedstatusGetCurrent", "im.pidgin.purple.PurpleInterface")
    currentPidginStatus = pidginMethodCurrent()
except Exception as e:
    print "Error while getting Pidgin: {}".format(e)
    pidgin = None

# Get Konversation
try:
    konversation = bus.get_object("org.kde.konversation", "/irc")
except Exception as e:
    print "Error while getting Konversation : {}".format(e)
    konversation = None

# Change the status
if isOnline:
    skypeMethod("SET USERSTATUS AWAY")

    if(konversation is not None):
        konversationMethod = konversation.get_dbus_method("setAway", "org.kde.konversation")
        konversationMethod("")

    if(pidgin is not None):
        pidginMethod = pidgin.get_dbus_method("PurpleSavedstatusActivate", "im.pidgin.purple.PurpleInterface")
        pidginMethod(currentPidginStatus + 2)
else:
    skypeMethod("SET USERSTATUS ONLINE")

    if(konversation is not None):
        konversationMethod = konversation.get_dbus_method("setBack", "org.kde.konversation")
        konversationMethod()

    if(pidgin is not None):
        pidginMethod = pidgin.get_dbus_method("PurpleSavedstatusActivate", "im.pidgin.purple.PurpleInterface")
        pidginMethod(currentPidginStatus - 2)
