clc;clear;close all;

[x1,fs_ori] = audioread('E:\\Document\\科研相关\\语音库\\data\\虚拟声\\female\\female_10.wav');
[x2,fs_ori] = audioread('E:\\Document\\科研相关\\语音库\\data\\虚拟声\\male\\male_50.wav');
% [x3,fs_ori] = audioread('E:\\Document\\科研相关\\语音库\\data\\虚拟声\\music\\music_60.wav');

% len = min([size(x1,1),size(x2,1),size(x3,1)]);
len = min([size(x1,1),size(x2,1)]);
% x = x1(1:len-200000,:) + x2(100001:len-100000,:) + x3(200001:len,:);
x = x1(1:len-200000,:) + x2(100001:len-100000,:);
audiowrite('female_male_10_50.wav',x,fs_ori);