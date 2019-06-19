function S = salinityCOND(T,C,P)
% salinityCOND
% Jesse Bausell
% July 3, 2018
% 
% This function calculates salinity (S) from temperature (T), conductivity
% (C), and density (D) based off of:
%
% 1978 PRACTICAL SALINITY SCAE EQUATIONS
% IEEE Journal of Oceanic Engineering, Vol. OE-5, No. 1, January 1980, page
% 14
%
% Inputs:
% C - conductivity (mmho/cm)
% T - Temperature (degrees C)
% D - Density (decibars)
%
% Outputs:
% S - salinity

%% Coefficients - Round 1

C = 10*C;

C_35_15_0 = 42.914;

A1 = 2.070E-5;      B1 = 3.426E-2;      C0 = 6.766097E-1;
A2 = -6.370E-10;    B2 = 4.464E-4;      C1 = 2.00564E-2;
A3 = 3.989E-15;     B3 = 4.215E-1;      C2 = 1.104259E-4;
                    B4 = -3.107E-3;     C3 = -6.9698E-7;
                                        C4 = 1.0031E-9;
                    
%% Equations - Round 1

R = C/C_35_15_0; %R is the ratio of measured conductivity with C(35,15,0).

Rp = 1+(P.*(A1 + A2*P + A3*(P.^2)))./(1+B1*T + B2*(T.^2) + B3*R + B4*R.*T);

rT = C0 + C1*T + C2*(T.^2) + C3*(T.^3) + C4*(T.^4);

R_T = R./(Rp.*rT);

%% Coefficients - Round 2

a0 = 0.0080;        b0 = 0.0005;        k = 0.0162;
a1 =  -0.1692;      b1 = -0.0056;
a2 = 25.3851;       b2 = -0.0066;
a3 = 14.0941;       b3 = -0.0375;
a4 = -7.0261;       b4 = 0.0636;
a5 = 2.7081;        b5 = -0.0144;

COEFF = (T-15)./(1+k*(T-15));

 S = a0 + a1*(R_T.^(1/2))+a2*(R_T)+a3*(R_T.^(3/2))+a4*(R_T.^(2))+a5*(R_T.^(5/2)) ...
     + COEFF.*(b0 + b1*(R_T.^(1/2))+b2*(R_T)+b3*(R_T.^(3/2))+b4*(R_T.^(2))+b5*(R_T.^(5/2)));
