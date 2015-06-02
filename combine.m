clc;clear;close all;
% addpath('E:\\Document\\�������\\lxx������
% [x1,fs_ori] = audioread('E:\\Document\\�������\\������\\data\\������\\female\\female_10.wav');
% [x2,fs_ori] = audioread('E:\\Document\\�������\\������\\data\\������\\male\\male_50.wav');
% [x3,fs_ori] = audioread('E:\\Document\\�������\\������\\data\\������\\music\\music_60.wav');
% [x1,fs_ori] = audioread('E:\\Document\\�������\\lxx������\\tmp\\1_5.wav');
% [x2,fs_ori] = audioread('E:\\Document\\�������\\lxx������\\tmp\\3_330.wav');

inPutFilePathF = sprintf('E:\\Document\\�������\\������\\data\\������\\whitenoise\\female_noise_10_10.wav');
inPutFilePathM = sprintf('E:\\Document\\�������\\������\\data\\������\\whitenoise\\male_noise_10_70.wav');
[female,fs] = audioread(inPutFilePathF);
[male,fs] = audioread(inPutFilePathM);
len = min([size(female,1),size(male,1)]);
x1 = female(1:len,:)./max(max(female(1:len,:))); 
x2 = male(1:len,:)./max(max(male(1:len,:)));
audiowrite(['E:\\MatlabCode\\seperation\\shu\\mixedvoice\\','female_regued.wav'],x1,fs);
audiowrite(['E:\\MatlabCode\\seperation\\shu\\mixedvoice\\','male_regued.wav'],x2,fs);
% for i = 0:10:90
%     for j = 0:10:90
%         inPutFilePathF = sprintf('E:\\Document\\�������\\������\\data\\������\\whitenoise\\female_noise_20_%02d.wav',i);
%         inPutFilePathM = sprintf('E:\\Document\\�������\\������\\data\\������\\whitenoise\\male_noise_20_%02d.wav',j);
%         [female,fs] = audioread(inPutFilePathF);
%         [male,fs] = audioread(inPutFilePathM);
%         len = min([size(female,1),size(male,1)]);
%         mixed = female(1:len,:)./max(max(female(1:len,:))) + male(1:len,:)./max(max(male(1:len,:)));
%         filename = ['virtl_mixed_Wnoise_20_f_',num2str(i),'_m_',num2str(j),'.wav'];
%         audiowrite(['E:\\MatlabCode\\seperation\\shu\\mixedvoice\\',filename],mixed,fs);
%     end
% end