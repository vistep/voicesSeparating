function [ tf_L_seped,tf_R_seped,mono,azimuthout ] = sepOnce( tf_L,tf_R,fs,sourceNum )
%source location detect and sound sepration
%   input:
%         tf_L: TF units after window and segmentation of left channel
%         tf_R: TF units after window and segmentation of right channel
%   output:
%         tf_L_seped: redistributed left TF units
%         tf_R_seped: redistributed right TF units

%   info: Jiaming.Shu 2015.4.29
azimuth = -90:5:90;
load('./trainData/ITD_GCC_16k.mat');
load('./trainData/IID_GCC_16k.mat');
%%
%1.参数计算和设置
frameSize = size(tf_L,1);
frameAmount = size(tf_L,2);
audioNum = size(tf_L,3);
Offset = frameSize;
% frameShift = 128;
MaxLag = 44;
onesample = 1000000/fs;

%%
%2.计算每帧的ITD
ITD = zeros(1,frameAmount,audioNum);
for audioIter = 1:audioNum
    for n = 1:frameAmount

        Pxx = tf_L(:,n,audioIter);
        Pyy = tf_R(:,n,audioIter);
        Pxx1 = fft(ifft(Pxx),2*frameSize);
        Pyy1 = fft(ifft(Pyy),2*frameSize);
        Pxy1 = Pxx1.*conj(Pyy1);

        [G,~,~] = GCC('PHAT',Pxx1,Pyy1,Pxy1,fs,2*frameSize,2*frameSize);
        delay_index=Offset-MaxLag:Offset+MaxLag;
        delay_us=delay_index/fs*1000000;
        G_new = G(delay_index);
        predxaxis=delay_us(1):1:delay_us(end);
        try
            predcure=spline(delay_us,G_new,predxaxis);
            [~,cur_itd]=max(predcure);
            ITD(1,n,audioIter) = cur_itd-(MaxLag+1)*onesample;
        catch
            ITD(1,n,audioIter) = NaN;
        end
    end
end
%2.1计算每一帧的能量
ener = zeros(1,frameAmount,audioNum);
for audioIter = 1:audioNum
    for n = 1:frameAmount
        ener(1,n,audioIter) = sum(abs(tf_L(:,n,audioIter)).^2+abs(tf_R(:,n,audioIter)).^2)/frameSize;
    end
end
ITD(ener<0.1) = NaN;%%将能量低于阈值的帧算出来的ITD置为无效

%%
%声源的估计分为两类。A:第一次分离。B:语音分离后仅重新估计声源位置
if(audioNum == 1)
%partA
    %3.统计ITD,定位声源
    %3.0整理ITD
    ITD = reshape(ITD,1,frameAmount*audioNum);
    ITD(isnan(ITD))=[]; %删除NaN
    %3.1将第一个ITD归入第一个声源
    source_list = cell(1);
    newSource = Source(1,ITD(1));
    source_list{1,1} = newSource;
    %3.2根据阈值将各个ITD归入已有声源或新建声源
    for ITDiter = 1:length(ITD)
        flag = 0;
        for i = 1:length(source_list)
            if(abs(ITD(ITDiter)-source_list{1,i}.getMean)<30)        %阈值1：规定多少范围内的ITD算作一个声源的
                source_list{1,i} = source_list{1,i}.Add(ITDiter,ITD(ITDiter));
                flag = 1;
                break;
            end
        end
        if(flag == 0)
            newSource = Source(ITDiter,ITD(ITDiter));
            newList = cell(1);
            newList{1,1} = newSource;
            source_list = [source_list, newList];
        end
    end
    %3.3统计归类后的声源
    sourceCount = zeros(1,length(source_list));
    sourceMean = zeros(1,length(source_list));
    for n = 1:length(source_list)
        sourceCount(1,n) = source_list{1,n}.getNum;
        sourceMean(1,n) = source_list{1,n}.getMean;
    end
%     %3.4排除野点造成的假声源
%     sourceMean1 = sourceMean(sourceCount>length(ITD)*0.1);                     %阈值2:规定多少频率以下的算作假声源
    %3.4根据sourceNum选出数量最多的几个声源
    sourceMean1 = zeros(1,sourceNum);
    for n = 1:length(sourceMean1)
        [~,index] = max(sourceCount);
        sourceMean1(n) = sourceMean(index);
        sourceCount(index) = 0;
    end
    %3.5与训练数据对比，确定声源位置
    % sourceIndex = zeros(1,length(sourceMean1));
    sourceITD = zeros(1,length(sourceMean1));
    for n = 1:length(sourceITD)
        [~,minIndex] = min(abs(sourceMean1(1,n)*ones(1,length(mean_ITD))-mean_ITD));
    %     sourceIndex(1,n) = minIndex;
        sourceITD(1,n) = mean_ITD(minIndex);
    end
