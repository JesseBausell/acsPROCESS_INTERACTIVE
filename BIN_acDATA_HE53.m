% BIN_acDATA_HE53
% Jesse Bausell
% July 7, 2018
%
% This program takes processed seabass data and depth-bins it into
% user-selected bin sizes. It then builds Seabass submitable files
% containing binned average absorption and attenuation spectra, along with
% their standard deviations. 

        
%% 1. Depth-bin ac-s data according to user-specified bin sizes.
% In this section of code, ac-s data are binned using the different
% binsizes that the user selects.

% Ready the binning by providing the necessary arrays to hold binned data.
% Each of the two cell arrays contains a cell for each binsize. Absorption
% and attenuation data will be split up and placed inside two different
% arrays, with each cell within an holding the binned data plus depth bin
% medians.
binned_CELLS_c = cell(1,length(depth_BINSIZE)); %Holds binned attenuation data
binned_CELLS_a = cell(1,length(depth_BINSIZE)); %Holds binned absorption data
binned_deptH = cell(1,length(depth_BINSIZE)); % Holds binned depth data

max_DEPTH = ceil(max(deptH)); % Maximum depth of the ac-s 
[v,h] = size(C_CORR); % Dimensions of absorption/attenuation matrix (they are the same size)

for ii = depth_BINSIZE
    % For each user-selected depth binsize create matrices for absorption
    % and attenuation. First column is the depth bins, followed by
    % bin-averaged absorption/attenuation spectra, followed by
    % absorption/attenuation standard deviations.

    % For each cell, create nan matrices for all of the binned mean and
    % standard deviations cell.
    BINNED_MAT_c = nan(ceil(max_DEPTH/ii),h+1);
    BINNED_MAT_a = nan(ceil(max_DEPTH/ii),h+1); 

    for jj = 0:ii:max_DEPTH-ii
        % This for loop fills the empty nan matrix
        vert_IND = length(0:ii:jj); % vertical index for BINNED_MAT
        BINNED_MAT_c(vert_IND,1) = (jj+jj+ii)/2; %Insert binned depth
        BINNED_MAT_a(vert_IND,1) = (jj+jj+ii)/2; %Insert binned depth
        % The following four lines bin absorption and attenuation
        BIN_IND = find(deptH >=jj & deptH <jj+ii); % Find appropriate depth bin
        BINNED_MAT_c(vert_IND,2:h+1) = nanmean(C_CORR(BIN_IND,:),1); %binned attenuation avg
        %BINNED_MAT_c(vert_IND,h+2:2*h+1) = nanstd(C_CORR(BIN_IND,:),0); %binned attenuation std
        BINNED_MAT_a(vert_IND,2:h+1) = nanmean(A_CORR(BIN_IND,:),1); %binned absorption avg
        %BINNED_MAT_a(vert_IND,h+2:2*h+1) = nanstd(A_CORR(BIN_IND,:),0); %binned absorption std
    end
    nNAN_IND = find(~isnan(BINNED_MAT_a(:,2))); % Find any NaN rows in matrices
    binned_CELLS_c{ii == depth_BINSIZE} = BINNED_MAT_c(nNAN_IND,:); % Extract NaNs from attenuation
    binned_CELLS_a{ii == depth_BINSIZE} = BINNED_MAT_a(nNAN_IND,:); % Extract NaNs from absorption
end

%% 2. Write binned absorption and attenuation .txt files for Seabass submission
% At this point, BIN_acDATA has formulated headers for binned absorption
% and attenuation data, as well as the binned data itself. Now it is time
% to combine headers with binned ac-s data and write the data files in
% Seabass-compatible format.
 
for kk = depth_BINSIZE
    % Create binned data files for each user-specified bin size.
    fid_acs = fopen([in_DIR experiment '_' station '_ac-s_bin_' num2str(kk)  '.txt'],'w'); %create binned attenuation .txt file
    % Header lines 1-9. Hydrolight requires 10 header rows.
    fprintf(fid_acs,'%s\n','Total absorption (a) and attenuation (c) measurements');
    fprintf(fid_acs,'%s\n',['Corrected: ' datestr(clock)]);
    fprintf(fid_acs,'%s\n','Instrument: ac-s & ac-9');
    fprintf(fid_acs,'%s\n',['File name: ' in_FILE]);
    fprintf(fid_acs,'%s\n',['Pure water Abs: ' wcal_a_infile]);
    fprintf(fid_acs,'%s\n',['Pure water Atten: ' wcal_c_infile]);
    fprintf(fid_acs,'%s\n','C-interpolated: yes');
    fprintf(fid_acs,'%s\n',['bin=' num2str(kk)]);
    fprintf(fid_acs,'%s\n','Data have been processed using code written and made avaiable by Jesse Bausell (email: jbausell@ucsc.edu, GitHub: JesseBausell).');

    % Begin header row 10, which holds 'Depth' and column headers
    fprintf(fid_acs,'%s\t','Depth'); % Start by printing Depth and a tab delimiter
    IOP = {'a','c'}; % Letters to go infront of wavelength numbers in the 10th column header
    formatSPC = '%4.2f\t'; % First format specifier (Depth) for the format specifier string    
    for ii = 1:2
        % This for-loop assembles the format specifiers that will be used
        % to print the data into Hydrolight-compatible text files. It also
        % prints the column headers onto the aforementioned text file.
        for jj = lambda
            % This for-loop creates a series of IOP headers (a & c) with
            % corresponding wavelengths. It also assembles the format
            % specifiers (twice)
            if isequal(ii,2) && isequal(jj,lambda(end));
                % Arrive at the last header column (end the line)
                fprintf(fid_acs,'%s\n',[IOP{ii} num2str(jj)]); % print IOP headers w end of line char
                formatSPC = [formatSPC '%8.6f\n']; % print format specifiers with end of line character
            else
                % All other header columns
                fprintf(fid_acs,'%s\t',[IOP{ii} num2str(jj)]); % print IOP headers w tab
                formatSPC = [formatSPC '%8.6f\t']; % print format specifiers with end of line character
            end
        end
    end

    % Begin 11th line
    fprintf(fid_acs,'%s\t',num2str(length(lambda))); % Print number of channels/wavelengths
    for jj = lambda
        % This for-loop again cycles through wavelengths. It prints
        % wavelength values onto the 11th header line. It does so one value
        % at a time.
        if isequal(jj,lambda(end))
            % At the last wavelength
            fprintf(fid_acs,'%s\n',num2str(jj)); %print with end of line character
        else
            % At all other wavelengths
            fprintf(fid_acs,'%s\t',num2str(jj)); % print with tab
        end
    end
    [l_bm, w_bm] = size(binned_CELLS_c{kk==depth_BINSIZE}); % Get dimensions of 
    % Construct ac-s data matrix (line below), consisting of binned depths (medians),
    % binned absorptions, and binned attenuations.
    BINNED_MAT = [binned_CELLS_a{kk==depth_BINSIZE} binned_CELLS_c{kk==depth_BINSIZE}(:,2:w_bm)]; % Create variable with binned attenuation data matrix
    
    for ll = 1:l_bm
        % Print ac-s data matrix into the hydrolight-compatible .txt file.
        fprintf(fid_acs,formatSPC,BINNED_MAT(ll,:));
    end
    fclose(fid_acs); % Close .txt file
end
