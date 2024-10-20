# This file contains the functions used to generate the moire pattern for the 2D
# crystal lattice data.

## Importing the necessary libraries
import numpy as np

"""
    Function: harmonic2Dmoire_2
    This function generates the moire pattern for a 2D crystal lattice. The function
    takes in the x and y coordinates of the lattice, and the lattice constant of the
    crystal. The function also reads in the data from the CrI3_sin_dict.txt file, which
    contains the information about the sinusoidal contributions to the moire pattern.
    The function then computes the sheared coordinates, and initializes the solution data
    array. The function then sums the contributions of each sinusoid to the solution data
    array, and returns the final solution data array.
"""
def harmonic2Dmoire_2(xx, yy, a_nm):
    theta = 120
    sin_data = np.genfromtxt("CrI3_sin_dict.txt", delimiter=", ")
    opdata = sin_data[0:-1,:]
    dc_val = sin_data[-1, 2]

    # Compute the sheared coordinates
    XX = (xx + yy / np.tan(np.radians(theta)))/a_nm
    YY = yy / np.sin(np.radians(theta)) /a_nm
    
    # Initialize the solution data array
    sol_data = np.full((len(yy), len(xx[0])), dc_val)
    
    # Sum the contributions of each sinusoid
    for (i, j, mag, ang) in opdata:
        sol_data += 2 * mag * np.cos(2 * np.pi * j * XX + 2 * np.pi * i * YY + ang)
    
    return sol_data