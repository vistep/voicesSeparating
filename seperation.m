clc;clear;close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%1.读取混合语音
% inPutFilePath = 'E:\\MatlabCode\\seperation\\shu\\female_10_30_60.wav';
inPutFilePath = 'E:\\MatlabCode\\seperation\\shu\\music_male_10_50.wav';
% inPutFilePath = 'E:\\MatlabCode\\seperation\\shu\\music_female_10_50.wav';
[y, fs_original] = audioread(inPutFilePath);
x_L = y(:,1);
x_R = y(:,2);
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
x_L = resample(x_L,fs,fs_original);
x_R = resample(x_R,fs,fs_original);
%2.3分帧加窗,时频分析
awin=hamming(frameSize);
tf_L=tfanalysis(x_L,awin,frameShift,frameSize); % time-freq domain
tf_R=tfanalysis(x_R,awin,frameShift,frameSize) ; % time-freq domain
%tf_L(1,:)=[];tf_R(1,:)=[]; % remove dc component from mixtures
%%
%3.计算每帧的ITD
frameAmount = size(tf_L,2);
ITD = zeros(1,frameAmount);
for n = 1:frameAmount

    Pxx = tf_L(:,n);
    Pyy = tf_R(:,n);
    Pxy = Pxx.*conj(Pyy);
    
    [G,t,R] = GCC('PHAT',Pxx,Pyy,Pxy,fs,frameSize,frameSize);
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
        if(abs(ITD(n)-source_list{1,i}.getMean)<25)
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
sourceMean1 = sourceMean(sourceCount>frameAmount*0.1);
%4.5与训练数据对比，确定声源位置
load('./trainData/ITD_GCC_16k.mat');
sourceIndex = zeros(1,length(sourceMean1));
sourceITD = zeros(1,length(sourceMean1));
for n = 1:length(sourceITD)
    [~,minIndex] = min(abs(sourceMean1(1,n)*ones(1,length(mean_ITD))-mean_ITD));
    sourceIndex(1,n) = minIndex;
    sourceITD(1,n) = mean_ITD(minIndex);
end
sourceNum = length(sourceITD);
%%
%5.声源分离 
% mask = zeros(length(sourceITD),frameAmount);
% for n = 1:frameAmount
%     [~,belong] = min(abs(ITD(n)*ones(1,length(sourceITD))-sourceITD));
%     mask(belong,n) = 1;
% end
%5.1计算每个频点的ITD
%freq=[(0:frameSize/2) ((-frameSize/2)+1:-1)]*(2*pi/(frameSize));
freq=(0:frameSize-1)*(2*pi/(frameSize));
fmat=freq(ones(size(tf_L,2),1),:)';
R21=(tf_L+eps)./(tf_R+eps); 
delta=-imag(log(R21))./fmat;
delta(1,:) = zeros(1,size(delta,2)); %直流分量的相位差为0
delta = onesample*delta; %转换成us
%5.2计算每个频点的掩码
load('./trainData/IID_GCC_16k.mat');
mask = zeros(frameSize,frameAmount,sourceNum);%最后一维代表声源编号

% for n = 1:frameAmount
%     for i = 1:frameSize
%         [~,belong] = min(abs(delta(i,n)*ones(1,length(sourceITD))-sourceITD));
%         mask(i,n,belong) = 1;
%     end
% end

for n = 1:frameAmount
    for i = 1:frameSize
        distance = zeros(1,sourceNum);
        for j = 1:sourceNum
%             distance(1,j) = (abs(mean_IID(i,sourceIndex(j))*exp(-1j*2*pi/frameSize*i*sourceITD(j)/onesample)*tf_L(i,n)-tf_R(i,n)))^2....
%             /(1+(mean_IID(i,sourceIndex(j)))^2);
            distance(1,j) = (abs(mean_IID(i,sourceIndex(j))*tf_L(i,n)-exp(-1j*2*pi/frameSize*i*sourceITD(j)/onesample)*tf_R(i,n)))^2....
            /(1+(mean_IID(i,sourceIndex(j)))^2);
        end
        [~,belong] = min(distance);
        mask(i,n,belong) = 1;
    end 
end


%5.3根据掩码分离频点
tf_L_seped = zeros(size(mask));
tf_R_seped = zeros(size(mask));
mono = zeros(size(mask));
for n = 1:size(mask,3)
    tf_L_seped(:,:,n) = tf_L .* mask(:,:,n);
    tf_R_seped(:,:,n) = tf_R .* mask(:,:,n);
    a_mat = repmat(mean_IID(:,sourceIndex(n)),1,frameAmount);
    mono(:,:,n) = (tf_L_seped(:,:,n).*(exp(1j*2*pi/frameSize*sourceITD(n)/onesample)*fmat) + a_mat.*tf_R_seped(:,:,n))./(ones(frameSize,frameAmount)+a_mat.^2);
end
%5.4转换回到时域
output = cell(1,sourceNum);
for n = 1:sourceNum
    output{n}=tfsynthesis(mono(:,:,n),sqrt(2)*awin/(2*frameSize),frameShift);
end




    