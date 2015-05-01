clc;clear;close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%1.读取混合语音
inPutFilePath = 'E:\\MatlabCode\\seperation\\shu\\hybrid_10_30_60.wav';
[y, fs_original] = audioread(inPutFilePath);
x_L = y(:,1);
x_R = y(:,2);
%%
%2.预处理
%2.1参数设置
fs = 16000;
frameSize = fs*0.06;%一帧为60ms
L = frameSize*2;
Offset = frameSize;
frameShift = frameSize/3;%帧移为20ms
MaxLag = trameSize/10;
onesample = 1000000/fs;
%2.2重采样
x_L = resample(x_L,fs,fs_original);
x_R = resample(x_R,fs,fs_original);
%2.3分帧加窗,时频分析
x_L = PreProccess(x_L,frameSize,frameShift);
x_R = PreProccess(x_R,frameSize,frameShift);
%%
%3.计算每帧的ITD
frameAmount = size(x_L,2);
ITD = zeros(1,frameAmount);
for n = 1:frameAmount

    Pxx = fft(x_L(:,n),L) ;
    Pyy = fft(x_R(:,n),L) ;
    Pxy = Pxx.*conj(Pyy);
    
    [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);
    delay_index=Offset-MaxLag:Offset+MaxLag;
    delay_us=delay_index/fs*1000000;
    G_new = G(delay_index);
    predxaxis=delay_us(1):1:delay_us(end);
    predcure=spline(delay_us,G_new,predxaxis);
    [~,cur_itd]=max(predcure);
    
    ITD(n) = cur_itd-(MaxLag+1)*onesample;
end
%%
%4.统计ITD,定位声源
%4.1将第一个ITD归入第一个声源
source_list = cell(1);
newSource = Source(1,ITD(1));
source_list{1,1} = newSource;
%4.2根据阈值将各个ITD归入已有声源或新建声源
for n = 2:frameAmount
    flag = 0;
    for i = 1:length(source_list)
        if(abs(ITD(n)-source_list{1,i}.getMean)<30)
            source_list{1,i} = source_list{1,i}.Add(n,ITD(n));
            flag = 1;
            break;
        end
    end
    if(flag == 0)
        newSource = Source(n,ITD(n));
        newList = cell(1);
        newList{1,1} = newSource;
        source_list = [source_list, newList];
    end
end
%4.3统计归类后的声源
sourceCount = zeros(1,length(source_list));
sourceMean = zeros(1,length(source_list));
for n = 1:length(source_list)
    sourceCount(1,n) = source_list{1,n}.getNum;
    sourceMean(1,n) = source_list{1,n}.getMean;
end
%4.4排除野点造成的假声源
sourceMean1 = sourceMean(sourceCount>frameAmount*0.05);
%4.5与训练数据对比，确定声源位置
load('./trainData/ITD_GCC_16k.mat');
sourceITD = zeros(1,length(sourceMean1));
for n = 1:length(sourceITD)
    [~,minIndex] = min(abs(sourceMean1(1,n)*ones(1,length(mean_ITD))-mean_ITD));
    sourceITD(1,n) = mean_ITD(minIndex);
end
%%
%5.声源分离 
mask = zeros(length(sourcITD),frameAmount);
for n = 1:frameAmount
    [~,belong] = min(abs(ITD(n)*ones(1,length(sourcITD))-sourceITD));
    mask(belong,n) = 1;
end



    