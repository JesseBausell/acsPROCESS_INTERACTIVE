% acsPROCESS_INTERACTIVE
% Jesse Bausell
% September 13, 2017
%
% This matlab script processes WET Labs ac-s data for submission of NASA's 
% SEABASS data repository. The program requires a metadata header file 
% and pure-water absorption and attenuation specra (see readme). It 
% formats data into SEABASS-submittable .txt files. These contain single
% specra as well as data binned to user specifications (as indicated in
% metadata header file.
%
% Required scripts and functions:
% ACS_dataSNATCH6.m
% ACS_dataFLAGGER6.m
% ACS_depthSELECTOR.m
% ACS_fileREADER_MS.m
% BIN_acDATA.m
% HoloGrater_ACS_4.m
% lambda_INTERPOLATE.m
% metaData_Reader.m
% PureWater_Extract3.m
% salinityCOND.m
% sullivan_VALS.m
% 
% Required data files:
% Seabass_header_ACS5.mat
% Sullivan_VALUES.mat

clear; close all; clc;

ACS_fileREADER_MS;
% This program will read a WetLabs ac-s data file into our program. It
% produces raw absorption and attenuation matrices, as well as temperature,
% salinity, and depth arrays.

% Before any subsequent steps, user will select the subsets of the ac-s
% multicast that he/she wants to process (below). 
[deptH_IND, deptH] = depthSELECTOR(deptH); % subset cast depths & indices

% Index matrices and arrays associated with depth
A_CORR = A_CORR(deptH_IND,:); % depth-subset of absorption
C_CORR = C_CORR(deptH_IND,:); % depth-subset of attenutation
S_insitu = S_insitu(deptH_IND); % depth-subset of salinity
T_insitu = T_insitu(deptH_IND); % depth-subset of temperature
C_insitu = C_insitu(deptH_IND); % depth-subset of conductivity
time_insitu = time_insitu(deptH_IND); % depth-subset of time (seconds)

% Final piece of this section is to order all variables according to depth
% (instead of time).
[deptH, deptH_sort] = sort(deptH); 
A_CORR = A_CORR(deptH_sort,:); % sort absorption by depth
C_CORR = C_CORR(deptH_sort,:); % sort attenutation by depth
S_insitu = S_insitu(deptH_sort); % sort salinity by depth
T_insitu = T_insitu(deptH_sort); % sort temperature by depth
C_insitu = C_insitu(deptH_sort); % sort conductivity by depth
time_insitu = time_insitu(deptH_sort); % sort time (seconds) by depth


%%   1. Performs holographic grating correction
% WetLabs ac-s takes measurements using two holographic gratings. Its 87-89
% channels are partitioned onto these gradients, which take measurements
% asynchronously. This can cause an artifact in raw ac-s spectra, exhibited
% as a "jump" in individual spectrum. This section of code corrects for
% this jump. It also collects the offsets that are interpolated in order to
% correct spectra.

diFF_C = nan(length(deptH),1); % Nan array to deposit attenuation offsets 
diFF_A = nan(length(deptH),1); % Nan array to deposit absorption offsets 

for hh = 1:length(deptH) 
    % Corrects holographic grating artifact for each individual
    % absorption/attenuation spectrum
    [C_CORR(hh,:), diFF_C(hh)] = HoloGrater_ACS_4(c_wv,C_CORR(hh,:),grate_IND); %attenuation
    [A_CORR(hh,:), diFF_A(hh)] = HoloGrater_ACS_4(a_wv,A_CORR(hh,:),grate_IND); %absorption
end
    
%%   2. Subtracts pure water values 
% This section corrects ac-s spectra by substracting pure water absorption
% and attenuation spectra from measured spectra.


[A_CORR, C_CORR, wcal_a_infile, wcal_c_infile] = PureWater_Extract3(A_CORR,C_CORR,nanmean(T_insitu),grate_IND);
% This line of code subtracts pure water a and c from ACS spectra. It
% prompts the user to choose two .mat files (absorption & attenuation spectra 
% averaged from ACS pure water instrument calibration files (.dat). The program than normalizes them to a
% temperature of 15 degrees C and subtracts them (original temperature is
% included in the .mat files).

%%   3. Performs Sullivan et al. temperture and salinity corrections
% Absorption and attenuation are impacted by temperature and salinity. 
% Sullivan et al. (2006) (see readme) provides temperature adjustment coefficients
% (used in the function PureWater_Extract3), as well as salinity adjustment 
% coefficients for absorption and attenuation spectra. Salinity adjustment
% coefficients assume an ambient water temperature of 15 degrees (C).
% Using Sullivan et al. (2006), ac-s data are adjsuted to a standard
% temperature of 15 degrees, salinity corrected, and then re-adjusted to
% the average ambient water temperature in which they were sampled.

Tnorm = 15; %standard water temperature temperature for salnity adjustement.
load('Sullivan_VALUES');  %load sullivan parameters

for ii = 1:length(c_wv) 
    % This loop normalizes absorption and attenuation data one wavelength
    % at a time. 
       
    [temp_DEP_a, salt_DEP_a] = sullivan_VALS(a_wv(ii),Sullivan_VALUES);
    [temp_DEP_c, salt_DEP_c, salt_DEP_c] = sullivan_VALS(c_wv(ii),Sullivan_VALUES);
    % The above function retrieves the Sullivan et al. (2006) temperature  
    % and salinity adjustment coefficients for absorption and attenuation 
    % for a given wavelength. Because absorption and attenuation
    % wavelengths are different, the program is run for each one
    % separately.
    
    C_tNORM = C_CORR(:,ii)-(T_insitu - Tnorm)*temp_DEP_c;
    A_tNORM = A_CORR(:,ii)-(T_insitu - Tnorm)*temp_DEP_a;
    % Adjust absorption and attenuation to a temperature of 15 degrees C
    % using Sullivan et al. (2006) adjustment coefficients.
    
    C_tNORM1 = C_tNORM - S_insitu*salt_DEP_c;
    A_tNORM1 = A_tNORM - S_insitu*salt_DEP_a;
    % Salinity-adjust absorption and attenuation using salinity measured 
    % by the ac-s CTD.
    
    C_tNORM2 = C_tNORM1-(Tnorm-T_insitu)*temp_DEP_c;
    A_tNORM2 = A_tNORM1-(Tnorm-T_insitu)*temp_DEP_a;
    % Re-adjust absorption and attenuation back to the original temperature
    % in which ac-s was deployed.
    
    C_CORR(:,ii) = C_tNORM2;
    A_CORR(:,ii) = A_tNORM2;
    % Replace absorption and attenuation matrices with salinity-corrected
    % data.
    
end

%%   4. Performs Rottgers et al. scattering correction. 
% ac-s measurements are subject to scattering-induced errors which can
% inflate field-sampled absorption. Absorption data are corrected for these
% errors using methods described in Rottgers et al. (2013) (see readme)

a_m715_INT = nan(length(deptH),1); 
c_m715_INT = nan(length(deptH),1);
% Creates nan array to place absorption and attenuation interpolated at
% a wavelength of 715 nm.

    for ii = 1:length(deptH)
    % Interpolate absorption and attenuation to wavelength of 715 nm (a715).
       a_m715_INT(ii) = lambda_INTERPOLATE(a_wv,A_CORR(ii,:),715); %absorption
       c_m715_INT(ii) = lambda_INTERPOLATE(c_wv,C_CORR(ii,:),715); %attenuation
       C_CORR(ii,:) = lambda_INTERPOLATE(c_wv,C_CORR(ii,:),a_wv); % interpolate attenuation with absorption wavelengths
    end

% Remove negative a715 values in order to prevent them from later becoming
% imaginary. Here they are replaced by NaNs.
a_715_IND = find(a_m715_INT < 0); %Find index of negative a715
a_m715_INT(a_715_IND) = NaN; % Replace negative values with NaN.

% Create variables for Rottgers et al. (2013) equations
e_c_INVERSE = 1; %constant in the correction equation (1/ec)
a_715 = 0.212*(a_m715_INT.^1.135); % Adjusts asorption at 715nm to account for scatter

% denominator component for Rottgers scatter correction equation
deNOM = (e_c_INVERSE*c_m715_INT-a_m715_INT); 

for ii = 1:length(a_wv) 
    % Correct absorption for scatter-related errors by wavelength usign
    % Rogttgers et al. (2013)'s scatter correction method, Equation 2b.
    A_CORR(:,ii) = A_CORR(:,ii) - (a_m715_INT-a_715).*((e_c_INVERSE*C_CORR(:,ii)-A_CORR(:,ii))./deNOM);
end

% Create referece variables for time and depth before they are altered.
deptH2 = deptH; % Create an alternate depth variable. Important in time stamp ID
time_insitu2 = time_insitu; % Create an alternate time index. Important in time stamp ID

% As explained above, absorption spectra for which a715<0 were eliminated
% before Rottgers correction was applied. Because each absorption spectrum
% has a corresponding depth and attenuation, depths and attenuations which
% correspond to eliminated absorption spectra must also be flagged and
% removed.
A_CORR(a_715_IND,:) = []; % Remove corresponding absorption spectra
C_CORR(a_715_IND,:) = []; %Remove corresponding attenuation spectra 
deptH(a_715_IND) = []; %Remove corresponding depth
time_insitu(a_715_IND) = []; %Remove corresponding time

%%   5. Interactively determine which spectra to keep and which to discard
% In this section the user must flag questionable ACS data (both a and c).
% This requires going through all wavelengths below 700 (but including 715)
% and determining what gets flagged and what does not.

intITR = floor(length(find(a_wv<715))/8); 
% Determines how many iterations to run interactive for-loop (nested in
% this section)

booL = A_CORR(:,intITR) > C_CORR(:,intITR); % Find where absorption > attenuation
booL_max = max(booL,[],2); % Find spectra where absorption > attenuation
% Find indices at which absorption < 0 or greater absorption > attenuation

[aERR_y, aERR_x] = find(booL_max > 0); % Find instances of attenuation greater than absorption
A_CORR(aERR_y,:) = []; % Remove these above-mentioned spectra from absorption...
C_CORR(aERR_y,:) = []; % attenuation  
deptH(aERR_y) = []; % depth
time_insitu(aERR_y) = []; % time
diFF_C(aERR_y) = [];
diFF_A(aERR_y) = [];


for ii = 1:2
    % This for loop lets user flag questinable data. First time around
    % script examines attenuation and the second time around it focusses on
    % absorption. We do this because we want to gauge absorption values based 
    % on attenuation maxima.
    
    % If statement below sets parameters for matlab function ACS_dataFLAGGER6
    if isequal(ii,2)
        % The second time through the for-loop, set ACS_dataFLAGGER6 inputs
        % for absorption.
        ACS_KEY = 'a'; 
        ACS_MAT = A_CORR; 
        lambdA = a_wv;
        flaggedROWS = NaN;
        x_m715 = a_m715_INT;
    else
        % The first time through the for-loop, set ACS_dataFLAGGER6 inputs
        % for attenuation.
        ACS_KEY = 'c';
        ACS_MAT = C_CORR;
        lambdA = c_wv;        
        flaggedROWS = NaN;
        x_m715 = c_m715_INT;
    end
    
    
    for jj = 1:intITR
        % For each iteration, systematically move up the absorption
        % spectrum to flag data (400 to 700nm).

        starT = (jj-1)*8+1;
        stoP = jj*8;
        %Indexes for ac-s channels (columns) and wavelenghts

        if ~isequal(jj,intITR)
            % If this is NOT the last iteration of the for-loop
            lambdA_subset = a_wv(starT:stoP); % Subset 8 wavelenghts
            ACS_MAT_subset = ACS_MAT(:,starT:stoP); % Subset absorption/attenuation data
        else
            % If this IS the last iteration of the for-loop
            lambdA_subset = [a_wv(starT:stoP-1) 715]; % Subset wavelenghts plus 715 nm
            ACS_MAT_subset = [ACS_MAT(:,starT:stoP-1) x_m715];
            % Create a subset of ACS data to use in the data flagging
            % program.
        end
            flaggedROWS = ACS_dataFLAGGER6(ACS_MAT_subset,lambdA_subset,flaggedROWS,ACS_KEY);
            % This program flags data according to user preferences.
    end
              
    if isequal(ii,2)
        % Give indices of flagged rows their own variable name depending
        A_flagged = flaggedROWS; % absorption
    else
        C_flagged = flaggedROWS; % attenuation
    end
        
end

%%   6. Determine whether or not to discard flagged rows
% After user flags questionable spectra, he/she determines whether to
% discard them by looking at the spectra

max_2BIN = ceil(max(deptH)); % Create a max integer for 2 m depth bin
if rem(max_2BIN,2) > 0
    % If max integer is odd, add 1 to make it even
    max_2BIN = max_2BIN + 1;
end

% Confirm intention to discard flagged absorption and attenuation spectra
C_flagged = ACS_dataSNATCH6(C_CORR,deptH,C_flagged,a_wv,{0:2:max_2BIN},'c',1); 
A_flagged = ACS_dataSNATCH6(A_CORR,deptH,A_flagged,a_wv,{0:2:max_2BIN},'a',1);

for cc = C_flagged'
    % for-loop eliminates redundancy in flagged absorption and attenuation
    % spectra. 
    IND = find(A_flagged == cc); 
    if ~isempty(IND) 
        % if a flagged attenuation specrum is also a flagged absorption spectrum
        A_flagged(IND) = []; % Eliminate flagged index in absorption 
    end
end

% Eliminate flagged ac spectra
totaL_flagged = sort([A_flagged; C_flagged]); % Combine and order absorption and attenuation flagged spectra
diFF_C(totaL_flagged) = [];
diFF_A(totaL_flagged) = [];
C_CORR(totaL_flagged,:) = [];
A_CORR(totaL_flagged,:) = [];
deptH(totaL_flagged) = [];
time_insitu(totaL_flagged) = [];
%%  7. Write data into .mat/hdf file and binned Hydrolight-compatible files

lambda = a_wv; % Reset a_wv (absorption wavelength) as lambda
save([in_DIR experiment '_' station  '_acs'],'C_CORR','A_CORR','deptH','lambda','-v7.3');
BIN_acDATA_HE53; % Bin ac-s data and print it in Hydrolight-compatible .txt files
