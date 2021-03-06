function [DynamicsLin, varargout] = mdl_quadrotor_dynamicsLin( x0, u0, ParMdlQuad )
% function [DynamicsLin, varargout] = mdl_quadrotor_dynamicsLin( x0, Par_mdlQuad )
%
%   Date        : Winter 2018
%
%   Description : Calculates the system dynamics and outputs of a 
%                 physical quadrotor model linearized around x0
% 
%   Parameters  : x0 -> Vector containing linearization point
%                 Par_mdlQuadrotor -> Struct containing model parameter
% 
%   Return      : DynamicsLin -> A struct containing the system dynamics 
%                                in linear state space form with matrices 
%                                A, B, C and D
%
%-------------------------------------------------------------------------%

if nargin==0
    % Set system size for query
    Ode.Size.tates           = 12;
    Ode.Size.inputs          = 4;
    Ode.Size.outputs         = 3;
    Ode.Size.parameters      = 0;
    Ode.Info.manipulatedVars = {'thrust_motor1'; 'thrust_motor2'; ...
                                'thrust_motor3'; 'thrust_motor4'};
    Ode.Info.systemStates    = {'x_geodetic'; 'y_geodetic'; 'z_geodetic'; ...
                                'u_body'; 'v_body'; 'w_body'; ...
                                'phi'; 'theta'; 'psi'; ...
                                'p_body'; 'q_body'; 'r_body'};
    Ode.Info.systemOutputs   = {'p_body'; 'q_body'; 'r_body'};
    Ode.Scaling.states       = [1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1; 1];
    Ode.Scaling.controls     = [1; 1; 1; 1];
    Ode.Scaling.outputs      = [1; 1];
    Ode.name                 = 'quadrotor_linearized';
    Ode.type                 = 'stateSpace';
    
    % Set output
    msg = 'Call for system size. Add an additional output argument';
    DynamicsLin              = msg;
    varargout                = {Ode};
    
else 
    % Extract necessary states for system dynamics
    u       = x0(4);
    v       = x0(5);
    w       = x0(6);
    phi     = x0(7);
    theta   = x0(8);
    psi     = x0(9);
    p       = x0(10);
    q       = x0(11);
    r       = x0(12);
    
    % Use intermediate values
    I    = ParMdlQuad.I;
    g    = ParMdlQuad.g;
    m    = ParMdlQuad.m;
    L    = ParMdlQuad.armLength;
    sphi = sin(phi);
    cphi = cos(phi);
    sthe = sin(theta);
    cthe = cos(theta);
    spsi = sin(psi);
    cpsi = cos(psi);
    
    %TODO: Get info about torque
    dm1  = ParMdlQuad.gamma;
    dm2  = ParMdlQuad.gamma;
    dm3  = ParMdlQuad.gamma;
    dm4  = ParMdlQuad.gamma;


    % Calculate A
    dfdxGeo = zeros(12, 3);
    
    dfdvBody ...
        = [cthe*cpsi    sphi*sthe*cpsi-cphi*spsi  cphi*sthe*cpsi+sphi*spsi;
           cthe*spsi    sphi*sthe*spsi+cphi*cpsi  cphi*sthe*spsi-sphi*cpsi;
               -sthe                   sphi*cthe                 cphi*cthe;
                   0                           r                        -q; 
                  -r                           0                         p;
                   q                          -p                         0;
                                       zeros(6,3)                         ];
       
    dfdeulerAngles ...
        = [(sphi*spsi+cphi*sthe*cpsi)*v+(cphi*spsi-sphi*sthe*cpsi)*w ...
           -sthe*cpsi*u+sphi*cthe*cpsi*v+cphi*cthe*cpsi*w ...
           -cthe*spsi*u-(cphi*cpsi+sphi*sthe*spsi)*v+(sphi*cpsi-cphi*sthe*spsi)*w; ...
          (-sphi*cpsi+cphi*sthe*spsi)*v-(cphi*cpsi+sphi*sthe*spsi)*w ...
           -sthe*spsi*u+sphi*cthe*spsi*v+cphi*cthe*spsi*w ...
            cthe*cpsi*u+(-cphi*spsi+sphi*sthe*cpsi)*v+(sphi*spsi+cphi*sthe*cpsi)*w; ...
                     cphi*cthe*v-sphi*cthe*w -cthe*u-sphi*sthe*v-cphi*sthe*w 0; ...
                                               0             g*cthe          0
                                    -g*cphi*cthe        g*sphi*cthe          0
                                     g*sphi*cthe        g*cphi*sthe          0
            -cphi*tan(theta)*q-sphi*tan(theta)*r sphi/cthe^2*q+cphi/cthe^2*r 0
                                  -sphi*q-cphi*r                  0          0
            cphi/cthe*q-sphi/cthe*r    sphi/cthe^2*sthe*q+cphi/cthe^2*sphi*r 0
            zeros(3,3) ];
        
    dfdomegaBody ...
        = [                                    zeros(3,3);
                                   0                   -w                    v;
                                   w                    0                   -u;
                                  -v                    u                    0;
                                   1      sphi*tan(theta)      cphi*tan(theta);
                                   0                 cphi                -sphi;
                                   0            sphi/cthe            cphi/cthe;
          ParMdlQuad.invI*...
          [  -I(3,1)*p+I(2,1)*r                    -I(3,2)*q-I(3,1)*p+(I(2,2)-I(3,3))*r I(2,1)*p+(I(2,2)-I(3,3))*q+2*I(2,3)*r
            2*I(3,1)*p+I(3,2)*q+(I(3,3)-I(1,1))*r                    -I(1,2)*r+I(3,2)*p (I(3,3)-I(1,1))*p-I(1,2)*q-2*I(1,2)*r
           -2*I(2,1)*p+(I(1,1)-I(2,2))*q-I(2,3)*r (I(1,1)-I(2,2))*p+2*I(1,2)*q+I(1,3)*r -I(2,3)*p+I(1,3)*q]];
       
    DynamicsLin.mA = [dfdxGeo dfdvBody dfdeulerAngles dfdomegaBody];
    
    % Calculate B
    DynamicsLin.mB = [zeros(5,4)
          1/m*ones(1,4)
          zeros(3,4)
          ParMdlQuad.invI*...
          [ 0    L    0   -L 
           -L    0    L    0
           dm1 -dm2 dm3 -dm4]];
      % TODO: Adapt thrust direction to notes
    
    % Set C
    DynamicsLin.mC = [zeros(3, 9) eye(3)];

    % Set function outputs
    DynamicsLin.mD = zeros(3,4);
    
    sprintf('Linear dynamics set\n');

end