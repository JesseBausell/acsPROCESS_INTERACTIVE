function flaggedROWS_verified = ACS_dataSNATCH6(HS6_data,deptH,flaggedROWS,lambdA,biNS,ACS_KEY,ind_KEY)
% ACS_dataSNATCH6
% Jesse Bausell
% November 24, 2016
%
% Based off of the program HS6_dataSNATCH2, except for ac-s data. Principles
% are the same.
%
% This program takes HS6 data that has already been flagged. It looks at
% all of the previously flagged HS6 rows and compares them with all other
% data in their respective bins, as well as the bin directly above and
% below their respective bins. Once the user decides which flagged bins to
% keep, discard, and edit, HS6_dataSNATCH bins all data according to
% pre-selected bins (while allowing the user to see them all).
%
% Inputs:
% HS6_data - sigma-correct data from the HS6
% deptH - array of depths corresponding with HS6_data
% flaggedROWS - indices of the rows that the user previously flagged
% lambdA - wavelenghts associated with HS6 channels
% biNS - the bin array pre-selected by the user.
%
% Outputs:
% flaggedROWS_verified

IND_715 = find(lambdA < 715);
IND_715 = IND_715(end);
if strcmpi(ACS_KEY,'a')
    % Allows us to differentiate between absorption and attenuation
    % data.
    y_word = 'Absorption';
elseif strcmpi(ACS_KEY,'c')
    y_word = 'Attenuation';
else
    error('ACS_KEY must be a or c');
end

%% 1. Create variables to be used down the road and create bined depth arrays

HS6_data_UNFLAGGED = HS6_data; HS6_data_UNFLAGGED(flaggedROWS,:) = [];
deptH_UNFLAGGED = deptH; deptH_UNFLAGGED(flaggedROWS) = [];
% These lines create copies of the primary data variables WITHOUT flagged
% data in them. This will be used when plotting the data at different depth
% bins.

deptH_BINNED = cell(1,length(biNS)+1); 
%Creates a cell array in which to put different depth bins

deptH_BINNED{1} = deptH;
%Designate the first cell for unbinned depths

HS6_data_BINNED = cell(1,length(biNS)+1);
%Creates a cell array in which to put data binned to different depths

HS6_data_BINNED_STD = cell(1,length(biNS)+1);
%Creates a cell array in which to put standard deviations of data binned
% to different depths

for hh = 1:length(biNS)
    
    deptH_BINNED{hh+1} = nan(length(biNS{hh})-1,1);
    % Create a nan array that will become our binned depths.

    for ii = 1:length(biNS{hh})-1
        % Create medians of each depth bin. These will be used in the eventual binning as
        % well as in evaluating the flagged rows, relative to their bins. 

        deptH_BINNED{hh+1}(ii) = median(biNS{hh}(ii:ii+1));
        % Find the median of each depth bin. 
    end
end

%% 2. Evaluate each flagged row.

