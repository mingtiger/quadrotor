function F_static = mdl_actuator_thrust( pwm ) 
% function F_static = mdl_actuator_thrust( pwm ) 
%
%   Author1     : 
%
%   Date        : Winter 2018
%
%   Description : Submodel for esc-bldc dynamics
%
%   Parameters  : pwm -> Pulse-width modulated signal
% 
% 
%   Return      : F_static -> Motor thrust from static map
%
%   This function was autogenerated by 04_identification/...
%   ...actuator_esc-bldc/ident_acutator_thrust.m 
%
%-------------------------------------------------------------------------%

g = 9.81; % Gravity [m/s^2]
F_static = g * (-0.007692.*pwm.^3 + 0.015926.*pwm.^2 + 0.0015483.*pwm + -0.00010295);