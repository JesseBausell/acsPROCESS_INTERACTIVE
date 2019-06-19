function [A_pureWater, C_pureWater, wcal_a_infile, wcal_c_infile] = PureWater_Extract3(A_CORR,C_CORR,Tnorm,grate_IND)
% PureWater_Extract
% Jesse Bausell and Jennifer Schulien
% September 9, 2015
%
% PureWater_Extract is a function designed to apply a pure-water
% calibration to ac-s data. The function prompts the user (on command window)
% to upload pure-water calibration spectra for absorption and attenuation
% (separately). These uploaded spectra must be .mat files, each containing
% a  matlab structure named ACS. ACS has the following fields: lambda,
% spectra, T_cal. Each field is a one dimensional array.
%
% PureWater_Extract3 will then correct for holographic gratings, as well as error 
% caused by temperature. This is done using methods described in:
%
% Sullivan et al. (2006). Hyperspectral temperature and salt dependencies
% of absorption by water and heavy water in the 400?750 nm spectral range. 
% Applied Optics 45(21):5394-5309.
% 
% Inputs:
% A_CORR - absorption matrix
% C_CORR - attenuation matrix
% Tnorm - average temperature from ac-s deployment
% grate_IND - highest ac-s channel located on the first (lower) holographic
% grating
%
% Outputs:
% A_pureWater - absorption matrix corrected with pure-water absorption spectrum
% C_pureWater - attenuation matrix corrected with pure-water attenuation spectrum
% wcal_a_infile - name of user-selected .mat file containing pure-water
% absorption spectrum
% wcal_c_infile - name of user-selected .mat file containing pure-water
% attenuation spectrum

%% Select and process pure water absorption/attenuation spectra
fmr_DIR = pwd; % gives provides a spaceholder so that user can return to directory  
breaKER = 0; % this will be a key to break the while loop at the appropriate time

% While loop allows for user to choose and examine apporpriate pure-water
% spectra interactively.
while 1 
    if isequal(breaKER,0)
    %choose a pure-water absorption spectrum
        clc; disp('choose a pure water ABSORPTION (a) file'); %display instructions
        [wcal_a_infile, a_DIR] = uigetfile('.mat'); %instructs user to choose pure-water absorption spectrum
        cd(a_DIR); %changes to directory from which absorption .mat file was chosen
        clc; % clears the screen
        load(wcal_a_infile); % loads the pure-water absorption spectrum and wavelengths
        cd(fmr_DIR); %Reverts back to the program directory
        ACS.spectra = HoloGrater_ACS_4(ACS.lambda,ACS.spectra,grate_IND); %correct for the spectral 'jump'   
        % Visualize the pure-water specrum and allow user to decide whether
        % use or discard it.
        plot(ACS.lambda,ACS.spectra,'r','LineWidth',2) 
        xlabel('\lambda  (nm)','FontSize',15); ylabel('Absorption (m ^-^1)','FontSize',15);
        %text(0.9*length(a_channels(:,rr)),0.8*max(a_channels(:,rr)),['Temp = ' num2str(nanmean(ACS.T_cal)) ' +/-' num2str(nanstd(ACS.T_cal))],'FontSize',16);
        title(['Temp = ' num2str(nanmean(ACS.T_cal)) ' +/- ' num2str(nanstd(ACS.T_cal))],'FontSize',20);
        disp(['Absorption: ' wcal_a_infile]); %displays prompt allowing user to confirm he/she selected right
        y = input('See plot: Is this the right file? (y/n): ','s'); %asks user if he/she is wants to keep pure-water absorption specrum
        if strmatch(y,'y') % If user accepts the absorption spectrum, 
            a_drift_corr = ACS; % Gives new variable name to ACS spectrum 
            breaKER = breaKER+1; % allows the while loop to advance to the next part
        end  
    end
    
    if isequal(breaKER,1)
    %choose a pure-water attenuation spectrum
        clc; disp('choose a pure water ATTENUATION (c) file'); % display instructions
        [wcal_c_infile, c_DIR] = uigetfile('.mat'); % instructs user to choose pure-water attenuation spectrum
        cd(c_DIR);%changes to directory from which attenuation .mat file was chosen
        clc; %clears the command window
        load(wcal_c_infile); % loads the pure-water attenuation spectrum and wavelengths 
        cd(fmr_DIR); %Reverts back to the program directory
        ACS(2).spectra = HoloGrater_ACS_4(ACS(2).lambda,ACS(2).spectra,grate_IND); %correct for the spectral 'jump'
        % Visualize the pure-water specrum and allow user to decide whether
        % use or discard it.
        plot(ACS(2).lambda,ACS(2).spectra,'b','LineWidth',2)
        xlabel('\lambda  (nm)','FontSize',15); ylabel('Attenutation (m ^-^1)','FontSize',15);
        %text(0.9*length(a_channels(:,rr)),0.8*max(a_channels(:,rr)),['Temp = ' num2str(nanmean(ACS.T_cal)) ' +/-' num2str(nanstd(ACS.T_cal))],'FontSize',16);
        title(['Temp = ' num2str(nanmean(ACS(2).T_cal)) ' +/- ' num2str(nanstd(ACS(2).T_cal))],'FontSize',20);
        disp(['Attenuation: ' wcal_c_infile]); %displays prompt allowing user to confirm he/she selected right
        y = input('Is this the right file? (y/n): ','s'); %asks user if he/she is satisfied
    end 
    
    if strmatch(y,'y') % User chooses whether to keep the selected attenuation spectrum. 
    % If not, this part of the code will repeat itself
        c_drift_corr = ACS(2); % Rename the ACS file   
        breaKER = breaKER+1; %break the while statement if user chooses "yes"
        break %redundant, but this also ends the while statement
    end
