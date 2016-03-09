clc;clear;close all;
fs = 16000;
% deg = 10:10:90;
deg = 10;
degEst=cell(3,length(deg));
for times = 1:3
    for i = 1:length(deg)
%         inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\180度声源\\female_male_%02d.wav',deg(i));
        inPutFilePath = sprintf('mixaudio.wav');
        dnnModel = sprintf('./model/20dB.mat');
        [output,ami] = sepIter(inPutFilePath,times,3,dnnModel,0.3);
        degEst{times,i}=ami;
%         audiowrite(sprintf('./output/outMale_female_male_%02d.wav',deg(i)),output{2},fs)
%         audiowrite(sprintf('./output/outFemale_female_male_%02d.wav',deg(i)),output{1},fs)
        audiowrite(sprintf('./output/s1.wav'),output{1},fs);
        audiowrite(sprintf('./output/s2.wav'),output{2},fs);
        audiowrite(sprintf('./output/s3.wav'),output{3},fs);
    end
end
tmp = degEst';
