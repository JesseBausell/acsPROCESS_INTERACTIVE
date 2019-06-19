function [ACS_INTERP] = lambda_INTERPOLATE(lambdA_ORGNAL,ACS_ORGNAL,lambdA_TRNSCRBE)
% lambda_INTERPOLATE
% Jesse Bausell
% October 24, 2016
%
% lambda_INTERPOLATE is intended to be used with ACS data, but can be used
% for other applications as well. The program allows the user to find the
% y-value of points that fall within a two-dimensional curve on the x-axis
% but are in between (or slightly different) than the x-values (x-array)
% enumerated in the curve. Plese note the abreviations used in the
% annotation: absorption (a) and attenuation (c).
%
% Inputs:
% lambdA_ORGNAL - the x-array that will serve as the reference for the
% interpolation
% ACS_ORGNAL - the y-array (ACS values most likely) that corresponds to the
% x-array.
% lambdA_TRNSCRBE- the points that the user wants interpolated.
%
% Outputs:
% ACS_INTERP - the newly-interpolated points for the y-axis.
% 
% Please note: lambda_INTERPOLATE will only accept one-demensional
% HORIZONTAL arrays for all three input variables. lambdA_ORGNAL and ACS_ORGNAL
% MUST BE EQUAL lengths.

a = size(lambdA_ORGNAL);
b = size(ACS_ORGNAL);
c = size(lambdA_TRNSCRBE);
% These three lines get the dimensions of all of the input matrices.

if ~isequal(a(1),1) || ~isequal(b(1),1) || ~isequal(c(1),1)
    % This if statement is an error filter. It protects the program's
    % function by not allowing it to run if something more than an array is
    % generated (more than one row).
    
    error('All inputs must be SINGLE row horizontal arrays!')
    
end



if ~isequal(size(lambdA_ORGNAL),size(ACS_ORGNAL))
    % This if statement is another error filter. It protects the program's
    % function by not allowing it to run if lambdA_ORGNAL and ACS_ORGNAL
    % are different sizes.
    
    error('lambdA_ORGNAL and ACS_ORGNAL must be the same lengths. Though you knew!')
    
end


ACS_INTERP = nan(c); 
% Creates the output variable that can be indexed in the for-loop below.


for ii = 1:c(2)
    %This for loop is the meat and potatoes of the program. It does several
    %things. First, it determines the location (on the x-axis) of the point
    %to interpolate (lambdA_TRNSCRBE), finds the three nearest points to it
    %on the original arrays (x and y), and then interpolates it using the
    %spline function.
    
    diff_ARRAY = abs(lambdA_ORGNAL - lambdA_TRNSCRBE(ii));
    lambda_IND = find(diff_ARRAY == min(diff_ARRAY)); lambda_IND = lambda_IND(1);
    % Determine the location (index) of the x-value that is the closest in
    % magnitude to the point we are interpolating.

    lambda_IND_HI = NaN;  % The upper interpolation input limit
    lambda_IND_LOW = NaN; % The lower interpolation limit
    keY = 0;              % They Key lets us know which equation to use for interpolation (there are some options)
    % These are baseline values of three variables used in the code below.
    % These values are redesignated depending on the relationship between
    % original and interpolated values.
    
    if (lambdA_ORGNAL(lambda_IND) - lambdA_TRNSCRBE(ii)) < 0 
        % If the x-value closest to the interpolation point is below it on
        % the x axis.
        
        lambda_IND_LOW = lambda_IND;
        lambda_IND_HI = lambda_IND + 1;
        keY = 1; 
        % Redefine the baseline variables.
        
    elseif (lambdA_ORGNAL(lambda_IND) - lambdA_TRNSCRBE(ii)) > 0 
        % If the x-value is closest to the interpolation point above it on
        % teh x-axis.
        
        lambda_IND_LOW = lambda_IND - 1;
        lambda_IND_HI = lambda_IND;
        keY = -1;
        % Redefine the baseline variables.
         
    end

    
    if isequal(lambda_IND_HI,length(lambdA_ORGNAL)+1)
        % If the point of interpolation is greater than the largest point
        % on the x-array.
        
        lambda_IND_HI = lambda_IND_HI-1;
        lambda_IND_LOW = lambda_IND_LOW - 1;
        % Redefine the baseline variables. Make the high and low point the
        % largest and second largest points on the x-array.
     
    elseif isequal(lambda_IND_LOW,0)
        % If the point of interpolation is less than the smallest point
        % on the x-array.

        lambda_IND_LOW = lambda_IND_LOW+1;
        lambda_IND_HI = lambda_IND_HI + 1;
        % Redefine the baseline variables. Make the high and low point the
        % smallest and second smallest points on the x-array. 
    end
    
    
    if isequal(lambda_IND_LOW,1)
        % If lambda_IND_LOW is the lowest point on the x-array.
        
        keY = 1; %Make sure that we slide the interpolation index to the right.
        
    elseif isequal(lambda_IND_HI,length(lambdA_ORGNAL))
        % If lambda_IND_LOW is the highest point on the x-array.

        keY = -1; %Make sure that we slide the interpolation index to the right.
        
    end

    % Now we interpolate!!
    
    if isequal(keY,1)
        %If a) interpolation index is less than the lowest point on the
        %x-array, b) interpolation index is inbetween two points in the
        %x-array and closest to the one on the left (smaller) or c)
        %interpolation index is between the first and second (smallest)
        %points in the x-array.
        
        ACS_INTERP(ii) = spline(lambdA_ORGNAL(lambda_IND_LOW:lambda_IND_HI+keY),ACS_ORGNAL(lambda_IND_LOW:lambda_IND_HI+keY),lambdA_TRNSCRBE(ii));
        % Slide index right one point (x-axis wise) and interpolate the data.
        
    elseif isequal(keY,-1)
        %If a) interpolation index is greater than the highest point on the
        %x-array, b) interpolation index is inbetween two points in the
        %x-array and closest to the one on the right (larger) or c)
        %interpolation index is between the last and second to last 
        %(AKA largest and secodn largest) points in the x-array.
    
        ACS_INTERP(ii) = spline(lambdA_ORGNAL(lambda_IND_LOW+keY:lambda_IND_HI),ACS_ORGNAL(lambda_IND_LOW+keY:lambda_IND_HI),lambdA_TRNSCRBE(ii));
        % Slide index left one point (x-axis wise) and interpolate the data.

        
    else
        % If the interpolated point falls directly on a point in the
        % x-array.
        
        ACS_INTERP(ii) = ACS_ORGNAL(lambda_IND);
        % No interpolation necessary. Use the original value.
        
    end
    
end


