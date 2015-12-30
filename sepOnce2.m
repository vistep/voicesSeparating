function [ tf_L_seped,tf_R_seped,err ] = sepOnce2( tf_L,tf_R,fs,dnnModel,factor,target )
%source location detect and sound sepration
%   input:
%         tf_L: TF units after window and segmentation of left channel
%         tf_R: TF units after window and segmentation of right channel
%   output:
%         tf_L_seped: redistributed left TF units
%         tf_R_seped: redistributed right TF units

%   info: Jiaming.Shu 2015.4.29
%   modifyed at 2015.12.12 by Jiaming.Shu 
%   using DNN to locate sound source direction
%   this function is based on sound seperation method to improve locating
%   ability

load('./trainData/ITD_GCC_16k.mat');
load('./trainData/IID_GCC_16k.mat');
load(dnnModel);
%%
%1.参数计算和设置
frameSize = size(tf_L,1);
frameAmount = size(tf_L,2);
frameShift = 256;
onesample = 1000000/fs;
degree = -90:10:90;
mean_ITD = mean_ITD(1:2:end);
mean_IID = mean_IID(:,1:2:end);
%%
%2.计算每帧的特征
vad = VAD(tfsynthesis(tf_R(:,:),sqrt(2)*hamming(frameSize)/(2*frameSize),frameShift),factor);
[IID, correlation] = featureExtract(tf_L(:,:),tf_R(:,:),vad);
correlation = bsxfun(@plus, correlation, 1);
correlation = bsxfun(@rdivide, correlation, 2);
feature_x = correlation;
target_y = zeros(size(feature_x,1),length(degree));
target_y(:,target) = 1;
%% 计算错误率和估计的角度
err = nntest(nn,feature_x,target_y);
labels = nnpredict(nn, feature_x);

%%
%4.声源分离 
freq=(0:frameSize-1)*(2*pi/(frameSize));
%4.2计算每个频点的掩码
mask = zeros(frameSize,frameAmount);
dis_mat = zeros(frameSize,frameAmount);
mask_tmp = zeros(frameSize,length(labels));
dis_tmp = zeros(frameSize,length(labels));
%将各个声源数据代入计算两声道对应频点之间的距离
IID_mat = mean_IID(:,labels);
dis_tmp(:,:) = ((abs(IID_mat.*tf_L(:,vad)-exp(-1j*freq'*mean_ITD(labels)./onesample).*tf_R(:,vad))).^2)./(ones(frameSize,length(labels))+IID_mat.^2);
%按最短距离原则计算mask
for i = 1:frameSize/2+1 %计算0~pi之间的mask
    for j = 1:length(labels)
        if dis_tmp(i,j)<0.5
            mask_tmp(i,j)=1;
        end
    end
end
%后一半的mask与前一半镜像对称
for n = 1:size(mask_tmp,3)
    mask_tmp(frameSize/2+2:frameSize,:,n) = flipud(mask_tmp(2:frameSize/2,:,n));
end
mask(:,vad) = mask_tmp;
%4.3根据掩码分离频点
tf_L_seped = zeros(size(mask));
tf_R_seped = zeros(size(mask));
for n = 1:size(mask,3)
    tf_L_seped(:,:,n) = tf_L .* mask(:,:,n);
    tf_R_seped(:,:,n) = tf_R .* mask(:,:,n);
end
end