else
%partB
    sourceITD = zeros(1,audioNum);
    for audioIter = 1:audioNum
         %3.0整理ITD
        ITDtmp = ITD(1,:,audioIter);
        ITDtmp = reshape(ITDtmp,1,frameAmount);
        ITDtmp(isnan(ITDtmp))=[]; %删除NaN
        %3.1将第一个ITD归入第一个声源
        source_list = cell(1);
        newSource = Source(1,ITDtmp(1));
        source_list{1,1} = newSource;
        %3.2根据阈值将各个ITD归入已有声源或新建声源
        for ITDiter = 1:length(ITDtmp)
            flag = 0;
            for i = 1:length(source_list)
                if(abs(ITDtmp(ITDiter)-source_list{1,i}.getMean)<25)        %阈值1：规定多少范围内的ITD算作一个声源的
                    source_list{1,i} = source_list{1,i}.Add(ITDiter,ITDtmp(ITDiter));
                    flag = 1;
                    break;
                end
            end
            if(flag == 0)
                newSource = Source(ITDiter,ITDtmp(ITDiter));
                newList = cell(1);
                newList{1,1} = newSource;
                source_list = [source_list, newList];
            end
        end
        %3.3统计归类后的声源
        sourceCount = zeros(1,length(source_list));
        sourceMean = zeros(1,length(source_list));
        for n = 1:length(source_list)
            sourceCount(1,n) = source_list{1,n}.getNum;
            sourceMean(1,n) = source_list{1,n}.getMean;
        end
        %3.4取数量最多的类的均值为统计值ITD
        [~,index] = max(sourceCount);
        sourceMean1 = sourceMean(index);
        %3.5与训练数据对比，确定声源位置
        [~,minIndex] = min(abs(sourceMean1*ones(1,length(mean_ITD))-mean_ITD));
        sourceITD(1,audioIter) = mean_ITD(minIndex);  
    end
end
sourceITD = unique(sourceITD);%去除重复声源
sourceNum = length(sourceITD);
sourceIndex = zeros(1,sourceNum);
for n = 1:sourceNum
    sourceIndex(n) = find(mean_ITD==sourceITD(n));
end
azimuthout = azimuth(sourceIndex);
%%
%4.声源分离 
% mask = zeros(length(sourceITD),frameAmount);
% for n = 1:frameAmount
%     [~,belong] = min(abs(ITD(n)*ones(1,length(sourceITD))-sourceITD));
%     mask(belong,n) = 1;
% end
%4.1计算每个频点的ITD
% freq=[(0:frameSize/2-1) (-frameSize/2:-1)]*(2*pi/(frameSize));
freq=(0:frameSize-1)*(2*pi/(frameSize));
fmat=freq(ones(size(tf_L,2),1),:)';
% R21=(tf_L+eps)./(tf_R+eps); 
% delta=-imag(log(R21))./fmat;
% delta(1,:) = zeros(1,size(delta,2)); %直流分量的相位差为0
% delta = onesample*delta; %转换成us
%4.2计算每个频点的掩码
% mask = 0.01*ones(frameSize,frameAmount,sourceNum);%最后一维代表声源编号
mask = zeros(frameSize,frameAmount,sourceNum);%最后一维代表声源编号
% mask1 = zeros(frameSize,frameAmount,sourceNum);
dis_mat = zeros(frameSize,frameAmount,sourceNum);
% dis_mat1 = zeros(frameSize,frameAmount,sourceNum);
% for n = 1:frameAmount
%     for i = 1:frameSize
%         [~,belong] = min(abs(delta(i,n)*ones(1,length(sourceITD))-sourceITD));
%         mask(i,n,belong) = 1;
%     end
% end
%将分离开的频点组合起来
tf_L = sum(tf_L,3);
tf_R = sum(tf_R,3);

% for n = 1:frameAmount
%     for i = 1:frameSize
%         distance = zeros(1,sourceNum);
%         for j = 1:sourceNum
% %             distance(1,j) = (abs(mean_IID(i,sourceIndex(j))*exp(-1j*2*pi/frameSize*i*sourceITD(j)/onesample)*tf_L(i,n)-tf_R(i,n)))^2....
% %             /(1+(mean_IID(i,sourceIndex(j)))^2);
% %             distance(1,j) = (abs(mean_IID(i,sourceIndex(j))*tf_L(i,n)-exp(-1j*2*pi/frameSize*i*sourceITD(j)/onesample)*tf_R(i,n)))^2....
% %             /(1+(mean_IID(i,sourceIndex(j)))^2);
%             distance(1,j) = (abs(mean_IID(i,sourceIndex(j))*tf_L(i,n)-exp(-1j*2*pi/frameSize*(i-1)*sourceITD(j)/onesample)*tf_R(i,n)))^2....
%             /(1+(mean_IID(i,sourceIndex(j)))^2);
% %             dis_mat1(i,n,j)=distance(1,j);
%         end
%         [~,belong] = min(distance);
%         mask(i,n,belong) = 1;
%     end 
% end
%将各个声源数据代入计算两声道对应频点之间的距离
for sourceIter = 1:sourceNum
%     try
%         IID_mat = repmat(mean_IID(:,sourceIndex(sourceIter)),1,frameAmount);
%     catch
%         save error.mat;
%         error('exit');
%     end
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

