#!/usr/bin/env python
# -*- coding: utf-8 -*-

# This script finds stray pixels in an indexed PNG file.
# A stray pixel is defined as one or a few pixels of a particular color
# lost among a large amount of pixels of another color

# Any area with less pixels than this value will trigger a warning
MAX_AREA_SIZE = 5

import sys
import numpy
from PIL import Image

if(len(sys.argv) != 2):
    print "Usage: {} [path to image]".format(sys.argv[0])
    sys.exit()

# Will raise an exception when opening something other than an image
im = Image.open(sys.argv[1])

if(im.format != "PNG" or im.palette is None):
    raise Exception("Only indexed PNG files are supported.")

width, height = im.size

print "Opening {} ({}x{})".format(sys.argv[1], width, height)

# Create a matrix of seen pixels, so we don't waste time treating ones we've already seen
seenPixels = numpy.zeros((width, height))

pixels = im.load()

# Define the fill algorithm
# Returns the number of pixels of the indicated color, starting from [x,y]
def fill(x, y, color):
    total = 0
    fillSet = set()
    fillSet.add((x, y))

    # Continue while the set is not empty
    while fillSet:
        (x, y) = fillSet.pop()

        if x < 0 or y < 0 or x >= width or y >= height or seenPixels[x, y] != 0 or pixels[x, y] != color:
            continue

        seenPixels[x, y] = 1
        total += 1

        # Left, right, up, down
        fillSet.add((x-1, y))
        fillSet.add((x+1, y))
        fillSet.add((x, y-1))
        fillSet.add((x, y+1))

        # Top left
        fillSet.add((x-1, y-1))
        # Top right
        fillSet.add((x+1, y-1))
        # Bottom left
        fillSet.add((x-1, y+1))
        # Bottom right
        fillSet.add((x+1, y+1))
    
    return total

# I usually put a swatch at the bottom right, this allows to ignore it by not analyzing the last line
height -= 1

# Start analyzing image pixel by pixel
# i and j are reversed to go left to right, top to bottom
for j in xrange(0, height):
    for i in xrange(0, width):
        # Don't treat pixels already treated
        if(seenPixels[i, j] == 0):
            color = pixels[i, j]

            # Ignore transparent pixels
            if(color == 0):
                continue

            # Start the fill algorithm and get the number of pixels of that color
            total = fill(i, j, color)

            if(total <= MAX_AREA_SIZE):
                print "Stray pixels detected starting at {} {} with size {}".format(i, j, total)
