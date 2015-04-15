LFP
===

CODE:  

principal.m is the main function, gathering all the other functions. It will give a list of artifacts and slow waves.

e.g.
	>> principal(SA34_27_06_2014_0003.values)
	
will give the list of artifacts and slow waves for the file SA34_27_06_2014_0003

NB: Please check the sampling frequency (and change if necessary in lfp_defaults.m), as it can be different from a file to another one:

	def.fsample = 10000;		% e.g. for SA34
	def.fsample = 20000;		% e.g. for SA14
