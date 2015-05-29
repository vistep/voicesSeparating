clc;clear;close all;
% addpath('E:\\Document\\科研相关\\lxx语音库
% [x1,fs_ori] = audioread('E:\\Document\\科研相关\\语音库\\data\\虚拟声\\female\\female_10.wav');
% [x2,fs_ori] = audioread('E:\\Document\\科研相关\\语音库\\data\\虚拟声\\male\\male_50.wav');
% [x3,fs_ori] = audioread('E:\\Document\\科研相关\\语音库\\data\\虚拟声\\music\\music_60.wav');
% [x1,fs_ori] = audioread('E:\\Document\\科研相关\\lxx语音库\\tmp\\1_5.wav');
% [x2,fs_ori] = audioread('E:\\Document\\科研相关\\lxx语音库\\tmp\\3_330.wav');

% len = min([size(x1,1),size(x2,1),size(x3,1)]);
% len = min([size(x1,1),size(x2,1)]);
% x = x1(1:len-200000,:) + x2(100001:len-100000,:) + x3(200001:len,:);
% x = x1(1:len-200000,:) + x2(100001:len-100000,:);
% x = x1(1:len,:) + x2(1:len,:);
% audiowrite('E:\\MatlabCode\\seperation\\shu\\mixedvoice\\5_330.wav',x,fs_ori);

for i = 0:10:90
    for j = 0:10:90
        inPutFilePathF = sprintf('E:\\Document\\科研相关\\语音库\\data\\虚拟声\\whitenoise\\female_noise_20_%02d.wav',i);
        inPutFilePathM = sprintf('E:\\Document\\科研相关\\语音库\\data\\虚拟声\\whitenoise\\male_noise_20_%02d.wav',j);
        [female,fs] = audioread(inPutFilePathF);
        [male,fs] = audioread(inPutFilePathM);
        len = min([size(female,1),size(male,1)]);
        mixed = female(1:len,:)./max(max(female(1:len,:))) + male(1:len,:)./max(max(male(1:len,:)));
        filename = ['virtl_mixed_Wnoise_20_f_',num2str(i),'_m_',num2str(j),'.wav'];
        audiowrite(['E:\\MatlabCode\\seperation\\shu\\mixedvoice\\',filename],mixed,fs);
    end
end