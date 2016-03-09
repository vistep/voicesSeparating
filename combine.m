clc;clear;close all;

% deg = [30,350,60;
%     10,300,40;
%     20,280,70;
%     40,290,10;
%     70,340,30];

% deg = [10,320,60,280;
%     20,300,50,270;
%     20,280,70,310;
%     40,290,10,330;
%     70,340,30,280];

deg = 10:10:90;

Rev = '_Rev_600';
for SNR = 0:5:20
    for i = 1:length(deg)
        inPutFilePath1 = sprintf('E:\\Document\\科研相关\\语音库\\有混响\\TestData\\female_0_white_%d%s.wav',SNR,Rev);
        inPutFilePath2 = sprintf('E:\\Document\\科研相关\\语音库\\有混响\\TestData\\male_%d_white_%d%s.wav',deg(i),SNR,Rev);
%         inPutFilePath3 = sprintf('E:\\Document\\科研相关\\语音库\\180度声源\\male2_%d_white_%d%s.wav',deg(i,3),SNR,Rev);
%         inPutFilePath4 = sprintf('E:\\Document\\科研相关\\语音库\\180度声源\\male1_%d_white_%d%s.wav',deg(i,4),SNR,Rev);
        
        [y1,fs] = audioread(inPutFilePath1);
        [y2,fs] = audioread(inPutFilePath2);
%         [y3,fs] = audioread(inPutFilePath3);
%         [y4,fs] = audioread(inPutFilePath4);
        
        y1 = y1./max(max(abs(y1)));
        y2 = y2./max(max(abs(y2)));
%         y3 = y3./max(max(abs(y3)));
%         y4 = y4./max(max(abs(y4)));
        
%         L = 473000;
        L = min([size(y1,1),size(y2,1)]);
        
        y1 = y1(1:L,:);
        y2 = y2(1:L,:);
%         y3 = y3(1:L,:);
%         y4 = y4(1:L,:);
        
        y = y1+y2;
        
        audiowrite(['./mixedvoice/SMAD/female_male_0_' num2str(deg(i)) '_white_' num2str(SNR) Rev '.wav'],y,fs);
    end
end

