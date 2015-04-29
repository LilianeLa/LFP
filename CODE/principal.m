% principal.m is the main function, gathering the other functions. It will give a list of artifacts and slow waves.  

% e.g. 
	% >> SW = principal(SA34_27_06_2014_0003.values, ttl.times);							% with correlation
% will give the list of artifacts and slow waves for the file SA34_27_06_2014_0003 

% NB: Please change the sampling frequency if necessary (in lfp_defaults.m), as it can be different from a file to another one:

	% def.fsample = 10000;		% e.g. for SA34 
	% def.fsample = 20000;		% e.g. for SA14 	

	
function SW = principal(V, vertical)
global def b bHP artifact red t s SW

disp(' ');
disp('*********************************************************************************************************');
disp('                                       I. DETECTION OF ARTIFACTS                                         ');
disp('*********************************************************************************************************');
disp(' ');
[red, bHP] = find_artifacts(V);		

disp(' ');
disp(' ');
disp('*********************************************************************************************************');
disp('                                      II. DETECTION OF SLOW WAVES                                        ');
disp('*********************************************************************************************************');
disp(' ');
% find_slow_waves_indiceDZC3(b);	
% SW = find_slow_waves(b);
SW = find_slow_waves_modif(b);

disp(' ');
disp(' ');
disp('*********************************************************************************************************');
disp('              III. DETECTION OF SLOW WAVES OCCURRING JUST BEFORE AND AFTER OPERANT ACTIONS               ');
disp('*********************************************************************************************************');
% find_BPandP300(vertical, SW);
% find_BPandP300_SWvalminvalmax(vertical, SW);
% find_BP_P300_randSW(vertical, SW);			% FAUX

% find_BP_P300_randSW(vertical, SW, V);
find_BP_P300_randSW_modifOA(vertical, SW, V);
% find_BP_P300_randSW_essai(vertical, SW, V);

% close all

% figure;
% plot(t,b);
% grid
% xlabel('Timepoints [-]');
% ylabel('Low-pass filtered signal [microV]');

% figure;
% plot(s,b);
% grid
% xlabel('Time [s]');
% ylabel('Low-pass filtered signal [microV]');

% figure;
% plot(s,V);
% grid
% xlabel('Time [s]');
% ylabel('Original signal [microV]');

% figure;
% plot(s,bHP, 'c');
% grid
% xlabel('Time [s]');
% ylabel('High-pass filtered signal [microV]');		

