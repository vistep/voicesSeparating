%把带方位的s1和s9混合起来 论文用 共37*37种情况

clear;clc;
addpath('E:\SPEECH\binauralCS\code\azimuth');
fs = 16000;

s9A=5:5:90;
s1A=270:5:355;

for t1=5:5:90
    for t2=270:5:355

clear voice y x_L x_R x

[s9,fs]=wavread(strcat('E:\SPEECH\binauralCS\方位s9_16k\s9_',num2str(t1))); %16k
[s1,fs]=wavread(strcat('E:\SPEECH\binauralCS\方位s1_16k\s1_',num2str(t2))); %16k

len=max(size(s9,1),size(s1,1));
s9=[s9;zeros(len-size(s9,1),2)];
s1=[s1;zeros(len-size(s1,1),2)];

x_L=s9(:,1)+s1(:,1);
x_R=s9(:,2)+s1(:,2);

y = [x_L,x_R];
    
wavwrite(y,fs,['E:\SPEECH\binauralCS\方位s9_s1\',num2str(t1),'_',num2str(t2)]);

    end
end