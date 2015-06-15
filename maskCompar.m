clc;clear;close all;  
%%
    %1.读取混合语音
    inPutFilePathF = sprintf('E:\\Document\\科研相关\\语音库\\data\\虚拟声\\whitenoise\\female_noise_10_10.wav');
    inPutFilePathM = sprintf('E:\\Document\\科研相关\\语音库\\data\\虚拟声\\whitenoise\\male_noise_10_70.wav');
    inPutFilePathMix = sprintf('E:\\MatlabCode\\seperation\\shu\\mixedvoice\\virtl_mixed_Wnoise_10_f_10_m_70.wav');
    [female,fs_original] = audioread(inPutFilePathF);
    [male,fs_original] = audioread(inPutFilePathM);
    [mix,fs_original] = audioread(inPutFilePathMix);
    len = min([size(female,1),size(male,1)]);
    x1 = female(1:len,:)./max(max(female(1:len,:))); 
    x2 = male(1:len,:)./max(max(male(1:len,:)));
    
    x_L = x2(:,1);
    x_R = x2(:,2);
    %%
    %2.预处理
    %2.1参数设置
    fs = 16000;
    %frameSize = fs*0.06;%一帧为60ms
    frameSize = 512;
    Offset = frameSize/2;
    frameShift = 128;
    MaxLag = 44;
    onesample = 1000000/fs;
    %2.2重采样
    if (fs_original==44100)
        x_L = resample(x_L,fs,fs_original);
        x_R = resample(x_R,fs,fs_original);
    end
    %2.3分帧加窗,时频分析
    awin=hamming(frameSize);
    tf_L=tfanalysis(x_L,awin,frameShift,frameSize); % time-freq domain
    tf_R=tfanalysis(x_R,awin,frameShift,frameSize) ; % time-freq domain
    
    tf_L_m = tf_L;
    tf_R_m = tf_R;
    
    %%
    %1.读取混合语音
    x_L = x1(:,1);
    x_R = x1(:,2);

    %2.2重采样
    if (fs_original==44100)
        x_L = resample(x_L,fs,fs_original);
        x_R = resample(x_R,fs,fs_original);
    end
    %2.3分帧加窗,时频分析
    awin=hamming(frameSize);
    tf_L=tfanalysis(x_L,awin,frameShift,frameSize); % time-freq domain
    tf_R=tfanalysis(x_R,awin,frameShift,frameSize) ; % time-freq domain
    
    tf_L_f = tf_L;
    tf_R_f = tf_R;
    
    mask_f = zeros(size(tf_L));
    for i = 1:size(tf_L,1)
        for j = 1:size(tf_L,2)
          if((abs(tf_L_f(i,j))^2+abs(tf_R_f(i,j)^2))>(abs(tf_L_m(i,j))^2+abs(tf_R_m(i,j)^2)))
              mask_f(i,j) = 1;
          end
        end
    end
    
    mask_m = ones(size(tf_L));
    mask_m = mask_m - mask_f;
    
    %1.读取混合语音
    x_L = mix(:,1);
    x_R = mix(:,2);

    %2.2重采样
    if (fs_original==44100)
        x_L = resample(x_L,fs,fs_original);
        x_R = resample(x_R,fs,fs_original);
    end
    %2.3分帧加窗,时频分析
    awin=hamming(frameSize);
    tf_L=tfanalysis(x_L,awin,frameShift,frameSize); % time-freq domain
    tf_R=tfanalysis(x_R,awin,frameShift,frameSize) ; % time-freq domain
    
    tf_L_f = tf_L.*mask_f;
    tf_R_f = tf_R.*mask_f;
    
    tf_L_m = tf_L.*mask_m;
    tf_R_m = tf_R.*mask_m;
    
    f = tfsynthesis(tf_R_f,sqrt(2)*awin/(2*frameSize),frameShift);
    m = tfsynthesis(tf_R_m,sqrt(2)*awin/(2*frameSize),frameShift);
    
    