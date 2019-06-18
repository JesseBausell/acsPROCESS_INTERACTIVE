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
acsPROCESS_INTERACTIVE processes raw field-collected ac-s measurements following a series of steps. It is outfitted to process raw data contained in ac-s ascii files regardless of ac-s channel number, wavelengths, or orientation of column field headers. It is similar in its function to acsPROCESS_SEABASS with the following exceptions: 1. user to determine which portions of ac-s multicast to process, 2. QAQC is performed interactively by user (it is not automated), 3. processed ac-s are output as (depth-binned) Hydrolight-compatible .txt files and MAT/HDF5 files. The later can be used for different types of statistical analyses such as boostrapping. Steps are outlined below:
  1. Reads ascii data into Matlab
  2. Calculates water column salinity using measurements conductivity (CTD)
  3. Prompts user to select a subset of the cast for processing. This can be as much or as little of the cast as he/she desires.
  4. Performs correction for spectral "jumps" caused by ac-s sampling using two holographic gratings
  5. Subtracts a/c pure-water calibration spectra from field-measured ac-s data**
  6. Corrects for the optical effects temperature and salinity using Sullivan et al. (2006)
  7. Corrects for scattering using Rottgers et al. (2013)
  8. QA/QC ac-s data. Paired ac spectra are flagged and removed if:
    a. c spectrum contains value less than zero or greater than 4 /m (400-700 nm)
    b. a spectrum contains value less than zero or greater than c value measured by the same channel (400-700 nm)
  8. Processed ac-s data are timestamped
  9. Produces Seabass-formatted ascii (.txt) file containing spectral offsets (a & c) calculated from holographic grating correction 
  10. Produces SeaBASS-formatted ascii (.txt) file containing time-stamped a/c spectra with depths at which they were sampled
  11. Produces SeaBASS-formatted ascii (.txt) file(s) containing depth-binned a/c average spectra and standard deviations. 
  12. Produces Matlab plot (.fig) detailing ac-s water column position (depth) over time (spectrum index). Plot will contain a user-selected reference point and a time-stamp (which is listed above the plot). Assuming ac-s was deployed simultaneously with hs6, hs6PROCESS_SEABASS.m will use this information to synchronize ac-s and hs6 data. In the event that ac-s and hs6 were deployed independently, the .fig file can be ignored.
