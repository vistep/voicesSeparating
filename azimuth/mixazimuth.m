clc;clear;
fs=16000;

soursenum=3;
azimuth=[20,40,350,140];

inPutFilePath ={sprintf('E:\\SPEECH\\binauralCS\\MA1\\MA1_pbbv6n%03d.wav',azimuth(1)),...
                    sprintf('E:\\SPEECH\\binauralCS\\FE1\\FE1_sbil4a%03d.wav',azimuth(2)),...
                    sprintf('E:\\SPEECH\\binauralCS\\MA2\\MA2_priv3n%03d.wav',azimuth(3)),...
                    sprintf('E:\\SPEECH\\binauralCS\\FE2\\FE2_lwwy2a%03d.wav',azimuth(4))};

y=[];filename='';
for i=1:soursenum
    x=wavread(char(inPutFilePath(i)));
    len=max(size(x,1),size(y,1));
    x=[x;zeros(len-size(x,1),2)];
    y=[y;zeros(len-size(y,1),2)];
    y=y+x;
    filename=[filename,'_',num2str(azimuth(i))];
end

wavwrite(y,fs,['C:\Users\Ray\Desktop\DUET_2\',num2str(soursenum),filename]);