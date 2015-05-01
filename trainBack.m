% % % %基于MIT  HRIR 数据卷积而成的 白噪声估计ITD和IID
clear all;
clc
fs = 44100;
frameSize = fs*0.06;%一帧为60ms
L = frameSize*2;
Offset = frameSize;
frameShift = frameSize/3;%帧移为20ms
MaxLag = 44;
onesample=1000000/fs;

for azimuth =0:5:90
    
    inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\data\\Speech\\方位白噪声\\WhiteNoise%03d.wav',azimuth);
    [y fs_read] = wavread(inPutFilePath);
    x_L = y(:,1);
    x_R = y(:,2);
    
    x_L = PreProccess(x_L,frameSize,frameShift);
    x_R = PreProccess(x_R,frameSize,frameShift);
    
    
    frameAmount = size(x_L,2);
    
    for n = 1:frameAmount
        
        Pxx = fft(x_L(:,n),L) ;
        Pyy = fft(x_R(:,n),L) ;
        Pxy = Pxx.*conj(Pyy);
        
        
        [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);
        G_new = G(Offset-MaxLag:Offset+MaxLag );
        delay_index=Offset-MaxLag:Offset+MaxLag;
        delay_us=delay_index/fs*1000000;
        predxaixs=delay_us(1):1:delay_us(end);
        predcurve=spline(delay_us,G_new,predxaixs);
        [R_max,index] = max(predcurve);
        ITD(azimuth/5+1,n) = index - (MaxLag+1)*onesample;
        % IID(azimuth/5+1,n,:) =20*log10(abs(Pyy./Pxx));
        
    end
    
    azimuth
    
end

mean_ITD = mean(ITD,2);
%mean_ITD = round(mean_ITD/onesample);
save E:\\MatlabCode\\train\\ITD_GCC_441  mean_ITD

% a=size(IID);
% mean_IID=ones(a(1),a(3));
% mean_IID(:,:)= mean(IID,2);
% save  F:\\科研\\研究方向\\2009年声源定位\\仿真\\program(周菲菲)\\IID_GCC  mean_IID


% %===================================================
% %===================================================
% %===================================================

% % % % % %直接由MIT FULL HRIR 数据估计ITD和IID，而不是由生成的方向性的白噪声信号估计ITD和IID
% clear all;
% clc
% fs = 44100;
% frameSize = fs*0.06;%一帧为60ms
% L = frameSize*2;
% Offset = frameSize;
% frameShift = round(frameSize/2);% 帧移
% MaxLag = 44;
% %对于后向的方位，采用低频的信号估计ITD(f<8kHz)，因为由于高频信号波长较小，因此容易被耳廓遮挡'
% LowF =round(1.5*L*1000/fs);
% FreqRange = zeros(L,1);
% FreqRange(1:LowF) = 1;
% FreqRange(L-LowF:L) = 1;
% 
% %估计IID时，采用子带IID形式，而不是每个频点估计IID
% %这里的子带个数选择为9
% NFreq = 9; % 每帧中的子带个数
% subframe = frameSize/NFreq;%每个子带的频点数
% 
% 
% %前向方位的ITD、IID估计
% for azimuth = 0:5:90
%     %左耳的HRIR
%     inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\data\\Speech\\方位白噪声\\WhiteNoise%03d.wav',azimuth);
%     [y fs_original] = wavread(inPutFilePath);
%     x_L = y(:,1);
%     %右耳的HRIR
%     x_R = y(:,2);
%     
%     %基于GCC估计ITD
%     Pxx = fft(x_L,L) ;
%     Pyy = fft(x_R,L) ;
%     Pxy = Pxx.*conj(Pyy);
%     
%     [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);
%     G_new = G(Offset-MaxLag:Offset+MaxLag );
%     [R_max,index] = max(G_new);
%     ITD(azimuth/5+1) = index - MaxLag-1;
%     IID(azimuth/5+1) =20*log10(sum(abs(Pyy).^2)./sum(abs(Pxx).^2));
%     
%     %     %估计子带IID
%     %     for subnum = 1:NFreq
%     %         index = subframe*(subnum-1)+1:subframe*subnum;
%     %         IID(azimuth/5+1,subnum) = 10*log10(sum(abs(Pyy(index)).^2)./sum(abs(Pxx(index)).^2));
%     %     end
%     
%     azimuth
% end
% 
% %后向方位的ITD、IID估计
% % for azimuth = 95:5:180
% %     %左耳的HRIR
% %     inPutFilePath = sprintf('F:\\科研\\研究方向\\2009年声源定位\\仿真\\data\\MITFullHRIR\\elev0\\L0e%03da.wav',azimuth);
% %     x_L = wavread(inPutFilePath);
% %     %右耳的HRIR
% %     inPutFilePath = sprintf('F:\\科研\\研究方向\\2009年声源定位\\仿真\\data\\MITFullHRIR\\elev0\\R0e%03da.wav',azimuth);
% %     x_R = wavread(inPutFilePath);
% %     
% %     
% %     %基于GCC估计ITD
% %     Pxx = fft(x_L,L) ;
% %     Pyy = fft(x_R,L) ;
% %     Pxy =Pxx.*conj(Pyy).*FreqRange;
%     
%     [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);
%     G_new = G(Offset-MaxLag:Offset+MaxLag );
%     [R_max,index] = max(G_new);
%     ITD(azimuth/5+1) = index - MaxLag-1;
%      IID(azimuth/5+1) =20*log10(sum(abs(Pyy).^2)./sum(abs(Pxx).^2));
%     
%     %     %估计子带IID
%     %     for subnum = 1:NFreq
%     %         index = subframe*(subnum-1)+1:subframe*subnum;
%     %         IID(azimuth/5+1,subnum) = 10*log10(sum(abs(Pyy(index)).^2)./sum(abs(Pxx(index)).^2));
%     %     end
%     
%     azimuth
% end
% 
% mean_ITD = ITD';
% save E:\\MatlabCode\\train\\ITD_HRIR  mean_ITD
% 
% mean_IID=IID';
% save  F:\\科研\\研究方向\\2009年声源定位\\仿真\\program(周菲菲)\\IID_HRIR mean_IID



