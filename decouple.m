clear
basemva = 100;  accuracy = 0.001; maxiter = 50;

%        IEEE 30-BUS TEST SYSTEM (American Electric Power)
%        Bus Bus  Voltage Angle   ---Load---- -------Generator----- Injected
%        No  code Mag.    Degree  MW    Mvar  MW  Mvar Qmin Qmax     Mvar
lfybus                             % form the bus admittance matrix
decouple1              % Load flow solution by fast decoupled method
busout               % Prints the power flow solution on the screen
lineflow           % Computes and displays the line flow and losses
