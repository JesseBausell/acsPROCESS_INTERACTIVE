% ACS_fileREADER_MS
% Jesse Bausell
% December 1, 2016
%
%
% This matlab script reads in WetLabs ac-s data files that are merged
% using compass. Compass uses 'nearest neighbor approach' to match
% absorption and attenuation data with concurrently sampled CTD data.

metaData_Reader;
%prompt user to select a the metadata file. This file has important
%information that will be used later on

fid = fopen([in_DIR in_FILE]); 
%opens the file and provides a file identifyer (fid)

linE = fgetl(fid);
%saves the header line  as a string array (header string). This will be used to locate,
%classify, and sort the various columns in our data matrix, once the data
%is written into matlab.


linE = regexprep(linE,'(',''); linE = regexprep(linE,')',''); 
%the header string contains quotation marks. These prevent indexing. This
%line gets rid of them in order to make indexing possible.

abs_IND = regexpi(linE,'[a]\d{3}[.]\d'); %find a###.# (absorption) position in header string
atten_IND = regexpi(linE,'[c]\d{3}[.]\d'); %find c###.# (attenutation) position in header string
Time_IND = regexpi(linE,'time'); %finds time column position in header string
num_IND = regexpi(linE,'\<[0-9]\w*[.]\w*[0-9]\>'); %finds columns headed by numbers (temp, depth, salinity)
word_IND = regexpi(linE,'\<[a-sA-Su-zU-Z]\w*\w*[a-zA-Z]\>'); %finds columns headed by words other than TIME (used to determine number fo columns)
cond_IND = regexp(linE,'COND*'); % finds position of 'COND*' in the header string
temp_IND = regexp(linE,'TEMP*'); % finds position of 'TEMP*' in the header string
depth_IND = regexp(linE,'DEPTH*'); % finds position of 'DEPTH*' in the header string

title_MAT = sort([Time_IND regexpi(linE,'\t')+1]); 
% Finds the start of all of the column headers (in header string)

txtscn_fodder = []; 
%empty string array in which to place format specifiers (e.g. %f %s etc.)


for ii = 1:length(title_MAT) 
% This for loop (ending on line 86 goes through variable title_MAT. It uses
% the category of a given header (column 2) to select a conversion
% specifier for it. It adjusts the number of specifiers (used in textscan)
% based on the number of columns in the original text file.
    
    if isequal(title_MAT(ii),Time_IND) %'Time' column
        txtscn_fodder = [txtscn_fodder '%10f']; %floating numbers, no decimals
    else %every other column besides time (e.g. a,c,t,s,z)
        txtscn_fodder = [txtscn_fodder '%8.5f']; %floating numbers (not time), 5 decimals
    end
    
    if isequal(ii,length(title_MAT)) % when the last column is reached        
        txtscn_fodder = [txtscn_fodder '%*[^\n]']; % add an end-of-lien character
    else
        txtscn_fodder = [txtscn_fodder '%*8.5f']; % corrects a programing glitch in compass
    end
    
end

abs_MATRIX = textscan(fid,txtscn_fodder,'Delimiter','\t'); 
% reads in data from ACS file of interest. abs_MATRIX contains ALL columns 

fclose(fid); 
%closes text file. Text file is already loaded onto a cell array and we
%don't need the file anymore.

C_CORR = nan(length(abs_MATRIX{1}),length(atten_IND)); %Nan matrix for raw attenuation
A_CORR = nan(length(abs_MATRIX{1}),length(abs_IND)); %Nan matrix for raw absorption
[l_AC, w_AC] = size(A_CORR); % measure dimensions of absorption/attenuation data
a_wv = nan(1,w_AC); %Nan array for absorption wavelenths
c_wv = nan(1,w_AC); %Nan array for attenuation wavelengths
% These are empty variables with which to place data

% Locate absorption, attenuation, and wavelengths from data file
for gg = 1:w_AC
    C_CORR(:,gg) = abs_MATRIX{:,title_MAT==atten_IND(gg)}; %place attenuation values in matrix
    A_CORR(:,gg) = abs_MATRIX{:,title_MAT==abs_IND(gg)}; %place absorption values in matrix
    a_wv(gg) = str2double(linE(abs_IND(gg)+1:abs_IND(gg)+5)); %fill in absorption wavelengths
    c_wv(gg) = str2double(linE(atten_IND(gg)+1:atten_IND(gg)+5)); %fill in attenuation wavelengths
end

% Find single column variables: time, conductivity, temperature, & depth
time_insitu = abs_MATRIX{Time_IND}; %gives us the time in milliseconds
C_insitu = abs_MATRIX{:,title_MAT==cond_IND}; % fill in in-situ conductivity
T_insitu = abs_MATRIX{:,title_MAT==temp_IND}; % fill in in-situ temperature
deptH = abs_MATRIX{:,title_MAT==depth_IND};   % fill in in-situ pressure (depth)

S_insitu = salinityCOND(T_insitu,C_insitu,deptH); 
%calculate salinity using temperature, conductivity, and depth (pressure)

time_insitu = (time_insitu - time_insitu(1))/1000; 
% convert milliseconds into seconds with the first time eqaualling zero
    

