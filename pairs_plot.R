### Scatter plot matrix for Rockall sills data ###

# Set working directory
#setwd("~/Documents/Work/rockall/sills_parser")

# Load required packages 
library("GGally")
library("readr")
library("dplyr")

# Read in data using readr
data = read_delim("sills_gmt_format_geog_sampled.txt", delim=" ")

# Drop lat/lon/name columns, reorder columns, and scale columns to be in km not m. 
data_pairs = data %>% 
  select(-c(midpoint_x, midpoint_y, name)) %>% 
  select(diameter, emplacement_depth, transgressive_height, bathy, grav, mag) %>% 
  mutate(diameter = diameter / 1000.0, bathy = bathy / 1000.0)

# Define a function to allow creation of aesthetics in ggpairs plot 
my_fn <- function(data, mapping, ...){
  p <- ggplot(data = data, mapping = mapping) + 
    geom_point(alpha=0.3, size=0.2) + 
    geom_smooth(method=loess, fill="red", color="red", ...) +
    geom_smooth(method=lm, fill="blue", color="blue", ...)
  p
}

# Create ggpairs plot 
rockall_plot = ggpairs(data_pairs, 
        columnLabels = c("Diameter (km)", "Em. depth (km)", "Tr. height (km)", "Bathymetry (km)", "Gravity (mGal)", "Magnetic (nT"), 
        lower = list(continuous = my_fn), 
        upper = list(continuous = wrap("cor", size = 3))) 


# Save ggpairs plot 
ggsave("rockall_sills_scatterplot_matrix.png", rockall_plot, dpi=600, width = 6.5, height = 6.5, units = "in")




######################################
### Explore depth : diameter ratio ###
######################################

## Note, not included in paper, but possibly useful for future work... 

# Regression analysis on our Rockall sills data
lm_mod = with(data_pairs, lm(diameter ~ emplacement_depth))
summary(lm_mod)

# Regression analysis on Malthe-Sorrensen 2004 modelled data 
malthe = read.table("malthe_sorrensen_w_diam_d_emdepth2.dat", col.names = c("em_depth", "diam"))
malthe_mod = with(malthe, lm(diam ~ em_depth))
summary(malthe_mod)

# Plot Rockall and Malthe-Sorrensen data and regression lines 
plot(x=data_pairs$emplacement_depth, y=data_pairs$diameter, pch=".")
points(malthe$em_depth, malthe$diam)
abline(lm_mod, col="red")
abline(malthe_mod, col="blue")
