clc;clear;close all;
fs = 16000;
deg = [270:10:350,0:10:90];
errEst=cell(3,length(deg));
for times = 1:3
    for i = 1:length(deg)
        inPutFilePath = sprintf(['E:\\Document\\科研相关\\语音库\\180度声源\\male2_' num2str(deg(i)) '_white_0.wav']);
        dnnModel = sprintf('./modelWithoutIID/0dB.mat');
        [output,err] = sepIter2(inPutFilePath,times,dnnModel,0.5,i);
        errEst{times,i}=1-err;
%         audiowrite(sprintf('./output/outFemale_female_male_0_%02d_white_20.wav',deg(i)),output{1},fs)
%         audiowrite(sprintf('./output/outMale_female_male_0_%02d_white_20.wav',deg(i)),output{2},fs)
    end
end
tmp = errEst';
