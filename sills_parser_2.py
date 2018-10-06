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

Note, this command: sed -i 's/./& /47' run on oga seafloor first to add space
for fixed width text files. 
Also ran sed -i '$ d' to remove final line (which reads "EOD")
"""


### Uncomment for OGA data
#file = "OGA_sills.dat"
#ff_file = "oga_forced_folds.dat"
#sf_file = "oga_seafloor.dat"

### Uncomment for PAD data
file = "all_sills_PAD_ireland.dat"
ff_file = "pad_forced_folds.dat"
sf_file = "seafloor_PAD_ireland.dat"

import math 
import numpy as np 
import pandas as pd

## Read in forced folds and seafloor 
ff = np.loadtxt(ff_file, skiprows=2, usecols=(0,1,2))
sf = np.loadtxt(sf_file, skiprows=2, usecols=(0,1,2))

# Sort forced folds and seafloor 
ff = ff[ff[:,1].argsort(),:]
ff = ff[ff[:,0].argsort(kind="mergesort"),:]

sf = sf[sf[:,1].argsort(),:]
sf = sf[sf[:,0].argsort(kind="mergesort"),:]


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
        
def ff_time(s_x, s_y):
    '''
    Find and return the time to the overlying forced fold horizon.
    Uses binary search and hence requires the ff to be sorted beforehand.
    The try / except is for where sills are not within the forced fold 
    horizon - best to drop the sill rather than extrapolate. 
    '''
    # Find time to ff
    x_l = np.searchsorted(ff[:,0], s_x, side="left")
    x_r = np.searchsorted(ff[:,0], s_x, side="right")
    if x_l == x_r:
        try:
            return ff[x_l, 2]
        except IndexError:
            return np.nan        
    else:
        # Remember to add x_l, as next line only searches sub array. 
        ix = np.searchsorted(ff[x_l:x_r,1], s_y, side="right") + x_l
        try:
            return ff[ix, 2]
        except IndexError:
            return np.nan
    

def depth_con(s_x, s_y, time):
    '''
    Depth convert a twtt time. Uses binary search and hence requires
    sf (the seafloor) to be sorted beforehand. Uses depth below 
    seafloor - time relationship from thesis. 
    '''
    # Find time below seafloor 
    x_l = np.searchsorted(sf[:,0], s_x, side="left")
    x_r = np.searchsorted(sf[:,0], s_x, side="right")
    if x_l == x_r:
        try:
            sf_time = sf[x_l, 2]
            t_below_sf = time/1000.0 - sf_time/1000.0
            # Return depth converted value 
            return -0.04 + 1.08 * t_below_sf + 0.13 * t_below_sf**2
        except IndexError:
            return np.nan    
    else:
        ix = np.searchsorted(sf[x_l:x_r,1], s_y, side="right") + x_l
        try:
            sf_time = sf[ix, 2]
            t_below_sf = time/1000.0 - sf_time/1000.0
            # Return depth converted value 
            return -0.04 + 1.08 * t_below_sf + 0.13 * t_below_sf**2
        except IndexError:
            return np.nan

def decompact(z1, z2, z3, c=0.51, phi_0=0.51, tolerance=0.001):
    '''
    This function implements the decompaction function in allen and allen 2005.
    z1 is the depth to the present day top of the package, in km. z2 is the depth to
    the present day base of the package, in km. z3 is the depth to which the top of the
    package is being moved to by the decompaction. The function returns z4, the depth to the 
    base of the package. 
    c is the porosity-depth coefficient, in km**-1. representative values are shale:0.51, 
    sst:0.27, chalk:0.71, shaly sand: 0.39
    phi_0 is the surface porosity. Representative values are shale:0.63, sst:0.49, 
    chalk:0.7, shaly sand: 0.56. 
    '''
    import numpy as np
    assert type(z1) == int or type(z1) == float or type(z1) == np.float64, "Type of z1 must be an int or a float. z1 = " + str(z1) + ". Type = " + str(type(z1))
    assert type(z2) == int or type(z2) == float or type(z1) == np.float64, "Type of z2 must be an int or a float"
    assert type(z3) == int or type(z3) == float or type(z1) == np.float64, "Type of z3 must be an int or a float"
    z4_new = z2-z1    
    z4_old = (z2 - z1) + 4*tolerance
    safety_counter = 0
    while(abs(z4_old - z4_new) > tolerance and safety_counter < 1000):
        z4_old = z4_new
        safety_counter += 1
        z4_new = z2 - z1 - (phi_0 / c)*(np.exp(-c*z1) - np.exp(-c*z2)) + (phi_0/c)*(np.exp(-c*z3) - np.exp(-c*z4_old))
    return z4_new


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
            sill_max_depth = depth_con(mid_x, mid_y, sill_max_t)
            ff_max_time = ff_time(mid_x, mid_y)
            ff_max_depth = depth_con(mid_x, mid_y, ff_max_time)
            decomp_emplac_depth = decompact(ff_max_depth, sill_max_depth, z3=0)
            emplacement_depth.append(decomp_emplac_depth)
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

data = pd.DataFrame({"name":sill_names, "midpoint_x": midpoint_x, "midpoint_y":midpoint_y, "diameter":diameter, "transgressive_height":trans_height, "emplacement_depth":emplacement_depth})
# Convert inf or -inf to na, then drop all rows with na. 
data = data.replace([np.inf, -np.inf], np.nan).dropna()
# If any emplacement depths are negative something is wrong, so drop
data = data[data.emplacement_depth > 0]
# If any transgressive heights are greater than emplacement depth, something is wrong, so drop 
data = data[data.emplacement_depth > data.transgressive_height]

# Sanity check by plotting EVERYTHING 
data.hist("diameter")
data.hist("midpoint_x")
data.hist("midpoint_y")
data.hist("emplacement_depth")
data.hist("transgressive_height")
data.plot(x="midpoint_x", y="midpoint_y", kind="scatter")
data.plot(x="emplacement_depth", y="transgressive_height", kind="scatter").plot([0,8], [0,8], 'r-')

# Write to CSV 
data.to_csv("output.csv")
# End of script