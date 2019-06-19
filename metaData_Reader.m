% metaData_Reader
% Jesse Bausell
% May 26, 2019
%
% This matlab script will upload data from a metadata header acs file and
% assign variables to user-input headers as necessary. These metadata are
% used to facilitate the processing of raw ac-s data into Seabass
% submittable or Hydrolight compatible files.

[in_FILE, in_DIR] = uigetfile('.txt'); 
%prompt user to select a file
fid = fopen([in_DIR in_FILE]); 
%opens the file and provides a file identifyer (fid)
for i = 1:3
    % Removes the first three header lines
    fgetl(fid);
end
%% Assign variables to metadata
% in_FILE
linE = fgetl(fid);
eQ = regexpi(linE,'=');
in_FILE = linE(eQ+1:end); %replaces in_FILE with ac-s data (previously metadata file name)
% in_DIR
linE = fgetl(fid);
eQ = regexpi(linE,'=');
in_DIR = linE(eQ+1:end); %replaces in_DIR with ac-s data pathway (previously metadata pathway)
% affiliations
linE = fgetl(fid);
eQ = regexpi(linE,'=');
affiliations = linE(eQ+1:end);
% investigators
linE = fgetl(fid);
eQ = regexpi(linE,'=');
investigators = linE(eQ+1:end);
% contact
linE = fgetl(fid);
eQ = regexpi(linE,'=');
contact = linE(eQ+1:end);
% experiment
linE = fgetl(fid);
eQ = regexpi(linE,'=');
experiment = linE(eQ+1:end);
% station
linE = fgetl(fid);
eQ = regexpi(linE,'=');
station = linE(eQ+1:end);
% latitude
linE = fgetl(fid);
eQ = regexpi(linE,'=');
lat = linE(eQ+1:end);
% longitude
linE = fgetl(fid);
eQ = regexpi(linE,'=');
lon = linE(eQ+1:end);
% document
linE = fgetl(fid);
eQ = regexpi(linE,'=');
doC = linE(eQ+1:end);
% water depth
linE = fgetl(fid);
eQ = regexpi(linE,'=');
D = linE(eQ+1:end);
% calibration files
linE = fgetl(fid);
eQ = regexpi(linE,'=');
cal_FILE_ac = linE(eQ+1:end);
% date
linE = fgetl(fid);
eQ = regexpi(linE,'=');
dat = linE(eQ+1:end);
%start_time
linE = fgetl(fid);
eQ = regexpi(linE,'=');
startTIME = linE(eQ+1:end);
%time_lag
linE = fgetl(fid);
eQ = regexpi(linE,'=');
lag = linE(eQ+1:end);
%depth_BINSIZE
linE = fgetl(fid);
eQ = regexpi(linE,'=');
depth_BINSIZE = str2num(linE(eQ+1:end));
%highest channel, first holographic grating
linE = fgetl(fid);
eQ = regexpi(linE,'=');
grate_IND = str2num(linE(eQ+1:end));
fclose(fid); % Close the metadata file