
%% 利用MIT的HRTR数据和白噪声信号生成具有方向性的噪声信号，0-360度
clear
clc
%读入的白噪声信号
fs = 16000;

inPutFilePath = sprintf('E:\\SPEECH\\双耳声源定位\\wav\\white.wav');
inPutData = wavread(inPutFilePath,fs);

 %% 读compact数据库
% for azimuth = 0:5:180
%     %读入MIT Compact HRTF数据，0～180度，仰角为0度
%     inPutFilePath = sprintf('E:\\SPEECH\\HRTF(MIT)\\compact\\elev0\\H0e%03da.dat',azimuth);
%     hrir = readrawc(inPutFilePath);
%     hrir_L = hrir(:,1);
%     hrir_R = hrir(:,2);
%     x_L = conv(inPutData,hrir_L);
%     x_R = conv(inPutData,hrir_R);
%     
%     %语音信号的范围[-1  1]
%     MaxValue = max(max(abs(x_L)),max(abs(x_R)));
%     MaxValue = MaxValue + MaxValue/1000;
%     x_L = x_L/MaxValue;
%     x_R = x_R/MaxValue;
% 
%     y = [x_L,x_R];
%     %方向性的噪声信号
%     outPutFilePath = sprintf('E:\\SPEECH\\binauralCS\\方位白噪声\\WhiteNoise%03d.wav',azimuth);
%     wavwrite(y,fs,outPutFilePath);
% end
%% 读full数据库
for azimuth = 0:5:355
    %读入MIT full HRTF数据 仰角为0度
    if azimuth == 0
        inPutFilePathL = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e000a.dat');
        inPutFilePathR = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e000a.dat');
    else
        inPutFilePathL = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e%03da.dat',azimuth);
        inPutFilePathR = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e%03da.dat',360-azimuth);
    end
    hrir_L = readraw(inPutFilePathL);
    hrir_R = readraw(inPutFilePathR);
    x_L = conv(inPutData,hrir_L);
    x_R = conv(inPutData,hrir_R);
    
    %语音信号的范围[-1  1]
    MaxValue = max(max(abs(x_L)),max(abs(x_R)));
    MaxValue = MaxValue + MaxValue/1000;
    x_L = x_L/MaxValue;
    x_R = x_R/MaxValue;

    y = [x_L,x_R];
    %方向性的噪声信号
    outPutFilePath = sprintf('E:\\SPEECH\\binauralCS\\方位白噪声16k\\WhiteNoise%03d.wav',azimuth);
    wavwrite(y,fs,outPutFilePath);
end