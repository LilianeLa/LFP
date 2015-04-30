function def = lfp_defaults 

global def 

% def.fsample = 10000;						% for SA34 	% The sampling frequency or sampling rate is the average number of samples obtained in one second (samples per second)
def.fsample = 20000;						% for SA14 	
def.rate = def.fsample;
def.butterorder = 2; 						% Avoid high order. (risk of high temporal shift with the original signal)
def.fcutlow = 10 ; 							% Butterworth low pass

%% BUTTERWORTH HIGH-PASS AND DETECTION OF ARTIFACTS
% def.amplitude_artifact = 25;			
def.amplitude_artifact = 20;				% Amplitude of fast component of the artifact
def.derivee_artifact = 40; 
def.artifact_cut_length = 1.7*def.fsample;			
% def.artifact_cut_length = 1.1*def.fsample;			
% def.artifact_cut_length = 2.1*def.fsample;			
def.fcuthigh = 100 ; 					

def.amplitude_slow_artifact = 27;			% Amplitude of the slow component of the artifact
% def.amplitude_slow_artifact = 15;		
% def.amplitude_slow_artifact = 30;		
def.endslow = 1;							% Maximum interval authorized between the first high value of bLP found and the first ZC encountered (seconds)
% def.eps1 = 1000;
% def.eps2 = 1000;

def.amplitudediapason = 16;				
def.durationdiapason = 0.65;				% has been fixed upon the artifacts of SA14_0003
% def.durationdiapason = 0.1;		

% def.duration_slow_artifact	= 0.8;		% 0.5 firstly, fixed upon artifact 3 (seconds)
def.duration_slow_artifact	= 1;		
% def.duration_slow_artifact	= 7;		% before the adaptation of 'diapason'	 

% Maximum slope index: criterion on the slope between the negative and the positive peaks (criteria of minimum percentile 90)				
def.percentile = 90; 		
		
% MASSIMINI CRITERIA
% Duration criteria in ms: minimum and maximum time durations between down zero-crossing and up zero-crossing 
def.SWlength      	= [100 1250 1500];		% duration of negative peak: between 100 and 1250 ms (reduced from 150, upon the event at 184.5 s in SA14, to detect the negative peak)
											% duration between up zero-crossing and positive peak : maximum 1500 ms																												
% Magnitude criteria in microV: criteria of magnitude for SWS (-80 140) and delta waves (-40 75)
% minimum negative peak amplitude: -40 for delta and -80 for SWS, 	% from Massimini		
% minimum total magnitude: 			75 for delta and 140 for SWS 	% from Massimini
% def.SWmAmpl       = [-30 75]; 	
% def.SWmAmpl       = [-30 65]; 			
% def.SWmAmpl       = [-28 49]; 			
% def.SWmAmpl       = [-25 49]; 			
def.SWmAmpl       = [-20 40]; 			

def.OAsemiwindow = 5;

% def.minimal_duration_OA = 2.8;				% The algorithm will detect both 3 and 6 sec OAs 
def.minimal_duration_OA = 5.8;				% The algorithm will detect only 6 sec OAs

return		% end 
