function [output_peak] = mccgrampeak(correlogram, peaktype, infoflag)

% average across-frequency 
%integratedccfunction = sum(correlogram.data);   

for i_ch=1:correlogram.nfilters
%-----------------------------------------
integratedccfunction = correlogram.data(i_ch,:);   

switch peaktype
   
case 'best'
   % find most-central ('best') peak
   if (infoflag >= 1)
      fprintf('finding best (most-central) peak ...\n');
   end;
   % find the central position of the peak closest to the midline (t=0)
   % first, find midline:
   for delay=1:correlogram.ndelays,
      if (correlogram.delayaxis(delay) == 0)
            midlineindex1 = delay;
      end;
   end;
   % next, starting at left edge, find closestpeak
   midlinedistance = 999;
   for delay=2:correlogram.ndelays-1,
      if ((integratedccfunction(delay) > integratedccfunction(delay-1)) & (integratedccfunction(delay) > integratedccfunction(delay+1)))
         % peak!
         thismidlinedistance = abs(delay-midlineindex1);
         % if this midline distance is *worse* than the previous one,
         % then that was clearly the most central peak
         if (thismidlinedistance > midlinedistance)
            % success!
            % return previous bestpeakindex;
            break;
         else 
            midlinedistance = thismidlinedistance;
            chosenpeakindex = delay;
         end;
      end;
   end;
   chosenpeak_usecs = correlogram.delayaxis(chosenpeakindex);
   if (infoflag >= 1)
      fprintf('location: %d samples = %d usecs\n', chosenpeakindex, chosenpeak_usecs);
   end;      
   
   
case 'largest'
   % find largest peak in average
   if (infoflag >= 1)
      fprintf('finding largest peak ...\n');
   end;
   % first, find midline:
   for delay=1:correlogram.ndelays,
      if (correlogram.delayaxis(delay) == 0)
            midlineindex1 = delay;
      end;
   end;
   % next, starting at left edge, find largestpeak
   largestpeakheight = -1;
   chosenpeakindex = -5050; 
   for delay=2:correlogram.ndelays-1,
      if ((integratedccfunction(delay) > integratedccfunction(delay-1)) & (integratedccfunction(delay) > integratedccfunction(delay+1)))
         % peak!
         if (integratedccfunction(delay) > largestpeakheight)
            % success!
            largestpeakheight = integratedccfunction(delay);
            chosenpeakindex = delay;
         end;
      end;
   end;
   if (chosenpeakindex <= -5050) 
       max_integratedccfunction_idx = find(max(integratedccfunction) == integratedccfunction); 
       chosenpeakindex = max_integratedccfunction_idx(1); 
   end
   chosenpeak_usecs = correlogram.delayaxis(chosenpeakindex);
   if (infoflag >= 1)
      fprintf('location: %d samples = %d usecs\n', chosenpeakindex, chosenpeak_usecs);
   end;      
   
   
otherwise
   % unknown peaktype 
   fprintf('%s! error! unknown peaktype ''%s'' \n\n', mfilename, peaktype);
   output_peak = [];
   return;
  
end
   
if 1  % "1" uses polyfit and "0" not. 
% reset average to +/- 250 us centered on the peak
halfwidth_us = 250;
halfwidth_samples = halfwidth_us/(1000000/correlogram.samplefreq);
halfwidth_samples = round(halfwidth_samples);
cutdownaverage = [];
cutdowndelays = [];
counter=0;
startcount = chosenpeakindex-halfwidth_samples;
stopcount = chosenpeakindex+halfwidth_samples;
if startcount < 1
   startcount = 1;
end;
if stopcount > correlogram.ndelays
   stopcount = correlogram.ndelays;
end;
  
for delay=startcount:stopcount
   counter=counter+1;
   cutdownaverage(counter) = integratedccfunction(delay);
   cutdowndelays(counter) = correlogram.delayaxis(delay);
end;


% use 'polyfit' to fit a smooth curve to the data
polypoints = 2;
if (infoflag >= 1)
  fprintf('interpolating using %-d order ''polyfit'' ... \n', polypoints);
  end;      
[polycoefs polyfactor] = polyfit(cutdowndelays, cutdownaverage, polypoints);

% measure to 1 usec resolution to use for later maximum
counter=1;
predcurve = [];
predxaxis = [];
for xpoint = correlogram.delayaxis(startcount):1:correlogram.delayaxis(stopcount)
   predcurve(counter) = polyval(polycoefs, xpoint);
   predxaxis(counter) = xpoint;
   counter=counter+1;
end;
    
% predxaxis = correlogram.delayaxis(startcount):1:correlogram.delayaxis(stopcount);
% predcurve=spline(cutdowndelays,cutdownaverage,predxaxis);

% plot if required 
if infoflag >= 2
   close;
   figure(1);
   plot(cutdowndelays, cutdownaverage, 'r*', predxaxis, predcurve, '-');
   xlabel('Internal delay \tau (\musecs)');
   ylabel('Across-frequency average');
end;

% measure the x axis (=timedelay) corresponding to the maximum of the smooth curve
maximum = 0;
counter=1;
bestitd = -999999;
for xpoint = correlogram.delayaxis(startcount):1:correlogram.delayaxis(stopcount)
  if (predcurve(counter) >= maximum)
     maximum = predcurve(counter);
     bestitd = xpoint;
  end;
counter=counter+1;
end; 
   
% report answers   
if infoflag >= 1
   fprintf('interpolated position = %.0f usecs\n', bestitd);
   fprintf('\n');
end;
   
    output_peak(i_ch) = bestitd; 
    
else
    
    output_peak(i_ch) = chosenpeak_usecs; 
    
end % if 0
%output_peak(i_ch) = chosenpeak_usecs;
%--------------------------------------------------
end % for(i_ch) 