for jj = 1:length(flaggedROWS)
    % This for loop will evaluate all flagged rows and let the user
    % determine whether or not to discard them or edit them. Version 6
    % (this version) has a built in feature to allow the user to choose
    % which bin gets QA/QC'd. It will go let user evaluate flagged rows one 
    % at a time

    % Finds which depth bin the flagged row belongs to using nearest
    % neighbor approach (from depth bin median)
    diFF = abs(deptH(flaggedROWS(jj))-deptH_BINNED{ind_KEY+1}); % distance from each median 
    keY = find(diFF == min(diFF)); % Index minimum depth difference (flagged depth - binned medians)
    keY = keY(1); % choose the first depth bin median if it is equidistant from two
       
    if isequal(keY,length(deptH_BINNED{ind_KEY+1})) % if-statement to design subplots
        % If flagged spectrum is in the bottom depth bin (two plots)
        l = 2; jumP = 0; 
        % Two plots for bottom bins. jumP one backward
    elseif isequal(keY,1) 
         % If flagged spectrum is in the top depth bin (two plots)
        l = 2; jumP = 1;
    else
        % If flagged spectrum any other depth bin
        l = 3; jumP = 0;
    end
      
    while 1
      % This while loop will allow user to continue plotting the same
      % data until the loop is broken by a user command (e.g. discard, keep,
      % or edit).       
        figure(1) % Denotes that upcoming figure is figure 1.
      
        for kk = 1:l
            % This for-loop plots figure 1, one subplot at a time
            subplot(l,1,kk); % Determines dimension of subplot           
            UNFLGD_IND = (deptH_UNFLAGGED >= biNS{ind_KEY}(keY + kk - 2+jumP) & ...
              deptH_UNFLAGGED < biNS{ind_KEY}(keY + kk -1+jumP));
            % Finds the range of depth indices (and hence data) that fall
            % within our depth bin (above).                          
            hold on % Plot multiple items on the same graph     
            [a,b] = size(HS6_data_UNFLAGGED(UNFLGD_IND,:));
            % Find the dimensions of the data matrix that falls within
            % our bin (above).
            UNFLAGGED_TEMP_HS6 = HS6_data_UNFLAGGED(UNFLGD_IND,:);
            % Index specta inside the bin of interest.

            if isempty(UNFLAGGED_TEMP_HS6)
                % Should there be no spectra inside the depth bin of
                % interest, create a dummy spectrum with NaN's. This
                % ensures the function keeps running.
                UNFLAGGED_TEMP_HS6 = nan(1,length(lambdA));
            end

            if isequal(a,length(lambdA))
                % If we have a square matrix (e.g. same number of spectra as
                % wavelengths), it is necessary to re-orient the data
                % matrix when plotting to ensure that data are oriented
                % correctly.
                h1 = plot(lambdA,UNFLAGGED_TEMP_HS6','b'); % Plot individual specta      
            else
                % If we do not have a square matrix....
                h1 = plot(lambdA,UNFLAGGED_TEMP_HS6,'b');
            end

            morE = nanmean(UNFLAGGED_TEMP_HS6,1) + 3*nanstd(UNFLAGGED_TEMP_HS6); % Upper bin limit (mean + 3*std)
            lesS = nanmean(UNFLAGGED_TEMP_HS6,1) - 3*nanstd(UNFLAGGED_TEMP_HS6); % Lower bin limit (mean - 3*std)
            h2 = plot(lambdA,morE,'.-k','LineWidth',3); % Plot the upper maximum range (mean + 3*std)
            h3 = plot(lambdA,lesS,'.-k','LineWidth',3); % Plot the lower maximum range (mean + 3*std)
            h4 = plot(lambdA,HS6_data(flaggedROWS(jj),:),'r','LineWidth',2.5); % Plot the flagged data row
            set(gca,'XTick',400:25:700,'XLim',[400 710]); % Sets a consistent x axis for each graph
            title(['bin = ' num2str(biNS{ind_KEY}(keY + kk - 2+jumP)) '-' num2str(biNS{ind_KEY}(keY + kk -1+jumP)) 'm'],'FontSize',12);
            text(450,0.85*max(HS6_data(flaggedROWS(jj),:)),['depth = ' num2str(deptH(flaggedROWS(jj)))],'FontSize',16,'BackgroundColor',[.7 .7 .7]);
            % Lets user know which depth each graph is at.

            % The below if-statement deals with subplot data labels
            if isequal(kk,1)
                % For the the top subplot
                LEG = legend([h1(1) h2 h4],'ACS data','ACS Boundaries', ...
                  'Flagged data','Location','northeast'); % Add legend                   
                set(LEG,'FontSize',12) % set font to 12
            elseif isequal(kk,2) 
                % Middle (second) plot
                ylabel([y_word ' (m^-^1)'],'FontSize',12);
            elseif isequal(kk,l)
                % Bottom plot (whichever plot that is)
                xlabel('\lambda','FontSize',12);         
            end
            hold off; %Stop plotting on Figure 1
        end

        while 1
            % Inner while loop that is responsible for controlling
            % the questions being asked.

            % Ask user what to do with flagged spectrum: keep, discard,
            % or edit
            disp('Select an option: Keep, Discard, or Edit'); % display text
            Que = input('Option: ','s'); % User inputs answer

            if strcmpi(Que,'Discard')
                % User choses to discard flagged row
                Que2 = input('Are you sure you want to DISCARD this spectrum? (y/n)','s'); % User confirms previous response               
                 if strcmpi('y',Que2)
                     % User verifies yes.
                    cranK = 0;
                    % Tells the program to break the outer while loop
                        close all; % Close the figure
                        break %break the inner while loop
                 else 
                     % User says no or doesn't answer properly
                      disp('Try again.'); % displays "try again"
                      % Takes user back the original question of
                      % whether to keep, edit, or discard. While
                      % loop is kept intact.
                 end
                 
            elseif strcmpi(Que,'Keep')
                % User opts to keep the flagged spectrum
                Que3 = input('Are you sure you want to KEEP this spectrum? (y/n)','s');
                    % Asks the user to make sure.
                  if strcmpi('y',Que3)
                      % User opts to keep the spectrum
                      flaggedROWS(jj) = NaN;
                      % Eliminates the row index from the array
                      % (this will prevent it from being discarded
                      % later on)
                      cranK = 0;
                      % Tells the program to break the outer loop.
                        close all; %close the figure
                        break % break the inner while loop
                  else
                      % User doens't answer yes or no
                      disp('Try again');
                      % User gave a bad answer.
                  end

            elseif strcmpi(Que,'Edit')
                % User opts to edit the HS6 row instead of outright
                % keeping or discarding it.
                    wavE = input('Enter wavelength to edit out: ');
                    % User enters a wavelength value at or near to the
                    % one he/she wants to eliminate
                    smaLL_ARRAY = abs(lambdA - wavE);
                    % Find the wavelength closest to the entered
                    % value
                    IND = find(smaLL_ARRAY == min(smaLL_ARRAY));
                    % Finds the index of that wavelength

                    figure(2)
                    hold on
                    h4 = plot(lambdA,HS6_data(flaggedROWS(jj),:),'r','LineWidth',2.5); 
                    % Plot the flagged data row
                    scatter(lambdA(IND),HS6_data(flaggedROWS(jj),IND),'*g','LineWidth',3);
                    % This scatter will plot the point to be
                    % discarded so that user can make sure that
                    % it's the right one.    
                    set(gca,'XTick',400:25:700,'XLim',[400 710]); 
                    % Sets a consistent x axis for each graph
                    Que4 = input('Permanently discard the enumerated data point? (y/n)','s');
                    % After seeign the selected data point, user
                    % gets to make sure he/she wants to get rid
                    % of it.
                    if strcmpi('y',Que4)
                        HS6_data(flaggedROWS(jj),IND) = NaN;
                        % Data point is replaced in the matrix
                        % with NaN.
                        disp('Data point discarded');
                        % User is informed that the data point
                        % is discarded.
                        cranK = 1;
                        % The program will not break the outer
                        % loop and will cycle once more.
                        close all; 
                        % Close graph and make program give use
                        % another one.
                        break
                        % Breaks the inner loop
                    else
                        % User does not say "yes"
                        disp('Data point kept');
                        % User is informed that the data point
                        % is kept.
                    end
            else
                % User said something other than Keep, Discard, or
                % Edit.
                disp('Invalid Entry. Try again');
                % Informs the user that he/she fucked up. Inner
                % loop is not broken.
            end
        end

        if isequal(cranK,0)
            % If the user selected discard or keep, the outer while
            % loop will break and the user will advance to the next
            % flagged HS6 data row.
            break
            % Break the outer while loop.
        end         
    end
end

flaggedROWS_verified = flaggedROWS(~isnan(flaggedROWS)); % Update flagged rows
