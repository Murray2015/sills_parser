# -*- coding: utf-8 -*-
"""
Created on Sun Sep 16 17:16:04 2018

@author: murray

Python script to take an file outputted by IHS Kingdom
of sill horizons from 2D seismic, and return the:
1. Midpoint x and y location of the sill
2. Diameter of the sill 
3. Maximum transgressive height 
4. Maximum emplacement depth 

"""

file = "OGA_sills.dat"



import math 

file_connection = open(file, "r")
sill_names, midpoint, diameter, trans_height, emplacement_depth = [], [], [], [], []

exceptions = 0
for i in file_connection:
    line = file_connection.readline()
#    print(line)
    if "PROFILE" in line:
#        print("profile")
        # Add new sill name to names list 
        words = line.split()
        sill_names.append(words[1] + " " + words[2])
        # zero all temp vars  
        min_x, max_x, min_y, max_y, deepest, shallowest = 0, 0, 0, 0, 0, 0
        # Skip the "SNAPPING..." line
        line = file_connection.readline()
    elif "SNAPPING" in line:
        continue
    elif "EOD" in line:
#        print("eod")
        # Calculate final vars and add to list
        midpoint.append(((min_x + max_x / 2), (min_y + max_y / 2)))
        diameter.append(math.sqrt((max_x - min_x)**2 + (max_y - min_y)**2))
        # depth convert deepest and shallowest, then find trans_height
        # Depth convert deepest and find emplacement depth 
    else:
#        print("else")
        # update vars 
        values = line.split()
        try:
            x, y, depth = float(values[0]), float(values[1]), float(values[2])
        except:
            exceptions += 1
            print("Exception {}!".format(exceptions))
            continue
        if min_x > x:
            min_x = x
        if max_x < x:
            max_x = x
        if min_y > y:
            min_y = y
        if max_y < y:
            max_y = y 

file_connection.close()
print(sill_names)
print(midpoint)
print(diameter)
# Make dataframe of sills 