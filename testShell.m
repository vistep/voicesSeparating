clc;clear;close all;
fs = 16000;
deg = 0:10:90;
degEst=cell(1,length(deg));
for i = 1:length(deg)

    inPutFilePath = sprintf('E:\\MatlabCode\\seperation\\shu\\mixedvoice\\virtl_mixed_f_10_m_%02d.wav',deg(i));

    [output,ami] = sepIter(inPutFilePath,2);
    degEst{i}=ami;
end
tmp = degEst';
% inPutFilePath = 'E:\\MatlabCode\\seperation\\shu\\mixedvoice\\virtl_mixed_f_10_m_20.wav';
% [output,ami] = sepIter(inPutFilePath,2);
