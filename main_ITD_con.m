function [ output_args ] = main_ITD_con( input_args )
%MAIN_ITD_延迟值 Summary of this function goes here
%   Detailed explanation goes here
% % %基于MIT的HRTF数据计算结果
clear all;
clc
fs = 44100;
frameSize = fs*0.04;%一帧为40ms
L = frameSize*2;
Offset = frameSize;
frameShift = frameSize/3;%帧移为20ms
MaxLag = 44;


for azimuth = 0:5:90
    
    inPutFilePath = sprintf('F:\\科研\\研究方向\\2009年声源定位\\仿真\\data\\Speech\\方位白噪声\\WhiteNoise%03d.wav',azimuth);
    [y fs] = wavread(inPutFilePath);
    x_L = y(:,1);
    x_R = y(:,2);
    
    x_L = PreProccess(x_L,frameSize,frameShift);
    x_R = PreProccess(x_R,frameSize,frameShift);
    
           
    frameAmount = size(x_L,2);
    
    for n = 1:frameAmount

        %根据功率谱估计互相关函数
        Pxx = fft(x_L(:,n),L) ;
        Pyy = fft(x_R(:,n),L) ;
        Pxy = Pxx.*conj(Pyy);
               
        [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);  
        %估计得到的互相关函数
        G_new = G(Offset-MaxLag:Offset+MaxLag );
        
        cc1 = correlogram(G_new, -1000, 1000, 'power', 'cc', x_L(:,n)', x_R(:,n)', fs, round(fs/4), 0);   
        cur_itd = ccgrampeak(cc1, 'largest', 0);
        
        ITD_con(azimuth/5+1,n) =cur_itd;    
       % IID(azimuth/5+1,n,:) =20*log10(abs(Pyy./Pxx));
              
    end

    azimuth
    
end
%save ITD  ITD 
%save IID  IID

mean_ITD = mean(ITD_con,2);
save F:\\科研\\研究方向\\2009年声源定位\\仿真\\program(周菲菲)\\ITD_Con  mean_ITD 
% 
% a=size(IID);
% mean_IID=ones(a(1),a(3));
% mean_IID(:,:)= mean(IID,2);
% save  F:\\科研\\研究方向\\2009年声源定位\\仿真\\program(周菲菲)\\IID_GCC  mean_IID 


%===================================================
%===================================================
%===================================================

% %基于CIPIC的HRTF数据计算结果
% clear all;
% clc
% fs = 44100;
% frameSize = fs*0.03;
% L = frameSize*2;
% Offset = frameSize;
% frameShift = frameSize/3;
% MaxLag = 44;
% 
% 
% A = [0:5:45 55 65 80 ];  LA = length(A);
% azimuth = [ A, 180-A(LA:-1:1)]; % Azimuths
% E = -45:(360/64):235;                  LE = length(E);  % Elevation
% 
% for azi_index = 15:length(azimuth)
%     
%     inPutFilePath = sprintf('F:\\科研\\研究方向\\2009年声源定位\\仿真\\data\\Speech\\方位白噪声\\WhiteNoise%03d.wav',azimuth(azi_index));
%     [y fs] = wavread(inPutFilePath);
%     x_L = y(:,1);
%     x_R = y(:,2);
%     
%     x_L = PreProccess(x_L,frameSize,frameShift);
%     x_R = PreProccess(x_R,frameSize,frameShift);
%     
%            
%     frameAmount = size(x_L,2);
%     
%     for n = 1:frameAmount
%         
%         Pxx = fft(x_L(:,n),L) ;
%         Pyy = fft(x_R(:,n),L) ;
%         Pxy = Pxx.*conj(Pyy);
%       
% 
%                
% %        [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);  
%        [G,t,R] = GCC('unfiltered',Pxx,Pyy,Pxy,fs,L,L);
%         G_new = G(Offset-MaxLag:Offset+MaxLag );
%         [R_max,index] = max(G_new);
%         ITD(azi_index,n) = index - MaxLag-1;    
%         IID(azi_index,n,:) =20*log10(abs(Pyy./Pxx));
%               
%     end
% 
%     azimuth(azi_index)
%     
% end
% save ITD  ITD 
% save IID  IID
% 
% mean_ITD = mean(ITD,2);
% save F:\\科研\\研究方向\\2009年声源定位\\仿真\\program(周菲菲)\\ITD_GCC  mean_ITD 
% 
% a=size(IID);
% mean_IID=ones(a(1),a(3));
% mean_IID(:,:)= mean(IID,2);
% save  F:\\科研\\研究方向\\2009年声源定位\\仿真\\program(周菲菲)\\IID_GCC  mean_IID 
% 
% end

