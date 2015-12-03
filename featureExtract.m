function [ IID, correlation, ITD ] = featureExtract( tf_L, tf_R, vad)
%Extract IID and correlation features from each frame
%   audioFile is downsampled to 16kHz
%   FFT is made on 512 points
%   author: Shu Jiaming
%   date: 2015-10-26

%%
frameSize = 512;
Offset = frameSize;
MaxLag = 16;
fs = 16000;
tf_L=tf_L(:,vad);
tf_R=tf_R(:,vad);
frameAmount = size(tf_L,2);

%%
%correlation & IID
for n = 1:frameAmount
    %correlation
    Pxx = tf_L(:,n);
    Pyy = tf_R(:,n);
    Pxx1 = fft(ifft(Pxx),2*frameSize);
    Pyy1 = fft(ifft(Pyy),2*frameSize);
    Pxy1 = Pxx1.*conj(Pyy1);
    [G,~,~] = GCC('PHAT',Pxx1,Pyy1,Pxy1,fs,2*frameSize,2*frameSize);
    delay_index = Offset-MaxLag:Offset+MaxLag;
%     delay_us = delay_index*onesample;
    G_new = G(delay_index);
    [~,itd] = max(G_new);
    itd = itd / (2 * MaxLag + 1);
    ITD(n,:) = itd;
    G_new = G_new ./ max(abs(G_new));
%     predxaxis = delay_us(1):1:delay_us(end);
%     predcure = spline(delay_us,G_new,predxaxis);
    correlation(n,:) = G_new';
    %IID
    R21temp=(Pyy+eps)./(Pxx+eps);
    atemp=abs(R21temp); %relative attenuation between the two mixtures
    alphatemp = atemp-1./atemp;% alpha ( symmetric at tenuation )
    IID(n,:) = atemp ./ max(abs(atemp));
end
end

