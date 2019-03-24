#!/usr/bin/env python3

# This won't work past Firefox 66 because scripts are now stored inside an indexedDB

import json
import re

# Load JSON file containing all the userscripts
with open('/home/tails/.mozilla/firefox/s00zsszv.tailszefox/browser-extension-data/{aecec67f-0d10-4fa7-b7c7-609a2db280cf}/storage.js') as f:
    userscripts = json.load(f)

for key in userscripts:
    # We found an userscript's code
    if key.startswith("code:"):
        # Grab the metadata to check the author
        metadata = userscripts[key.replace("code:", "scr:")]["meta"]

        # Only export scripts I made
        try:
            if(metadata["author"] != "Tailszefox"):
                continue
        # No author found
        except KeyError:
            continue

        print("Found script {}".format(metadata["name"]))
        filename = re.sub('[\s\(\)]', '_', metadata["name"]) + ".user.js"
        print("Saving to {}".format(filename))

        with open('/home/tails/backup/firefox/userscripts/{}'.format(filename), 'w') as uf:
            uf.write(userscripts[key])

        with open('/home/tails/Documents/scripts/github/Userscripts/{}'.format(filename), 'w') as uf:
            uf.write(userscripts[key])
