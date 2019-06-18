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
  3. Prompts user to select a subset of the cast for processing (unselected portions of the cast will be excluded from all subsequent
  steps). This can be as much or as little of the cast as he/she desires.
  4. Performs correction for spectral "jumps" caused by ac-s sampling using two holographic gratings
  5. Subtracts a/c pure-water calibration spectra from field-measured ac-s data**
  6. Corrects for the optical effects temperature and salinity using Sullivan et al. (2006)
  7. Corrects for scattering using Rottgers et al. (2013)
  8. c spectra are interpolated to wavelengths of a spectra 
  9. QA/QC ac-s data. Paired ac spectra are flagged and removed by user:
    a. user flags c spectra that may be contaminated
    b. user flags a spectra that may be contaminated
    c. determines whether to remove previously-flagged a/c spectra. If an a spectrum is removed, its corresponding (paired) c spectrum is 
    removed automatically as well (and vice versa).
  10. Produces MAT/HDF5 file containing processed ac-s data (see "Outputs")
  11. Produces depth-binned ac-s files formatted for Hydrolight 5.0
  
User Instructions:
  1. Fill out metadata_HeaderFile_acs.txt (as specified below)
  2. Run acsPROCESS_INTERACTIVE.m using Matlab command window.
  3. Select appropriate metadata_HeaderFile_acs.txt file when prompted. 
  4. Select subset of ac-s cast for processing 
    a. Examine time-series plot of ac-s cast (appears automatically). Displays ac-s vertical position (depth) over time (spectrum index).
    b. To select subset of ac-s cast, enter "y" into command window
    c. Select cast subset by entering indices into command window. These can be entered individually (not recommended) or as an array,
    using a colon to separate beginning and end indices (recommended). Data cursor can assist in this process.
    d. Evaluate previously-selected cast subset(s) (highlighted in red). To select an additional cast subset enter repeat steps b-c. 
    e. If satsified with previously-made selection(s) enter "n" into the command window. Re-confirm you are satisfied by entering "y"
    f. If unsatisfied with selections, enter "redo" or "exit" to start over.
  5. Select appropriate pure-water absorption (MAT) file when prompted. (file is created using Purewater_SpecBuilder.m)
  6. Select appropriate pure-water attenuation (MAT) file when prompted. (file is created using Purewater_SpecBuilder.m)
  7. Flag questionable c spetra for possible removal. 
    a. Examine depth profile comparing first 8 ac-s channels (lowest 8 wavelengths) of c spectra. These channels are oriented
    vertically by depth index (not by actual depth), with shallowest index on top.
    b. To create an acceptable range of c values, enter "y" into command window in response to message "Create ACS Limit?" To skip steps
    c-d, enter "n".
    c. Using the command window, enter an upper limit for c, press enter, enter a lower limit for c, and press enter. "0" is good lower
    limit because c is always positive.
    d. Limits are indicated on depth profile by black vertical lines. Enter "y" or "n" into command window to accept limits or try again. 
    e. Any spectrum containing c values outside of user-selected range for channels 1-8 will be automatically flagged. A flagged spectrum
    is indicated by a row of 8 white stars (one on each channel).
    
    
  8. Flag questionable a spetra for possible removal (see step 7)
  9. Evaluate (and potentially discard) flagged c spectra
  10. Evaluate (and potentially discard) flagged a spectra (see step 8)
  
Filling out metadata_HeaderFile_acs.txt:
acsPROCESS_SEABASS relies on metadata_HeaderFile_acs.txt to process ac-s data. All information (excluding pure-water MAT files) should be included in this header. A header template (metadata_HeaderFile_acs.txt) indicating important fields is provided in GitHub acsPROCESS_SEABASS repository. When filling out this header file, the first three headers (indicating user instructions) should be left alone. Required information fields contain = signs. USER SHOULD ONLY ALTER TEXT APPEARING ON THE RIGHT HAND SIDE OF =. User should indicate unavailability of desired information with "NA". DO NOT DELETE ROWS! Below are fields contained in metadata_HeaderFile_acs.txt and instructions on how to fill them out. Spaces should never be used in header fields; use underscore instead (_).

