% This function aims to count the number of operant actions showing slow wave(s) just before (1, 2, 3 or more slow waves; it doesn't matter about the number).
% If there is 1 (or 2, 3 etc.) SWs just before the OA, then it corresponds to a TRUE element (1); if not, FALSE (0). 
% The algorithm computes the sum of these booleans, simply corresponding to the scalar 'countBP'. For example, in the case there are 10 OA and 'countBP'=10, it means each OA has a BP. 
% A list with the moments of operant actions (in seconds) with the indication of whether there is a BP or not, is displayed. 
% In the end is also displayed the total number of OA and the number of OA having at least one BP.

% 1. If you run principal.m : 				Please rename the channel 11 into 'ttl' (necessary to do it because it's named 'ttl' in the code)
% 2. If you don't run principal code, but only run find_BPandP300: 
%		- Either run principal_NOcorrelation.m: 	gives 'SW' as we need 'SW'. 
% 
% 			e.g. >> 			SW = principal(SA34_20_06_2014_0003.values);						% !! Don't forget 'SW' otherwise 'SW' won't be saved in the workspace			% Don't forget ';' because we don't want to display SW
% 	   			 >> 			find_BPandP300(ttl.times, SW)
% 
% 		- Or open the corresponding 'SW.mat' if already saved.
% 	   			 >> 			find_BPandP300(ttl.times, SW)


% INPUT: We need: 
% - TTL signal, which is a vector indicating moments of up-down and down-up of operant actions. Element 1 will always be an up-down. up-down are odd indexes and down-up are even indexes.
% - Moments of the positive and negative peaks of each BP (negative peaks are in certain cases more far from the OA, positive peaks are more far from the OA in other cases, it depends... so we can examine both types)


function find_BPandP300(vertical, SW)				% The input is in fact ttl.times but we can't write "function find_BP(ttl.times)" although we can write "find_BP(ttl.times)"	in the prompt
global def			
% global def SW			% useless because SW is input. (Moreover, putting it gives a WARNING-message.)

% oa 					% oa = ttl.times

lfp_defaults;				
oa = zeros(length(vertical)/2, 1);
countBP = 0;
countP300 = 0;


for i = 1:length(oa)				% until the last OA up-down, where up-down is an odd index of 'vertical' as the first up-down is the index 1 of 'vertical'. We suppose 'vertical' is of even length as we admit the last element is a down-up. 
	oa(i) = vertical(2*i-1);	
	
	indexBP = find([SW(1,:).negpeak_seconds] > (oa(i)-def.OAsemiwindow)  &  [SW(1,:).negpeak_seconds] < oa(i) );	% gives the order number of SW of the list of SWs, which is detected as a BP. Ex: If indexBP=1, it means the first SW in the list is a BP
	if isempty(indexBP)
		indexBP = find([SW(1,:).pospeak_seconds] > (oa(i)-def.OAsemiwindow)  &  [SW(1,:).pospeak_seconds] < oa(i) ); % same as before, but we look at the positive peak instead of the negative, in the case the negative peak is too far from OA to be detected as BP	
	end 	
	if ~isempty(indexBP) 				% in the case we have found something as a BP, then we can find the time of the BP. (It has no sense to search the time of BP if we haven't found any BP)
		% BP = SW(1, indexBP);			% gives the time in seconds, of the detected BP
		countBP = countBP+1;			% We only add 1, not 2 or 3 because, even if we find 2 BP or more for 1 OA, it has no importance. We only want to see if there is AT LEAST one BP per OA.
		disp(' ');
		disp(['OA', num2str(i), ' occurs at ', num2str(oa(i)), 's']);
		if length(indexBP) == 1
			disp(['     -> Possible BP:    negative peak at ', num2str(SW(1,indexBP).negpeak_seconds), 's;    positive peak at ', num2str(SW(1,indexBP).pospeak_seconds), 's']);
		elseif length(indexBP) == 2 	
			disp(['     -> Possible BP:    negative peak at ', num2str(SW(1,indexBP(1)).negpeak_seconds), 's;    positive peak at ', num2str(SW(1,indexBP(1)).pospeak_seconds), 's']);
			disp(['                        negative peak at ', num2str(SW(1,indexBP(2)).negpeak_seconds), 's;    positive peak at ', num2str(SW(1,indexBP(2)).pospeak_seconds), 's']);
		elseif length(indexBP) == 3	
			disp(['     -> Possible BP:    negative peak at ', num2str(SW(1,indexBP(1)).negpeak_seconds), 's;    positive peak at ', num2str(SW(1,indexBP(1)).pospeak_seconds), 's']);
			disp(['                        negative peak at ', num2str(SW(1,indexBP(2)).negpeak_seconds), 's;    positive peak at ', num2str(SW(1,indexBP(2)).pospeak_seconds), 's']);
			disp(['                        negative peak at ', num2str(SW(1,indexBP(3)).negpeak_seconds), 's;    positive peak at ', num2str(SW(1,indexBP(3)).pospeak_seconds), 's']);
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
		% P300 = SW(1, indexP300);			% gives the time in seconds, of the detected P3
		countP300 = countP300+1;			% We only add 1, not 2 or 3 because, even if we find 2 P3 or more for 1 OA, it has no importance. We only want to see if there is AT LEAST one P3 per OA.
		
		% howmanyP300 = length(indexP300)	% TEST
		
		if length(indexP300) == 1
			disp(['     -> Possible P3:    negative peak at ', num2str(SW(1,indexP300).negpeak_seconds), 's;    positive peak at ', num2str(SW(1,indexP300).pospeak_seconds), 's']);
		elseif length(indexP300) == 2 	
			disp(['     -> Possible P3:    negative peak at ', num2str(SW(1,indexP300(1)).negpeak_seconds), 's;    positive peak at ', num2str(SW(1,indexP300(1)).pospeak_seconds), 's']);
			disp(['                        negative peak at ', num2str(SW(1,indexP300(2)).negpeak_seconds), 's;    positive peak at ', num2str(SW(1,indexP300(2)).pospeak_seconds), 's']);
		elseif length(indexP300) == 3	
			disp(['     -> Possible P3:    negative peak at ', num2str(SW(1,indexP300(1)).negpeak_seconds), 's;    positive peak at ', num2str(SW(1,indexP300(1)).pospeak_seconds), 's']);
			disp(['                        negative peak at ', num2str(SW(1,indexP300(2)).negpeak_seconds), 's;    positive peak at ', num2str(SW(1,indexP300(2)).pospeak_seconds), 's']);
			disp(['                        negative peak at ', num2str(SW(1,indexP300(3)).negpeak_seconds), 's;    positive peak at ', num2str(SW(1,indexP300(3)).pospeak_seconds), 's']);
		end 	
	else 	
		disp(['     -> No P3 detected'])
	end		
	
	
end

%% Display the results
% Time_OA_in_seconds = oa 							% TEST
% BP 

disp(' ');
if length(oa) > 1
	disp(['For a total of ', num2str(length(oa)), ' operant actions,'])
 	% disp(['There are ', num2str(length(oa)), ' operant actions.'])			
elseif length(oa)  == 1 
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

% % Display the number of operant actions having at least 1 P300 (1 or 2 or more P300 per operant action)
if countP300 > 1 
	disp([' - ', num2str(countP300), ' operant actions show at least one P3.'])
elseif countP300 == 1 	
	disp(' - 1 operant action shows at least one P3.')
else 
	disp(' - No operant action shows at least one P3.')
end	
