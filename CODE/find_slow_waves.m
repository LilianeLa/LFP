% This function aims to find slow waves. The argument of this function is the filtered signal from low-pass filter.
% The criteria used are based on Massimini's but were softened: 
% - criterion on slope between the negative and the positive peaks (criteria of minimum percentile 90).  (Has been added to the Massimini criteria)
% - magnitude criteria in microV (minimum negative peak amplitude, minimum total peak-to-peak magnitude) 
% - duration criteria in ms (duration of negative peak, duration between up zero-crossing and positive peak). 

% At indexes of downward zero-crossing, negative peak, upward zero-crossing and positive peak, the vector 'red' returned by the function 'find_artifacts' 
% is useful to indicate if these indexes are parts of artifacts or not.
% (When there is an artifact detected, the algorithm skip the event and doesn't check if it's a slow wave)

% This function was written with Christophe Phillips's help, who kindly shared routines and parts of code. (Cyclotron Research Centre, University of Liege, Belgium)

function find_slow_waves(V)
global def b red t		
SW = struct('negpeak_seconds', [], 'pospeak_seconds', []);
countwaves=0;
F1 = zeros(1,size(V,1)); 
F2 = zeros(1,size(V,1)); 
F3 = zeros(1,size(V,1)); 
F1 = V';				
F2 = sign(V');			
DZC = find(diff(F2)== -2);	

% Criterion of maximum slope index percentile 90
F3 = [0 diff(V')]; 		
MSI_plot = zeros(1, size(F1,2));											
MSI_plot(find( F3 > crc_percentile(F3, def.percentile) )) = 100;
MSI = find(MSI_plot==100); 												

for imsi=1:size(MSI,2)-1		
    %% Find nearest MSI and DZC
    indiceDZC = find((DZC-MSI(imsi))<0);	
    if ~isempty(indiceDZC)			
        indiceDZC=indiceDZC(end);			% Keep only the last element of indiceDZC
        iDZC=DZC(indiceDZC);		
    else							
        iDZC=1;						
    end
	
	if red(iDZC) == 0  						% Check there's no artifact at the index iDZC 
		[valmin,indposmin]=min(F1(iDZC:MSI(imsi)));
		posmin = iDZC-1 +indposmin;		
		
		upperbound = size(F1,2) - (iDZC + def.rate * def.SWlength(2) /1000); 	   
		if upperbound >0
			iUZC = find(diff(F2(iDZC:iDZC+round(def.rate* def.SWlength(2)/1000))) == 2)+ iDZC-1; 	
		else
			iUZC= find(diff(F2(iDZC:end)) ==2) + iDZC-1;									
		end	
		
		if ~isempty(iUZC)&& ~isempty(indiceDZC)	&& red(posmin)==0						% not  ~isempty(iDZC)
			iUZC=iUZC(1);
			
			% Criterion on negative peak magnitude
			if ((iUZC-iDZC) <= 	(def.SWlength(2)*def.rate/1000) && ...
								(def.SWlength(1)*def.rate/1000) <= (iUZC-iDZC) )	&& ...
				red(iUZC) == 0								% disp('Duration of negative peak is between SWlentgth(1) and SWlentgth(2)')				

				%% Negative peak magnitude
				if valmin <= def.SWmAmpl(1)					% disp('Amplitude of negative peak is more negative than def.SWmAmpl(1)')					
					upperboundPicPositif = size(F1,2) - (iUZC +(def.rate*def.SWlength(3)/1000));
					if upperboundPicPositif > 0
						% if ((indiceDZC+3)<size(DZC,)) && (DZC(indiceDZC+3)-iUZC < def.rate*def.SWlength(3)/1000)
							% [valmax, indposmax]= max(F1(iUZC:DZC(indiceDZC+3)));							
						if 	   ((indiceDZC+2)<size(DZC,2)) && (DZC(indiceDZC+2)-iUZC < def.rate*def.SWlength(3)/1000)			% We examine between iUZC and the DZC after the next DZC (we want to find the maximum, not the derivative)
							[valmax, indposmax]= max(F1(iUZC:DZC(indiceDZC+2)));																
						elseif ((indiceDZC+1)<size(DZC,2)) && (DZC(indiceDZC+1)-iUZC < def.rate*def.SWlength(3)/1000)			% If the DZC after the next DZC is too far (i.e. is above duration threshold),
							[valmax, indposmax]= max(F1(iUZC:DZC(indiceDZC+1)));												% then we examine between iUZC and the next DZC (we want to find the maximum, not the derivative)	
						end
					else
						[valmax, indposmax]= max(F1(iUZC:end));
					end
					posmax = iUZC-1 + indposmax;

					if ~isempty(posmax) && ...
						red(posmax) == 0
					%% Criterion on peak to peak magnitude 
						if (abs(valmax) + abs (valmin)) >= def.SWmAmpl(2)
	 
							if  isempty(SW(end).negpeak_seconds) || ... % nothing in SW.negpeak (1st pass)
									((all(abs(posmin - squeeze(cat(1,SW(:).negpeak_seconds) *def.fsample))  > def.rate*def.SWlength(3)/5/1000))&&...   % need ... ms between SW negativity
									 (all(abs(posmax - squeeze(cat(1,SW(:).pospeak_seconds) *def.fsample))  > def.rate*def.SWlength(3)/5/1000)))     
									
									countwaves = countwaves+1;                                
									disp(' ');		
									disp(['SW', num2str(countwaves), ':    ', num2str(valmin) ' microV at ', num2str(posmin/def.fsample), 's;    ', num2str(valmax), ' microV at ', num2str(posmax/def.fsample), 's']) 										

									SW(countwaves).negpeak_seconds = 	posmin /def.fsample ;   % negative peak position in s
									SW(countwaves).pospeak_seconds = 	posmax /def.fsample ;   % positive peak position in s
							end
						end 
					end	
				end 	
			end			
		end				
	end 	
end           

disp(' ');
if countwaves == 0 
	disp('----> No slow wave detected');	
elseif countwaves == 1 
	disp('----> 1 slow wave detected');
else
	disp(['----> ', num2str(countwaves), ' slow waves detected'])
end 