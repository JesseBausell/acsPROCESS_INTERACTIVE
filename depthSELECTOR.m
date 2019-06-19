function [selected_deptH_IND, selected_deptH] = depthSELECTOR(deptH)
% depthSELECTOR
% Jesse Bausell
% May 26, 2016
%
% Revised: December 9, 2016
%
% This program Allows the user to visually select which part of the data
% he/she wants to use according to depth. Use the figure cursor to
% determine index of the desired depths.
%
% Inputs:
% deptH - depths for backscatter rows
%
% Outputs:
% selected_deptH - user-selected depths
% selected_deptH_IND - user-selected depth indices
%% Select desired depth at which to work
% This section is an interactive while loop that lets users select pieces
% of a multi-cast profile for processing.

d_KEY = 1; % reference variable for cycling through while-loop
bb_Depth = nan(length(deptH),1); % empty nan-array in which to put user-selected depth values

while 1
    % This interactive while-loop allows user to select portions of the
    % ac-s multicast that he/she is interested in processing.
    if isequal(d_KEY,1);
        % User has not made any depth selection
        plot(deptH,'b','LineWidth',2); % Depth vs. index of spectrum (numerical order)
        xlabel('Index','FontSize',20); ylabel('Depth (m)','FontSize',20); % labels 
        title('ACS Cast Depth','FontSize',20); %title
        hold on % plot more on figure
        plot(bb_Depth,'r','LineWidth',2); % plot user-selected depth indices
        legend('ACS Cast','Selected ACS Cast','Location','northeast'); % add legend
        set(gca,'ydir','reverse'); % reverse y orientation of plot
        replY = input('Select subset of ACS cast (y/n/exit/redo)?' ,'s'); 
        % Asks user if he/she wants to select an additional region (subset)
        % of the cast (above)
        clc; % Clears command window
    
        if regexpi(replY,'Y');
            % If user wants to select an additional region of the cast,
            % clear command window, close figure, and move to the secong
            % part of the while loop.
            clc; close all; d_KEY = d_KEY+1; 
            % reference variable increases. Move on to next section of
            % while loop (above)
            
        elseif regexpi(replY,'n');
            % If user DOES NOT want to select and additional region of the
            % cast, asks if he/she is satisfied (below) 
            replY1 = input('Are you satisfied with selected ACS data subset?' ,'s'); clc;
                if regexpi(replY1,'y')
                    % User indicates that he/she is satisfied with selection of depths           
                    num_IND = find(isnan(bb_Depth) ~= 1); % Indexes depths that user has selected
                    selected_deptH = bb_Depth(num_IND); % Gives indexed depth separate variables
                    selected_deptH_IND = num_IND; % Gives indices themselves a variable
                    close all; clc; % close all figures, clear command window
                    return % End program
                else
                    % User indicates that he/she IS NOT satisfied with
                    % previous selection of depths
                    d_KEY = 1; % Reference variable reverts back to 1. While loop recycles
                    close all; clc; % Close figures. Clear command window. User starts over again.
                end     
                
        elseif regexpi(replY,'exit');
                    % User wants to cancel changes. He/she is asked this
                    % (below)
                    replY1 = input('Disregard all changes to ACS data?' ,'s'); clc;
                if regexpi(replY1,'y')
                    % User wants to cancel all selections
                    selected_deptH = deptH; % Selected depth is reverted to original depth
                    close all; clc; % Everything is closed, command window is cleared.
                    return % Function is ended             
                else
                    % User doesn't want to cancel all selections. Program
                    % starts from beginning.
                    d_KEY = 1; % Index variable brought back to 1
                    close all; clc; % Everything is closed, command window is cleared.                    
                end            
                
        elseif regexpi(replY,'redo');
            % User wants to start from scratch
            d_KEY = 3; % Index variable increased to 3. Jump to end of while-loop
            
        else
            % User made invalid input into the command window.
            clc; close all;
            disp('Invalid Selection. Try again.');      
        end    
    end
    
    
    if isequal(d_KEY,2);
        % User previously selected to make additional depth selection.
        % Cast depth vs. index is replotted with user-selections overlaid.
        plot(deptH,'b','LineWidth',2); % Plot all cast depths
        xlabel('Index','FontSize',20); ylabel('Depth (m)','FontSize',20); % labels
        title('ACS Cast Depth','FontSize',20); % title
        hold on % plot something else
        plot(bb_Depth,'r','LineWidth',2); % User-selected depths
        legend('ACS Cast','Selected ACS Cast','Location','northeast'); % legend
        set(gca,'ydir','reverse'); % reverse y direction
        % Display instructions to user about making selections (below)
        disp(['Select any combination of integers between 1 & ' num2str(length(deptH))]);
        disp('Use the figure to help you select.')
        disp('Use the notation ###:### to select beginning and end depths.')
        replY2 = input('Choose integers: ','s'); % User chooses depth indices on command window
    
        if isempty(regexpi(replY2,'[a-z]'))
            % User correctly selected ONLY INTEGERS
               replY2 = str2num(replY2); % Convert string to double array
               replY2 = sort(replY2,'ascend'); % Order numbers ascending 
               bb_Depth(replY2) = deptH(replY2); % Place depths onto nan array
               d_KEY = d_KEY-1; % decrease reference variable. Go back to the beginning
               close all; clc; % Close everything. Clear command window.
        else 
            % User input letters. Make make another selection
               clc; close all; % Close everything. Clear command window.
               disp(['Integers from 1-' num2str(l)  ' only.']); % Inform user of error     
        end   
    end
    
    
    if isequal(d_KEY,3);
        % User previously decided that he/she wanted to start over fresh. 
        bb_Depth = nan(length(deptH),1); % User-selected depths are replaced with NaNs
        d_KEY = 1; % Reference variable returned to 1. While loop recycled.        
    end    
end