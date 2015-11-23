clc;clear;close all;
fs = 16000;
deg = 10:10:90;
degEst=cell(3,length(deg));
for times = 3:3
    for i = 1:length(deg)
        inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\testDataNew\\female_male_0_%02d_white_20.wav',deg(i));
        [output,ami] = sepIter(inPutFilePath,times,2);
        degEst{times,i}=ami;
        audiowrite(sprintf('./output/outFemale_female_male_0_%02d_white_20.wav',deg(i)),output{1},fs)
        audiowrite(sprintf('./output/outMale_female_male_0_%02d_white_20.wav',deg(i)),output{2},fs)
    end
end
tmp = degEst';
% inPutFilePath = 'E:\\Document\\科研相关\\语音库\\TestData\\female_male_0_50_white_0.wav';
% inPutFilePath = './sb06_0Rev_0dB_45IntAngle.wav';
% [output,ami] = sepIter(inPutFilePath,3,2);