end

%% Temperature-corrects pure-water spectra and subtract from absorption and attenuation
% To create pure-water calibration files deionized water is typically run 
% through ac-s flow chambers, usually in a laboratory, before or following field
% deployment(s). Because absorption and attenuation are temperature dependent,
% water temperature differences between the laboratory and the field must
% be taken into account before pure-water calibration spectra can be 
% subtracted from field-sampled ac-s data. Sullivan et al. (2006) (see readme) 
% is used to temperature-adjust pure-water calibration spectra using the average
% ambient temperature of ac-s profile(s). These temperature-adjusted 
% pure-water absorption and attenuation calibration spectra are then 
% subtracted from ac-s data.

load('Sullivan_VALUES');  
%loads wavelength-dependent  Sullivan et al. (2006) temperature and salinity adjustment coefficients
A_pureWater = nan(size(A_CORR)); %creates nan matrix to deposit absorption data
C_pureWater = nan(size(C_CORR)); %creates nan matrix to deposit attenuation data

for ii = 1:length(c_drift_corr.lambda) 
    % This for-loop adusts pure-water value 
    temp_DEP_a = sullivan_VALS(a_drift_corr.lambda(ii),Sullivan_VALUES); 
    temp_DEP_c = sullivan_VALS(c_drift_corr.lambda(ii),Sullivan_VALUES);
    % The above function retrieves the Sullivan et al. (2006) temperature  
    % adjustments coefficients for absorption and attenuation for a given
    % wavelength
    
    T_insitu_A = a_drift_corr.T_cal(ii); % Pure-water temperature (absorption calibration)
    T_insitu_C = c_drift_corr.T_cal(ii); % Pure-water temperature (attenuation calibration)
    
    A_pure = a_drift_corr.spectra(ii)-(T_insitu_A - Tnorm)*temp_DEP_a;
    C_pure = c_drift_corr.spectra(ii)-(T_insitu_C - Tnorm)*temp_DEP_c; 
    % Adjusts pure water absorption/attenuation to for temperature
    % differences between the the laboratory and the field in which ac-s
    % data were sampled.
    
    A_pureWater(:,ii) = A_CORR(:,ii) - A_pure; 
    C_pureWater(:,ii) = C_CORR(:,ii) - C_pure; 
    %Subtracts temperature-adjusted pure-water absorption and attenuation
    %from ac-s data.  
end