clc;clear;close all;
fs = 16000;
deg = 0:10:90;
degEst=cell(1,length(deg));
% for i = 1:length(deg)
% 
%     inPutFilePath = sprintf('E:\\MatlabCode\\seperation\\shu\\mixedvoice\\virtl_mixed_Wnoise_10_f_20_m_%02d.wav',deg(i));
% 
%     [output,ami] = sepIter(inPutFilePath,1);
%     degEst{i}=ami;
% end
% tmp = degEst';
inPutFilePath = 'E:\\MatlabCode\\seperation\\shu\\mixedvoice\\virtl_mixed_Wnoise_10_f_10_m_70.wav';
[output,ami] = sepIter(inPutFilePath,1);
