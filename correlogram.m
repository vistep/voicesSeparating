function [output_correlogram] = correlogram(cross_corr,mindelay, maxdelay, transduction, binauralswitch, multichanneloutput_l, multichanneloutput_r, samplerate, fbankcf, infoflag)

% measure max/min values of waveforms
%maxoverall = wave.overallmax; 

[num_channels, num_samples] = size(multichanneloutput_l);

% make a true time axis
timeaxis_samples = 1:1:length(num_samples);
timeaxis_ms = timeaxis_samples/samplerate*1000;
onesample = 1000000/samplerate; % us

% apply the neural transduction
[multichanneloutput_l, powervector_l, maxvector_l] = mmonauraltransduction(multichanneloutput_l, transduction, samplerate, infoflag);
[multichanneloutput_r, powervector_r, maxvector_r] = mmonauraltransduction(multichanneloutput_r, transduction, samplerate, 0);

 
   
%*****************************************************
% binaural code
%*****************************************************

% quantize min/max delay to an integer number of samples
maxdelay = round(maxdelay/onesample) * onesample;
mindelay = round(mindelay/onesample) * onesample;
maxdelay_samples = maxdelay/onesample;
mindelay_samples = mindelay/onesample;

% get width of delay axis in samples; quantized in units of 
% 'delaystep' samples
delaystep = 1;  % samples (1= maximum resolution)
delayindex_samples = mindelay_samples:delaystep:maxdelay_samples;
ndelays = length(delayindex_samples);
delayindex_usecs = delayindex_samples * onesample;


% define 'correlogram' structure
%correlogram = mccgramstructure(programname, transduction, samplerate, lowfreq, highfreq, filterdensity, nfilters, qfactor, bwminfactor, mindelay, maxdelay, ndelays, 'binauralcorrelogram');
correlogram.freqaxishz =  fbankcf;
%[filter_q, filter_bwmin] = mstandarderbparameters;
%correlogram.freqaxiserb =  mhztoerb(fbankcf, filter_q, filter_bwmin, 0);
correlogram.delayaxis = delayindex_usecs;
correlogram.powerleft =  powervector_l;
correlogram.powerright =  powervector_r;

correlogram.nfilters = num_channels; 
correlogram.ndelays = ndelays; 


correlogram.data = cross_corr';   

%*****************************************************
% return values
correlogram.samplefreq = samplerate; 
output_correlogram = correlogram;
output_correlogram.title = 'first-level correlogram';
