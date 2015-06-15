% tf_L_tmp=[];
% tf_R_tmp=[];
% for i = 1:size(tmp_index,2)
%     if(tmp_index(1,i))
%         tf_L_tmp=[tf_L_tmp,tf_L(:,i,2)];
%         tf_R_tmp=[tf_R_tmp,tf_R(:,i,2)];
%     end
% end
%         
load('./trainData/ITD_GCC_16k.mat');
load('./trainData/IID_GCC_16k.mat');
load('framExtact.mat')

fs = 16000;
sourceNum=2;
onesample = 1000000/fs;
frameSize=size(mean144R,1);
frameAmount=size(mean144L,2);
dis_mat = zeros(frameSize,frameAmount,sourceNum);
sourceIndex=[21,34];
IID_mat = repmat(mean_IID(:,22),1,frameAmount);
tf_L=mean144L;
tf_R=mean144R;
sourceITD=mean_ITD(sourceIndex);
freq=(0:frameSize-1)*(2*pi/(frameSize));
fmat=freq(ones(size(tf_L,2),1),:)';


for sourceIter = 1:sourceNum
    IID_mat = repmat(mean_IID(:,sourceIndex(sourceIter)),1,frameAmount);
    dis_mat(:,:,sourceIter) = ((abs(IID_mat.*tf_L-exp(-1j*sourceITD(sourceIter)/onesample.*fmat).*tf_R)).^2)./(ones(frameSize,frameAmount)+IID_mat.^2);
end
