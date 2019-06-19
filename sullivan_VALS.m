function [temp_DEP, salt_DEP_a, salt_DEP_c, waveLength_CORR]...
    = sullivan_VALS(waveLength,Sullivan_VALUES)
% sullivan_VALS
% Jesse Bausell
% Date unknown
% 
% sullivan_VALS will find the proper temperature, salinity adjustment
% coefficients for absorption and attenuation for a specified wavelength. 
% 
% Inputs:
% waveLength - the wavelength of interest
% Sullivan_VALUES - matfile containing all of the conversion (dependency)
% factors at each wavelength
% 
% Outputs:
% temp_DEP - adjustment coefficient for temperature (both a & c)
% salt_DEP_a - adjustment coefficient for salinity (a)
% salt_DEP_c - adjustment coefficient for salinity (c)
% waveLength_CORR - actual wavelength for the values (sullivan value that
% is the closest to waveLength input.

Diff = abs(Sullivan_VALUES(:,1)-waveLength-.001); %find all differences in wave lengths
        
A_IND = find(Diff == min(Diff)); %find minimal difference in wave length and use as an index

%find relevant values in order to solve equations
waveLength_CORR = Sullivan_VALUES(A_IND,1);
temp_DEP = Sullivan_VALUES(A_IND,2);
salt_DEP_c = Sullivan_VALUES(A_IND,4);
salt_DEP_a = Sullivan_VALUES(A_IND,6);
