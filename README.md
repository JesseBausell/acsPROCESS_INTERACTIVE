# acsPROCESS_INTERACTIVE
Consistent with up to date protocols and NASA's SEABASS submission standards, acsPROCESS_INTERACTIVE processes raw absorption/attenuation data as sampled in natural water bodies using WET Labs ac-s meter.

This Matlab script processes raw spectral absorption (a) and attenuation (c) measurements, as sampled in natural water bodies using Wet Labs Spectral Absorption and Attenuation Sensor (ac-s). acsPROCESS_SEABASS uses up to date processing protocols (as of June 2019) to process ac-s data, which it outputs as both individual and depth-binned spectra. All output data products are formatted for compatibility with Hydrolight 5.0. The script requires user input in selecting a portion of the cast for processing, as well as for QA/QC.

Inputs:
metadata_HeaderFile_acs.txt - ascii file (.txt) containing metadata required to process raw ac-s data (see below)
purewater_absorption.mat - MAT file containing pure-water a calibration spectrum (see Purewater_SpecBuilder)
purewater_attenuation.mat - MAT file containing pure-water c calibration spectrum (see Purewater_SpecBuilder)

Outputs: 
Station_#_ac-s_bin_#.txt - depth-binned file(s) containing processed ac-s data. Formatted for Hydrolight 5.0. acsPROCESS_INTERACTIVE will create one file for each user-specified depth bin (see "Filling out metadata_HeaderFile_acs.txt" section). 
Station_#_acs.mat - MAT/HDF5 file containing individual a spectra (variable: A_CORR), their corresponding c spectra (variable: C_CORR), depths at which spectra were measured (variable: deptH), and wavelengths of a/c spectra (variable: lambda). A_CORR and C_CORR matrices are ordered by ascending depth (rows) and ascending wavelengths (columns).

Required Matlab Scripts and Functions:
ACS_dataFLAGGER6.m
ACS_dataSNATCH6.m
ACS_fileREADER_MS.m
BIN_acDATA_HE53.m
depthSELECTOR.m
HoloGrater_ACS_4.m
lambda_INTERPOLATE.m
metaData_Reader.m
PureWater_Extract3.m
salinityCOND.m
sullivan_VALS.m

Required data files:
Seabass_header_ACS5.mat
Sullivan_VALUES.mat

Program Description:
acsPROCESS_INTERACTIVE processes raw field-collected ac-s measurements following a series of steps. It is outfitted to process raw data contained in ac-s ascii files regardless of ac-s channel number, wavelengths, or orientation of column field headers. It is similar in its function to acsPROCESS_SEABASS, except that it Steps are outlined below:
