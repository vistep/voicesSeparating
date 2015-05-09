clc;clear;close all;
deg = 0:10:90;
degEst=cell(1,length(deg));
for i = 1:length(deg)
%     inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\data\\采集声\\female_%02d.wav',deg(i));
%     inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\data\\虚拟声\\whitenoise\\female_noise_20_%02d.wav',deg(i));
%     inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\data\\虚拟声\\whitenoise\\female_noise_15_%02d.wav',deg(i));
%     inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\data\\虚拟声\\whitenoise\\female_noise_10_%02d.wav',deg(i));
%     inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\data\\虚拟声\\whitenoise\\female_noise_5_%02d.wav',deg(i));
    inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\data\\虚拟声\\whitenoise\\female_noise_0_%02d.wav',deg(i));

    [output,ami] = sepIter(inPutFilePath,1);
    degEst{i}=ami;
end