//============================================================================
// Name        : test_code.cpp
// Author      : en
// Version     :
// Copyright   : Your copyright notice
// Description : Hello World in C++, Ansi-style
//============================================================================

#include <stdio.h>
#include "obsv_kalmanIntegration.h"

#define LSM9DS0_MAG_MGAUSS_2GAUSS      (0.08F)
#define LSM9DS0_GYRO_DPS_DIGIT_245DPS      (0.00875F)
#define LSM9DS0_ACCEL_MG_LSB_2G (0.061F)

//#include "ctrl_PD.h"

unsigned long tic;
double roll_est = 0;
double pitch_est = 0;
double roll_meas = 0;
double pitch_meas = 0;
double bias_p = 0;
double bias_q = 0;


int main(){
	printf("Hallo \n");
	double p = 0.3;
	double q = 0.5;


	double udot = 0;
	double vdot = 0;
	double wdot = 9.81;


	filterKalman(udot, vdot, wdot, roll_meas, roll_est, pitch_meas, pitch_est, bias_p, bias_q, p, q);
//	PWM = ctrl_PD(roll_est, pitch_est, p_bias_p, q-bias_q);


	printf("pitch_est: %f", pitch_est);
	return 0;
}
