# -*- coding: utf-8 -*-
"""
Created on Tue Sep 18 16:22:40 2018

@author: murray
"""

file = "OGA_sills.dat"

import math 
import numpy as np 

file_connection = open(file, "r")
sill_names, midpoint_x, midpoint_y, diameter, trans_height, emplacement_depth = [], [], [], [], [], []

def fixed_width(line):
    c1 = line[2:17]
    c2 = line[17:32]
    c3 = line[32:47]
    try:
        return float(c1), float(c2), float(c3)
    except:
        print("Fixed width exception!")
        print(line)

x, y, z, x_min, x_max, y_min, y_max = np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan
for line in file_connection:
    if "PROFILE" in line:
        name_line = line.split()
        sill_name = "Sill " + name_line[2]
        #print(sill_name)
    elif "SNAPPING" in line:
        continue
    elif "EOD" in line:
        if x_min == np.nan:
            continue
        else:
            sill_names.append(sill_name)
            midpoint_x.append((x_min + x_max) / 2)
            midpoint_y.append((y_min + y_max) / 2)
            diameter.append(math.sqrt((x_max - x_min)**2 + (y_max - y_min)**2))
            x, y, z, x_min, x_max, y_min, y_max = np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan
    else:
        x, y, z = fixed_width(line)
#        print(x, y, z)
        if x_min > x or np.isnan(x_min):
            x_min = x
        if x_max < x or np.isnan(x_max):
            x_max = x
        if y_min > y or np.isnan(y_min):
            y_min = y
        if y_max < y or np.isnan(y_max):
            y_max = y

file_connection.close() 

#print(sill_names) 
#print(midpoint) 
#print(diameter) 
print(len(sill_names), len(midpoint_x), len(midpoint_y), len(diameter)) 






a = "  2.79546942E+05  6.43261855E+06        4468.32     39.11             39      780.7444 2 WG152DOGA100077A242                        "

