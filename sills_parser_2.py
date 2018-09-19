# -*- coding: utf-8 -*-
"""
Created on Tue Sep 18 16:22:40 2018

@author: murray

Python script to take an file outputted by IHS Kingdom
of sill horizons from 2D seismic, and return the:
1. Midpoint x and y location of the sill
2. Diameter of the sill 
3. Maximum transgressive height 
4. Maximum emplacement depth 
"""


##### Currently the logic is for seafloor, but am giving it ff !! 

file = "OGA_sills.dat"
ff_file = "oga_forced_folds.dat"

import math 
import numpy as np 
import pandas as pd

# Read in forced folds and seafloor 
ff = np.loadtxt(ff_file, skiprows=2, usecols=(0,1,2))

# Sort forced folds and seafloor 
ff = ff[ff[:,1].argsort(),:]
ff = ff[ff[:,0].argsort(kind="mergesort"),:]


file_connection = open(file, "r")
sill_names, midpoint_x, midpoint_y, diameter, sill_time, trans_height, emplacement_depth = [], [], [], [], [], [], []

def fixed_width(line):
    '''
    Parse the first 3 fields of IHS Kingdom output horizon
    file. File is fixed width. 
    '''
    c1, c2, c3 = line[2:17], line[17:32], line[32:47]
    try:
        return float(c1), float(c2), float(c3)
    except:
        raise ValueError("Fixed width exception!")

def depth_con(s_x, s_y, s_time):
    '''
    Depth convert a sill time. Uses binary search and hence requires
    ff (the forced fold) to be sorted beforehand. Uses depth below 
    seafloor - time relationship from thesis. 
    '''
    # Find time below seafloor 
    x_l = np.searchsorted(ff[:,0], s_x, side="left")
    x_r = np.searchsorted(ff[:,0], s_x, side="right")
    ix = np.searchsorted(ff[x_l:x_r,1], s_y, side="right")
    sf_time = ff[ix, 2]
    t_below_sf = s_time/1000.0 - sf_time/1000.0
    # Return depth converted value 
    return -0.04 + 1.08 * t_below_sf + 0.13 * t_below_sf**2

x, y, z, x_min, x_max, y_min, y_max = np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan
z_list = []
for line in file_connection:
    if "PROFILE" in line:
        name_line = line.split()
        sill_name = "Sill " + name_line[2]
    elif "SNAPPING" in line:
        continue
    elif "EOD" in line:
        if np.isnan(x_min):
            continue
        else:
            sill_names.append(sill_name)
            sill_max_t = np.max(z_list)
            sill_min_t = np.min(z_list)
            mid_x = (x_min + x_max) / 2.0
            mid_y = (y_min + y_max) / 2.0
            midpoint_x.append(mid_x)
            midpoint_y.append(mid_y)
            diameter.append(math.sqrt((x_max - x_min)**2 + (y_max - y_min)**2))
            sill_time.append(sill_max_t)
            trans_height.append(depth_con(mid_x, mid_y, sill_max_t) - depth_con(mid_x, mid_y, sill_min_t))
            x, y, z, x_min, x_max, y_min, y_max = np.nan, np.nan, np.nan, np.nan, np.nan, np.nan, np.nan
            z_list = []
    else:
        x, y, z = fixed_width(line)
        if x_min > x or np.isnan(x_min):
            x_min = x
        if x_max < x or np.isnan(x_max):
            x_max = x
        if y_min > y or np.isnan(y_min):
            y_min = y
        if y_max < y or np.isnan(y_max):
            y_max = y
        z_list.append(z)

file_connection.close() 

data = pd.DataFrame({"midpoint_x": midpoint_x, "midpoint_y":midpoint_y, "diameter":diameter, "transgressive_height":trans_height})
data.to_csv("output.csv")