% %==============================================================
% %利用生成的方向的语音文件来计算各个方位的ITD和IID参数
% %==============================================================
% %
% clc
% clear all;
% fs = 44100;
% frameDura = 60;% 帧长为60ms
% frameSize  = frameDura*fs/1000;%一帧采样点数
% L = frameSize*2;
% Offset = frameSize;
% frameShift = round(frameSize/2);% 帧移
% MaxLag = 44;
% %对于后向的方位，采用低频的信号估计ITD(f<8kHz)，因为由于高频信号波长较小，因此容易被耳廓遮挡'
% LowF =round(1.5*L*1000/fs);
% FreqRange = zeros(L,1);
% FreqRange(1:LowF) = 1;
% FreqRange(L-LowF:L) = 1;
% 
% %估计IID时，采用子带IID形式，而不是每个频点估计IID
% %这里的子带个数选择为9
% NFreq = 9; % 每帧中的子带个数
% subframe = frameSize/NFreq;%每个子带的频点数
% 
% % ============== 读取语音文件========================
% testfileindex = strvcat('\\female\\female','\\male\\male','\\music\\music');
% testfilenumber = 1;
% 
% % VAD标示
% VADFilePath = strcat('F:\\科研\\研究方向\\2009年声源定位\\仿真\\data\\虚拟声',testfileindex(testfilenumber,:),'_',num2str(frameDura),'_index.mat');
% load (VADFilePath);
% 
% %前向方位的ITD、IID估计
% for azimuth =0:5:90
%     %读取各方位的语音信号
%     inPutFilePath = strcat('F:\\科研\\研究方向\\2009年声源定位\\仿真\\data\\虚拟声',testfileindex(testfilenumber,:),'_',num2str(azimuth),'.wav');
%     [y fs] = wavread(inPutFilePath);
%     x_L = y(:,1);
%     x_R = y(:,2);
%     
%     x_L = PreProccess(x_L,frameSize,frameShift);
%     x_R = PreProccess(x_R,frameSize,frameShift);
%     
%     
%     frameAmount = size(x_L,2);
%     frameNumSound = 0;
%     
%     for n = 1:frameAmount
%         if vad(n) == 1
%             
%               frameNumSound = frameNumSound+1;
%             
%             %基于GCC估计ITD
%             Pxx = fft(x_L(:,n),L) ;
%             Pyy = fft(x_R(:,n),L) ;
%             Pxy = Pxx.*conj(Pyy);
%             
%             [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);
%             G_new = G(Offset-MaxLag:Offset+MaxLag );
%             [R_max,index] = max(G_new);
%             ITD(azimuth/5+1,frameNumSound) = index - MaxLag-1;
%             
%             %估计子带IID
%             for subnum = 1:NFreq
%                 index = subframe*(subnum-1)+1:subframe*subnum;
%                 IID(azimuth/5+1,frameNumSound,subnum) =10*log10(sum(abs(Pyy(index)).^2)./sum(abs(Pxx(index)).^2));
%             end
%             
%         else
%             continue
%         end
%         
%     end
%     azimuth
% end
% 
% %后向方位的ITD、IID估计
% for azimuth = 95:5:180
%     %读取各方位的语音信号
%     inPutFilePath = strcat('F:\\科研\\研究方向\\2009年声源定位\\仿真\\data\\虚拟声',testfileindex(testfilenumber,:),'_',num2str(azimuth),'.wav');
%     [y fs] = wavread(inPutFilePath);
%     x_L = y(:,1);
%     x_R = y(:,2);
%     
%     x_L = PreProccess(x_L,frameSize,frameShift);
%     x_R = PreProccess(x_R,frameSize,frameShift);
%     
%     
%     frameAmount = size(x_L,2);
%      frameNumSound = 0;
%     
%     for n = 1:frameAmount
%         if vad(n) == 1
%             
%             frameNumSound = frameNumSound+1;
%             
%             %基于GCC估计ITD
%             Pxx = fft(x_L(:,n),L) ;
%             Pyy = fft(x_R(:,n),L) ;
%             Pxy = Pxx.*conj(Pyy).*FreqRange;
%             
%             [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,L,L);
%             G_new = G(Offset-MaxLag:Offset+MaxLag );
%             [R_max,index] = max(G_new);
%             ITD(azimuth/5+1,frameNumSound) = index - MaxLag-1;
%             
%             %估计子带IID
%             for subnum = 1:NFreq
%                 index = subframe*(subnum-1)+1:subframe*subnum;
%                 IID(azimuth/5+1,frameNumSound,subnum) =10*log10(sum(abs(Pyy(index)).^2)./sum(abs(Pxx(index)).^2));
%             end
%             
%         else
%             continue
%         end
%     end
%     azimuth
% end
% 
% mean_ITD = mean(ITD,2);
% save F:\\科研\\研究方向\\2009年声源定位\\仿真\\program(周菲菲)\\ITD_speech  mean_ITD
% 
% 
% a=size(IID);
% mean_IID=ones(a(1),a(3));
% mean_IID(:,:)= mean(IID,2);
% save  F:\\科研\\研究方向\\2009年声源定位\\仿真\\program(周菲菲)\\IID_speech mean_IID
% 
% 
% 
% %        
% %===================================================
% %===================================================
% %===================================================
% 
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