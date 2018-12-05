clear all; 
close all; 
clc;

% Load bus definitions
load('00_config/bus_init.mat');

% Load quadrotor model parameters
Par_mdlQuad = mdl_quadrotor_par();

% Load kalman filter parameters
Par_filterKalman = mdl_filter_kalmanIntegration_par();

% Load complementary filter parameters
Par_filterMadgwick = mdl_filter_madgwick_par();

% Load esc-bldc parameter
Par_actuator = mdl_actuator_dynamics_par();

% Set linearized system dynamics
x0         = [0;0;0;zeros(9,1)];
u0         = Par_mdlQuad.m*Par_mdlQuad.g/4*ones(4,1);
SysDynLin  = mdl_quadrotor_dynamicsLin(x0, u0, Par_mdlQuad);

% Load complementary filter parameters
Par_control_pd = mdl_control_pd_par( SysDynLin.mB, Par_mdlQuad );


clear x0 u0 SysDynLin