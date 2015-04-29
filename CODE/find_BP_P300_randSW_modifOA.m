% This function aims to count the number of operant actions showing slow wave(s) just before 
% (1, 2, 3 or more slow waves; it doesn't matter about the number).
% If there is 1 (or 2, 3 etc.) SWs just before the OA, then it corresponds to a TRUE element (1); if not, FALSE (0). 
% The algorithm computes the sum of these booleans, simply corresponding to the scalar 'countBP'. For example, in the case there are 10 OA and 'countBP'=10, it means each OA has a BP. 
% A list with the moments of operant actions (in seconds) with the indication of whether there is a BP or not, is displayed. 
% A second list gives random windows, and indicates for each one if there are slow waves or not (not BP and P300). 
% The random windows are taken such that the detected slow waves won't be the BP and P300 detected before. 
% Moreover, all the random windows are different, such as there won't be twice the same random window and there won't be any redundant slow waves detected.

% In the end is displayed the total number of OA and the number of OA having at least one BP. 
% There is also an information about the number of random windows showing at least one SW (which is neither BP or P3).


% 1. If you run principal.m : 				Please rename the channel 11 into 'ttl' (necessary to do it because it's named 'ttl' in the code)
% 2. If you don't run principal code, but only run find_BP_P300_randSW: 
%		- Either run principal_NOcorrelation.m: 	gives 'SW' as we need 'SW'. 
% 
% 			e.g. >> 			SW = principal(SA34_20_06_2014_0003.values);						% !! Don't forget 'SW' otherwise 'SW' won't be saved in the workspace			% Don't forget ';' because we don't want to display SW
% 	   			 >> 			find_BP_P300_randSW(ttl.times, SW, SA34_20_06_2014_0003.values)		% !! Don't forget 'values' otherwise length(V)=1
% 
% 		- Or open the corresponding 'SW.mat' if already saved.
% 	   			 >> 			find_BP_P300_randSW(ttl.times, SW, SA34_20_06_2014_0003.values)		% !! Don't forget 'values' otherwise length(V)=1


% INPUT: We need: 
% - TTL signal, which is a vector indicating moments of up-down and down-up of operant actions. Element 1 will always be an up-down. up-down are odd indexes and down-up are even indexes.
% - Moments of the positive and negative peaks of each BP (negative peaks are in certain cases more far from the OA, positive peaks are more far from the OA in other cases, it depends... so we can examine both types)
% - The original signal

function find_BP_P300_randSW_modifOA(vertical, SW, V)				% The input is in fact ttl.times but we can't write "function find_BP(ttl.times)" although we can write "find_BP(ttl.times)"	in the prompt
global def			
% global def SW			% useless because SW is input. (Moreover, putting it gives a WARNING-message.)


lfp_defaults;				
oa = zeros(length(vertical)/2, 1);
countOA = 0;
countBP = 0;
countP300 = 0;
countrandSW = 0;
deadzone = zeros(ceil(length(V)/def.rate), 1);		% The indexes of deadzone are IN SECONDS, not in INDEXES

for i = 1:length(oa)				% until the last OA up-down, where up-down is an odd index of 'vertical' as the first up-down is the index 1 of 'vertical'. We suppose 'vertical' is of even length as we admit the last element is a down-up. 
	if vertical(2*i) - vertical(2*i-1) > 2 
		oa(i) = vertical(2*i-1);	
		countOA=countOA+1; 		
		
		%% BP 
		indexBP = find([SW(1,:).negpeak_seconds] > (oa(i)-def.OAsemiwindow)  &  [SW(1,:).negpeak_seconds] < oa(i) );	% gives the order number of SW of the list of SWs, which is detected as a BP. Ex: If indexBP=1, it means the first SW in the list is a BP
		if isempty(indexBP)
			indexBP = find([SW(1,:).pospeak_seconds] > (oa(i)-def.OAsemiwindow)  &  [SW(1,:).pospeak_seconds] < oa(i) ); % same as before, but we look at the positive peak instead of the negative, in the case the negative peak is too far from OA to be detected as BP	
		end 	
		if ~isempty(indexBP) 				% in the case we have found something as a BP, then we can find the time of the BP. (It has no sense to search the time of BP if we haven't found any BP)
			countBP = countBP+1;			% We only add 1, not 2 or 3 because, even if we find 2 BP or more for 1 OA, it has no importance. We only want to see if there is AT LEAST one BP per OA.
			disp(' ');
			disp(['OA', num2str(i), ' occurs at ', num2str(oa(i)), 's']);
			if length(indexBP) == 1
				disp(['     -> Possible BP:    ', num2str(SW(1,indexBP).valmin), ' microV at ', num2str(SW(1,indexBP).negpeak_seconds), 's;    ', num2str(SW(1,indexBP).valmax), ' microV at ', num2str(SW(1,indexBP).pospeak_seconds), 's']);
			elseif length(indexBP) == 2 	
				disp(['     -> Possible BP:    ', num2str(SW(1,indexBP(1)).valmin), ' microV at ', num2str(SW(1,indexBP(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(1)).valmax), ' microV at ', num2str(SW(1,indexBP(1)).pospeak_seconds), 's']);
				disp(['                        ', num2str(SW(1,indexBP(2)).valmin), ' microV at ', num2str(SW(1,indexBP(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(2)).valmax), ' microV at ', num2str(SW(1,indexBP(2)).pospeak_seconds), 's']);		
			elseif length(indexBP) == 3	
				disp(['     -> Possible BP:    ', num2str(SW(1,indexBP(1)).valmin), ' microV at ', num2str(SW(1,indexBP(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(1)).valmax), ' microV at ', num2str(SW(1,indexBP(1)).pospeak_seconds), 's']);
				disp(['                        ', num2str(SW(1,indexBP(2)).valmin), ' microV at ', num2str(SW(1,indexBP(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(2)).valmax), ' microV at ', num2str(SW(1,indexBP(2)).pospeak_seconds), 's']);		
				disp(['                        ', num2str(SW(1,indexBP(3)).valmin), ' microV at ', num2str(SW(1,indexBP(3)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(3)).valmax), ' microV at ', num2str(SW(1,indexBP(3)).pospeak_seconds), 's']);		
			elseif length(indexBP) == 4	
				disp(['     -> Possible BP:    ', num2str(SW(1,indexBP(1)).valmin), ' microV at ', num2str(SW(1,indexBP(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(1)).valmax), ' microV at ', num2str(SW(1,indexBP(1)).pospeak_seconds), 's']);
				disp(['                        ', num2str(SW(1,indexBP(2)).valmin), ' microV at ', num2str(SW(1,indexBP(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(2)).valmax), ' microV at ', num2str(SW(1,indexBP(2)).pospeak_seconds), 's']);		
				disp(['                        ', num2str(SW(1,indexBP(3)).valmin), ' microV at ', num2str(SW(1,indexBP(3)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(3)).valmax), ' microV at ', num2str(SW(1,indexBP(3)).pospeak_seconds), 's']);		
				disp(['                        ', num2str(SW(1,indexBP(4)).valmin), ' microV at ', num2str(SW(1,indexBP(4)).negpeak_seconds), 's;    ', num2str(SW(1,indexBP(4)).valmax), ' microV at ', num2str(SW(1,indexBP(4)).pospeak_seconds), 's']);							
			end 	
		else 	
			disp(' ');
			disp(['OA', num2str(i), ' occurs at ', num2str(oa(i)), 's']);
			disp(['     -> No BP detected'])
		end		
		
		%% P300
		indexP300 = find([SW(1,:).negpeak_seconds] < (oa(i)+def.OAsemiwindow)  &  [SW(1,:).negpeak_seconds] > oa(i) );	% gives the order number of SW of the list of SWs, which is detected as a P3. Ex: If indexP300=1, it means the first SW in the list is a P3
		% if isempty(indexP300)					% useless because it can be mistaken for the BP. If the negative peak is before OA it means it's a BP. If the neg peak is outside def.OAsemiwindow, then the pos peak is ALSO outside so in any case there's no sense to search for the pos peak 
			% indexP300 = find([SW(1,:).pospeak_seconds] < (oa(i)+def.OAsemiwindow)  &  [SW(1,:).pospeak_seconds] > oa(i) ); % same as before, but we look at the positive peak instead of the negative, in the case the negative peak is too far from OA to be detected as P3	
		% end 	
		if ~isempty(indexP300) 					% in the case we have found something as a P3, then we can find the time of the P3. (It has no sense to search the time of P3 if we haven't found any P3)
			countP300 = countP300+1;			% We only add 1, not 2 or 3 because, even if we find 2 P3 or more for 1 OA, it has no importance. We only want to see if there is AT LEAST one P3 per OA.
			if length(indexP300) == 1
				disp(['     -> Possible P3:    ', num2str(SW(1,indexP300).valmin), ' microV at ', num2str(SW(1,indexP300).negpeak_seconds), 's;    ', num2str(SW(1,indexP300).valmax), ' microV at ', num2str(SW(1,indexP300).pospeak_seconds), 's']);
			elseif length(indexP300) == 2 	
				disp(['     -> Possible P3:    ', num2str(SW(1,indexP300(1)).valmin), ' microV at ', num2str(SW(1,indexP300(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(1)).valmax), ' microV at ', num2str(SW(1,indexP300(1)).pospeak_seconds), 's']);
				disp(['                        ', num2str(SW(1,indexP300(2)).valmin), ' microV at ', num2str(SW(1,indexP300(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(2)).valmax), ' microV at ', num2str(SW(1,indexP300(2)).pospeak_seconds), 's']);		
			elseif length(indexP300) == 3	
				disp(['     -> Possible P3:    ', num2str(SW(1,indexP300(1)).valmin), ' microV at ', num2str(SW(1,indexP300(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(1)).valmax), ' microV at ', num2str(SW(1,indexP300(1)).pospeak_seconds), 's']);
				disp(['                        ', num2str(SW(1,indexP300(2)).valmin), ' microV at ', num2str(SW(1,indexP300(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(2)).valmax), ' microV at ', num2str(SW(1,indexP300(2)).pospeak_seconds), 's']);		
				disp(['                        ', num2str(SW(1,indexP300(3)).valmin), ' microV at ', num2str(SW(1,indexP300(3)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(3)).valmax), ' microV at ', num2str(SW(1,indexP300(3)).pospeak_seconds), 's']);			
			elseif length(indexP300) == 4	
				disp(['     -> Possible P3:    ', num2str(SW(1,indexP300(1)).valmin), ' microV at ', num2str(SW(1,indexP300(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(1)).valmax), ' microV at ', num2str(SW(1,indexP300(1)).pospeak_seconds), 's']);
				disp(['                        ', num2str(SW(1,indexP300(2)).valmin), ' microV at ', num2str(SW(1,indexP300(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(2)).valmax), ' microV at ', num2str(SW(1,indexP300(2)).pospeak_seconds), 's']);		
				disp(['                        ', num2str(SW(1,indexP300(3)).valmin), ' microV at ', num2str(SW(1,indexP300(3)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(3)).valmax), ' microV at ', num2str(SW(1,indexP300(3)).pospeak_seconds), 's']);		
				disp(['                        ', num2str(SW(1,indexP300(4)).valmin), ' microV at ', num2str(SW(1,indexP300(4)).negpeak_seconds), 's;    ', num2str(SW(1,indexP300(4)).valmax), ' microV at ', num2str(SW(1,indexP300(4)).pospeak_seconds), 's']);							
			end 	
		else 	
			disp(['     -> No P3 detected'])
		end

		%% The current zone around the oa(i) is now a new part of 'deadzone'
		if floor(oa(i)) - 2*def.OAsemiwindow > 0 
			lowerboundwindow = floor(oa(i)) - 2*def.OAsemiwindow;
		else 
			lowerboundwindow = 1;										% Not 0 because 0 is not authorized as an index 
		end 
		
		if ceil(oa(i)) + 2*def.OAsemiwindow < ceil(length(V)/def.rate)
			upperboundwindow =  ceil(oa(i)) + 2*def.OAsemiwindow;
		else 
			upperboundwindow = ceil(length(V)/def.rate);
		end 	
			
		deadzone(lowerboundwindow:upperboundwindow) = 1;		
	
	end
end

oa_new = find(oa ~= 0);			% or 		find (oa > 0 )

disp(' ');
disp(' ');
%% Find if there is at least 1 SW in each window

% for i = 1 : length(oa)														% Reduce the length of oa; otherwise it will put a window around each oa < 2 seconds, which is an inconvenient because it detects more random slow waves which are not necessary
for i = 1 : length(oa_new)

	% Update the zone of accessible and authorized centers 
	possiblecenters = find(deadzone == 0);										% for the first iteration, this is simple because deadzone is the first deadzone determined. But at each iteration, possiblecenters is updated because at each iteration a new part of 'deadzone' will be added
	
	% Build the current random window
	randindex = round(rand(1) * length(possiblecenters));  						% Choose a random index of possiblecenters and round it into an integer
	if randindex>0 
		randcenter = possiblecenters(randindex);
	else 
		randcenter = possiblecenters(1);
	end 
	
	if randcenter-def.OAsemiwindow >0 
		randwindow = [randcenter-def.OAsemiwindow, randcenter+def.OAsemiwindow];	%  colon for the lowerbound, 1 colon for the upperbound
	else 
		randwindow = [1, randcenter+def.OAsemiwindow];
	end

	% Find random SW in the random window
	indexrandSW = find([SW(1,:).negpeak_seconds] < randwindow(2)  &  [SW(1,:).negpeak_seconds] > randwindow(1) );	% gives the order number of SW of the list of SWs, which is detected as a random SW. Ex: If indexrandSW=1, it means the first SW in the list is a rand SW
	% disp(' ');
	disp(['Random window ', num2str(i), ': [', num2str(randwindow(1)), 's, ', num2str(randwindow(2)), 's]']);	
	% disp(['Random window ', num2str(i), ' is from ', num2str(randwindow(1)), 's to ', num2str(randwindow(2)), 's']);	
	if ~isempty(indexrandSW) 					% in the case we have found something as a rand SW, then we can find the time of the rand SW. (It has no sense to search the time of rand SW if we haven't found any rand SW)
		countrandSW = countrandSW+1;			% We only add 1, not 2 or 3 because, even if we find 2 rand SW or more for 1 OA, it has no importance. We only want to see if there is AT LEAST one rand SW per OA.
		if length(indexrandSW) == 1
			disp(['     -> Random SW:      ', num2str(SW(1,indexrandSW).valmin), ' microV at ', num2str(SW(1,indexrandSW).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW).valmax), ' microV at ', num2str(SW(1,indexrandSW).pospeak_seconds), 's']);
		elseif length(indexrandSW) == 2 	
			disp(['     -> Random SW:      ', num2str(SW(1,indexrandSW(1)).valmin), ' microV at ', num2str(SW(1,indexrandSW(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(1)).valmax), ' microV at ', num2str(SW(1,indexrandSW(1)).pospeak_seconds), 's']);
			disp(['                        ', num2str(SW(1,indexrandSW(2)).valmin), ' microV at ', num2str(SW(1,indexrandSW(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(2)).valmax), ' microV at ', num2str(SW(1,indexrandSW(2)).pospeak_seconds), 's']);		
		elseif length(indexrandSW) == 3	
			disp(['     -> Random SW:      ', num2str(SW(1,indexrandSW(1)).valmin), ' microV at ', num2str(SW(1,indexrandSW(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(1)).valmax), ' microV at ', num2str(SW(1,indexrandSW(1)).pospeak_seconds), 's']);
			disp(['                        ', num2str(SW(1,indexrandSW(2)).valmin), ' microV at ', num2str(SW(1,indexrandSW(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(2)).valmax), ' microV at ', num2str(SW(1,indexrandSW(2)).pospeak_seconds), 's']);		
			disp(['                        ', num2str(SW(1,indexrandSW(3)).valmin), ' microV at ', num2str(SW(1,indexrandSW(3)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(3)).valmax), ' microV at ', num2str(SW(1,indexrandSW(3)).pospeak_seconds), 's']);			
		elseif length(indexrandSW) == 4	
			disp(['     -> Random SW:      ', num2str(SW(1,indexrandSW(1)).valmin), ' microV at ', num2str(SW(1,indexrandSW(1)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(1)).valmax), ' microV at ', num2str(SW(1,indexrandSW(1)).pospeak_seconds), 's']);
			disp(['                        ', num2str(SW(1,indexrandSW(2)).valmin), ' microV at ', num2str(SW(1,indexrandSW(2)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(2)).valmax), ' microV at ', num2str(SW(1,indexrandSW(2)).pospeak_seconds), 's']);		
			disp(['                        ', num2str(SW(1,indexrandSW(3)).valmin), ' microV at ', num2str(SW(1,indexrandSW(3)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(3)).valmax), ' microV at ', num2str(SW(1,indexrandSW(3)).pospeak_seconds), 's']);		
			disp(['                        ', num2str(SW(1,indexrandSW(4)).valmin), ' microV at ', num2str(SW(1,indexrandSW(4)).negpeak_seconds), 's;    ', num2str(SW(1,indexrandSW(4)).valmax), ' microV at ', num2str(SW(1,indexrandSW(4)).pospeak_seconds), 's']);							
		end 	
	else 	
		% disp(['     -> No random SW detected'])
		disp(['     -> No SW detected'])
	end
	
	%% Avoid the doubloons of random windows: state the current random window is now a deadzone (i.e. useless to access it at a further iteration)
	deadzone(randwindow(1):randwindow(2)) = 1;			% The zone from current lowerbound and upperbound have become a new part of deadzone because we don't wanna detect twice the same SW
end 	


%% DISPLAY THE RESULTS
disp(' ');
disp('*********************************************************************************************************');
if countOA > 1
	% disp(['For a total of ', num2str(length(oa)), ' operant actions,'])			% length(oa) can be higher than countOA so this is important to write countOA instead
	disp(['For a total of ', num2str(countOA), ' operant actions,'])
 	% disp(['There are ', num2str(length(oa)), ' operant actions.'])			
elseif countOA  == 1 
	disp('There is only 1 operant action.')
else 
	disp('There is no operant action.')
end 	

% NumberOAhavingBP = countBP						% Display the number of operant actions having at least 1 BP (1 or 2 or more BP per operant action)
if countBP > 1 
	disp([' - ', num2str(countBP), ' operant actions show at least one BP.'])
elseif countBP == 1 	
	disp(' - 1 operant action shows at least one BP.')
else 
	disp(' - No operant action shows at least one BP.')
end	

%% Display the number of operant actions having at least 1 P300 (1 or 2 or more P300 per operant action)
if countP300 > 1 
	disp([' - ', num2str(countP300), ' operant actions show at least one P3.'])
elseif countP300 == 1 	
	disp(' - 1 operant action shows at least one P3.')
else 
	disp(' - No operant action shows at least one P3.')
end	

if countrandSW > 1 
	disp([' - ', num2str(countrandSW), ' of the ', num2str(countOA), ' random windows show at least one SW (which is neither BP or P3).'])
elseif countrandSW == 1 	
	disp([' - 1 of the ', num2str(countOA), ' random windows shows at least one SW (which is neither BP or P3).'])
else 
	disp([' - 0 of the ', num2str(countOA), ' random windows shows at least one SW.'])
end	
disp('*********************************************************************************************************');
disp(' ');




% rand(1)												% gives 1 random value 
% rand(length(oa))										% gives matrix length(oa)*length(oa) 
% rand(length(oa), 1)									% gives vector 
