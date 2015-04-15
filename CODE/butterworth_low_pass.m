% This function returns the filtered signal from low-pass filter: 'b'. 

% NB:
% - b will be used in 'find_artifacts' 
% - b will be the input of 'find_slow_waves' 

function b = butterworth_low_pass(V)

global def b t 			
lfp_defaults;			

t = [1:1:size(V,1)];		
% s = t/ def.rate; 

[num,den] = butter(def.butterorder, def.fcutlow/(def.fsample/2), 'low'); 		
b = filter(num,den,V); 

% figure; 
% plot(t,b,'g');
% hold on
% plot(t,V); 
% grid
% xlabel('Timepoints (index) [-]');
% ylabel('Voltage [microV]');
% legend('Filtered signal (low-pass)', 'Original signal');
% title(['Low-pass filter (fc = ', num2str(def.fcutlow), 'Hz, second order)']);

% figure; 
% plot(s,b,'m');
% grid
% xlabel('Time [seconds]')
% ylabel('Voltage [microV]')


