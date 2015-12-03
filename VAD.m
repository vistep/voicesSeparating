function [ vad1 ] = VAD( x,factor )
%UNTITLED1 Summary of this function goes here
%  Detailed explanation goes here
% 对原始女声、男声进行端点检测，得到每一帧信号的端点检测标记文件_index.mat
%注意这里的标记文件与帧长、帧重叠长度都有关系

fs = 16000;%降采样后的采样率
% frameDura = 60;%帧长
frameSize  = 512;
frameShift = 256;
L = frameSize*400;
% factor = 0.5;
 
% for k=1:size(FilePath,1)
%     x = wavread(testFilePath);
    testData = x(:,1);    
    E = sum(power(testData,2))/length(testData);
    threshold = E*frameSize*factor;%
    
    
    x = PreProccess(testData,frameSize,frameShift);
    EnFrame = sum(power(x,2));
    vad = EnFrame>threshold;
    vad1 = [EnFrame 0]>threshold;
%     outPutFilePath = strcat(FilePath(k,:),'_',num2str(frameSize),'_index.mat');
%     save(outPutFilePath,'vad','vad1')
    
    [M N] = size(x);
    y = reshape(x,1,M*N);
    index = repmat(vad,M,1);
    index = reshape(index,1,M*N);
    figure()
     plot(y(1:L));
     hold on
     plot(0.2*index(1:L),'r')       
% end

