function [ tf_L_seped,tf_R_seped,mono,azimuthout ] = sepOnce( tf_L,tf_R,fs,sourceNum,dnnModel,factor )
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

load('./trainData/ITD_GCC_16k.mat');
load('./trainData/IID_GCC_16k.mat');
load(dnnModel);
%%
%1.参数计算和设置
frameSize = size(tf_L,1);
frameAmount = size(tf_L,2);
audioNum = size(tf_L,3);
frameShift = 256;
onesample = 1000000/fs;
degree = -90:10:90;
mean_ITD = mean_ITD(1:2:end);
mean_IID = mean_IID(:,1:2:end);
%%
%2.计算每帧的特征
feature_x = cell(1,audioNum);
for audioIter = 1:audioNum
    vad = VAD(tfsynthesis(tf_R(:,:,audioIter),sqrt(2)*hamming(frameSize)/(2*frameSize),frameShift),factor);
    [IID, correlation] = featureExtract(tf_L(:,:,audioIter),tf_R(:,:,audioIter),vad);
    correlation = bsxfun(@plus, correlation, 1);
    correlation = bsxfun(@rdivide, correlation, 2);
    feature_x{audioIter} = [IID, correlation];
end

%%
%声源的估计分为两类。A:第一次分离。B:语音分离后仅重新估计声源位置
if(audioNum == 1)
%partA
labels = nnpredict(nn, feature_x{1});
deg = degree(labels);
deg_tmp = deg(deg~=0);
% [IDX, center] = kmeans(deg,sourceNum,'start',[deg(1);deg_tmp(1)]);
% [IDX, center] = kmeans(deg,sourceNum,'start',[deg_tmp(1);-1*deg_tmp(1)]);
[nelements, binCenter] = hist(deg,-90:10:90);
[~,idtmp] = sort(nelements);
center = binCenter(idtmp(length(nelements) - sourceNum + 1 : end));
else
%partB
for audioIter = 1:audioNum
    labels = nnpredict(nn, feature_x{audioIter});
    deg = degree(labels);
    [nelements, binCenter] = hist(deg,-90:10:90);
%     binCenter = binCenter(nelements > length(deg)*0.2);
%     nelements = nelements(nelements > length(deg)*0.2);
%     center(audioIter) = sum(binCenter .* nelements)/sum(nelements);
    [~,idtmp] = max(nelements);
    center(audioIter) = binCenter(idtmp);
end
end
%计算最近的角度
sourceIndex = nan(size(center));
for n = 1:length(center)
    [~ , sourceIndex(n)] = min(abs(center(n).*ones(size(degree)) - degree));
end
azimuthout = degree(sourceIndex);
sourceITD = mean_ITD(sourceIndex);
%%
%4.声源分离 
freq=(0:frameSize-1)*(2*pi/(frameSize));
fmat=freq(ones(size(tf_L,2),1),:)';
%4.2计算每个频点的掩码
% mask = 0.01*ones(frameSize,frameAmount,sourceNum);%最后一维代表声源编号
mask = zeros(frameSize,frameAmount,sourceNum);%最后一维代表声源编号
dis_mat = zeros(frameSize,frameAmount,sourceNum);
%将分离开的频点组合起来
tf_L = sum(tf_L,3);
tf_R = sum(tf_R,3);

%将各个声源数据代入计算两声道对应频点之间的距离
for sourceIter = 1:sourceNum
    IID_mat = repmat(mean_IID(:,sourceIndex(sourceIter)),1,frameAmount);
    dis_mat(:,:,sourceIter) = ((abs(IID_mat.*tf_L-exp(-1j*sourceITD(sourceIter)/onesample.*fmat).*tf_R)).^2)./(ones(frameSize,frameAmount)+IID_mat.^2);
end
%按最短距离原则计算mask
for i = 1:frameSize/2+1 %计算0~pi之间的mask
    for j = 1:frameAmount
        [~,belong] = min(dis_mat(i,j,:));
        mask(i,j,belong) = 1;
    end
end
%后一半的mask与前一半镜像对称
for n = 1:size(mask,3)
    mask(frameSize/2+2:frameSize,:,n) = flipud(mask(2:frameSize/2,:,n));
end
%4.3根据掩码分离频点
tf_L_seped = zeros(size(mask));
tf_R_seped = zeros(size(mask));
mono = zeros(size(mask));
for n = 1:size(mask,3)
    tf_L_seped(:,:,n) = tf_L .* mask(:,:,n);
    tf_R_seped(:,:,n) = tf_R .* mask(:,:,n);
    a_mat = repmat(mean_IID(:,sourceIndex(n)),1,frameAmount);
    mono(:,:,n) = (tf_L_seped(:,:,n).*exp(1j*sourceITD(n)/onesample.*fmat) + a_mat.*tf_R_seped(:,:,n))./(ones(frameSize,frameAmount)+a_mat.^2);
end

end

