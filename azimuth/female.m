%% 利用MIT的HRTR数据和白噪声信号生成具有方向性的噪声信号，0-360度
clear
clc
%读入的白噪声信号
fs = 16000;

inPutFilePath = 'E:\SPEECH\binauralCS\Source_Filter_based\FE2-MA1\orig1_lwwy2a_pbbv6n.wav';
inPutData = wavread(inPutFilePath);

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
    outPutFilePath = sprintf('E:\\SPEECH\\binauralCS\\FE2\\FE2_lwwy2a%03d.wav',azimuth);
    wavwrite(y,fs,outPutFilePath);
end