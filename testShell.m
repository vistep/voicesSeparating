clc;clear;close all;
fs = 16000;
deg = 10:10:90;
degEst=cell(3,length(deg));
% for times = 1:3
%     for i = 1:length(deg)
%         inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\testDataNew\\female_male_0_%02d_white_0.wav',deg(i));
%         [output,ami] = sepIter(inPutFilePath,times,2);
%         degEst{times,i}=ami;
%     end
% end
% tmp = degEst';
inPutFilePath = 'E:\\Document\\科研相关\\语音库\\TestData\\female_male_0_40_white_0.wav';
[output,ami] = sepIter(inPutFilePath,3,2);
