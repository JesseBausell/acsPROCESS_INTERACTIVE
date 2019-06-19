function [ACS_Grated, grate_INDICATOR] = HoloGrater_ACS_4(lamdA,ACS_line,grate_IND)
% HoloGrater_ACS_4
% Jesse Bausell
% September 5, 2015 
%
%
%
% This function performs the holographic grating correction for raw
% ac-s spectra. For each individual spectrum it calculates expected
% absorption/attenuation at the lowest wavelength of the second grating
% (upper wavelengths) using matlab's spline function. It then subtracts
% this value from the observed absorption/attenuation creating an offset.
%
% Inputs:
% lamdA - wavelengths of individual absorption/attenuation spectrum
% ACS_line - absorption/attenuation spectrum
% grate_IND - highest wavelength in the first holographic grating.
%
% Outputs:
% ACS_Grated - corrected absorption/attenuation spectrum
% grate_INDICATOR - offset value
%% Before the correction is applied, check to be sure that lamdA and ACS_line are 1 dimensional
[l_lamdA,w_lamdA] = size(lamdA); [l_ACS_line,w_ACS_line] = size(ACS_line);
% Calculates dimensions of input variables

if ~isequal(l_lamdA,1) || ~isequal(l_ACS_line,1) 
    % if input variables are 2D, return error
    error('Input Dimension mismatch! One row only please.')
end

%% Calculate Interpolation and offset between holographic gratings

interPOLATION = spline(lamdA(grate_IND-2:grate_IND),ACS_line(grate_IND-2:grate_IND),lamdA(grate_IND+1));
%finds the interpolation point (note that grate_IND+1 and interPOLATION are
%an ordered pair.

grate_INDICATOR = interPOLATION-ACS_line(grate_IND+1); 
% Calculates offset as difference between observed and expected
% absorption/attenuation at the lowest wavelength of the second grating

ACS_line(grate_IND+1:end) = ACS_line(grate_IND+1:end)+grate_INDICATOR; 
% Uses the offset to correct the second holographic grating
ACS_Grated = ACS_line; % Changes the variable name
    
