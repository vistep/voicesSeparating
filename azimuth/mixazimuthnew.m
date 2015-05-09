clear;clc;
addpath('E:\\Document\\科研相关\\lxx语音库\\azimuth');
fs = 16000;
soursenum=3;
azimuth=[5,40,330,280];
inPutFilePath ={'E:\\Document\\科研相关\\lxx语音库\\azimuth\\s18.wav',...
                'E:\\Document\\科研相关\\lxx语音库\\azimuth\\s1.wav',...
                'E:\\Document\\科研相关\\lxx语音库\\azimuth\\s2.wav',...
                'E:\\Document\\科研相关\\lxx语音库\\azimuth\\s9.wav'};

% 读full数据库
out=[];filename='';
for i=soursenum
    clear voice y x_L x_R x
    if azimuth(i) == 0
        inPutFilePathL = sprintf('E:\\Document\\科研相关\\lxx语音库\\HRTF(MIT)\\full\\elev0\\L0e000a.dat');
        inPutFilePathR = sprintf('E:\\Document\\科研相关\\lxx语音库\\HRTF(MIT)\\full\\elev0\\L0e000a.dat');
    else
        inPutFilePathL = sprintf('E:\\Document\\科研相关\\lxx语音库\\HRTF(MIT)\\full\\elev0\\L0e%03da.dat',azimuth(i));
%         inPutFilePathR = sprintf('E:\\Document\\科研相关\\lxx语音库\\HRTF(MIT)\\full\\elev0\\L0e%03da.dat',360-azimuth(i));
        inPutFilePathR = sprintf('E:\\Document\\科研相关\\lxx语音库\\HRTF(MIT)\\full\\elev0\\R0e%03da.dat',azimuth(i));
    end
    hrir_L = readraw(inPutFilePathL);
    hrir_R = readraw(inPutFilePathR);
    
    x=wavread(char(inPutFilePath(i)));
    x_L = conv(x,hrir_L);
    x_R = conv(x,hrir_R);

    %语音信号的范围[-1  1]
    MaxValue = max(max(abs(x_L)),max(abs(x_R)));
    MaxValue = MaxValue + MaxValue/1000;
    x_L = x_L/MaxValue;
    x_R = x_R/MaxValue;
    
    y = [x_L,x_R];
    
    len=max(size(out,1),size(y,1));
    out=[out;zeros(len-size(out,1),2)];
    y=[y;zeros(len-size(y,1),2)];
    out=out+y;
    filename=[filename,'_',num2str(azimuth(i))];
end

wavwrite(out,fs,['E:\\Document\\科研相关\\lxx语音库\\tmp\\',num2str(soursenum),filename]);



% %生成与带角度的语音长度一致的原始语音数据
% clear;clc;
% addpath('E:\SPEECH\binauralCS\code\azimuth');
% fs = 16000;
% soursenum=1;
% inPutFilePath ={'E:\SPEECH\binauralCS\code\azimuth\s2.wav'};
% 
% % 读full数据库
% out=[];filename='s2';
% for i=1:soursenum
%     clear voice y x_L x_R x
%     inPutFilePathL = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e000a.dat');
%     inPutFilePathR = sprintf('E:\\SPEECH\\HRTF(MIT)\\full\\elev0\\L0e000a.dat');
%     hrir_L = readraw(inPutFilePathL);
%     hrir_R = readraw(inPutFilePathR);
%     
%     x=wavread(char(inPutFilePath(i)));
%     x_L = conv(x,hrir_L);
%     %语音信号的范围[-1  1]
%     MaxValue = max(abs(x_L));
%     MaxValue = MaxValue + MaxValue/1000;
%     x_L = x_L/MaxValue;
%     y = x_L;
%     filename=[filename,'_',num2str(0)];
% end
% wavwrite(y,fs,['E:\SPEECH\binauralCS\code\selectedDUET\',filename]);