data_file_name= indicate name of ascii file containing unprocessed ac-s data. This file is generated using WET Labs Archive File Processing (WAP) software program, which merges a/c data with CTD data using nearest neighbor approach. Prior to running acsPROCESS_SEABASS, user must open  WAP-generated ascii file and maually indicate Conductivity, Temperature, and Depth column headers inside as follows: COND*, TEMP* and DEPTH*. All other column headers should remain untouched.

data_file_name=pathway for aforementioned WAP-generated ac-s ascii file (data_file_name). This pathway should include the folder in which sits, and should be ended using "/" or "\" for mac and pc respectively. 

affiliations=name of company or research institution with which investigators are affiliated. 

investigators=lists of investigators. Multiple names should be separated by commas and _ should be used in place of spaces.

contact=email of principle investigator

experiment=name of experiment or field campaign 

station=field station number 

latitude=latitude of field station. This should be indicated in decimal form. DO NOT format in minutes or seconds. Do not include Roman letters. South should be indicated with a negative sign.

longitude=longitude of field station. This should be indicated in decimal form. DO NOT format in minutes or seconds. Do not include Roman letters. West should be indicated with a negative sign.

documents=additional documents user wishes to submit to SeaBASS. DO NOT INDICATE kudelalab_ACS_readme.pdf. This is printed automatically in output files.

water_depth=bottom depth of the field station in meters. Numerals only. Do not include units.

calibration_files=names of original ac-s pure-water (DAT) calibration files from which MAT files were generated. Separate with a comma, and do not include spaces. Pure-water absorption file should come first. 

date(yyyymmdd)=indicate date on which ac-s was deployed.

start_time(military_time:HH:MM:SS)=military time at which ac-s cast was initiated. This is indicated in ac-s cast summary file. It should be in GMT.

time_lag(seconds)=elapsed time between cast initiation and data acquisition. This is indicated in ac-s cast summary file.

bin_size=desired depth bin-sizes for binning. User can include as many as he/she wishes.

first_grating=highest chanel number found on ac-s first holographic grating. This can also be thought of as the wavelength index directly before (left side) the "jump" in unprocessed a/c spectra.


Metadata Header File Example:
ac-s metadata template
Template contains information necessary for the processing of ac-s data files (ASCII) merged with CTD data using WetLabs COMPASS software. Use commas to separate names of investigators and files, but DO NOT leave ANY spaces between words. If a space is unavoidable, use an underscore between words (like_this). Unknown or unavailable information should be indicated with NA. Latitude and longitude should be in decimal degrees and water depth should be in meters. Do not include units of measurement. These will be added later by the program. 
#### DO NOT ALTER HEADER FIELDS####
data_file_name=COAST18.012
data_file_path=/Users/JBausell/Documents/acs_data/
affiliations=UC_Santa_Cruz
investigators=Jesse_T_Bausell,_Easter_B_Bunny,Kris_B_Kringle
contact=jbausell@ucsc.edu
experiment=COAST
station=18
latitude=36.889
longitude=-121.874
documents=NA
water_depth=24
calibration_files=watercal_a_111021.dat,watercal_c_111021.dat
date(yyyymmdd)=20111028
start_time(military_time:HH:MM:SS)=20:01:41
time_lag(seconds)=30
bin_size=0.5,1,2
first_grating=41

Bibliography:
Röttgers, R., D. McKee, and S.B. Woźniak, Evaluation of scatter corrections for ac-9 absorption measurements in coastal waters. Methods in Oceanography, 2013. 7: p.21-39.

Sullivan, J.M., et al., Hyperspectral temperature and salt dependencies of absorption by water and heavy water in the 400-750 nm spectral range. Applied Optics, 2006. 45(21): p.5294-5309.  
