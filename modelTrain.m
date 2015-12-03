clc;clear all;close all;
%%
%feature extract
deg = 0:10:90;
train_x = [];
train_y = [];
test_x = [];
test_y = [];
for i = 1:length(deg)
    inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\有混响\\TestData\\female_%02d_white_0_Rev_600.wav',deg(i));
%     inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\噪声无混响\\TestData\\female_%02d_white_20.wav',deg(i));
%     if deg(i)==0
%         inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\噪声无混响\\TestData\\female_%01d_white_20.wav',deg(i));
%     end
    load('./VADdata/female_0_white_0_Rev_600_512_index.mat');
    [IID, correlation] = featureExtract(inPutFilePath,vad1);
    correlation = bsxfun(@plus, correlation, 1);
    correlation = bsxfun(@rdivide, correlation, 2);
    tmp_x = [IID, correlation];
    tmp_y = zeros(size(tmp_x,1), length(deg));
    tmp_y(:, i) = 1;
    train_x = [train_x; tmp_x(1:round(9*size(tmp_x,1)/10),:)];
    train_y = [train_y; tmp_y(1:round(9*size(tmp_x,1)/10),:)];
    test_x = [test_x; tmp_x(round(9*size(tmp_x,1)/10)+1:end,:)];
    test_y = [test_y; tmp_y(round(9*size(tmp_x,1)/10)+1:end,:)];
end
for i = 1:length(deg)
    inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\有混响\\TestData\\male_%02d_white_0_Rev_600.wav',deg(i));
%     inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\噪声无混响\\TestData\\male_%02d_white_20.wav',deg(i));
%     if deg(i)==0
%         inPutFilePath = sprintf('E:\\Document\\科研相关\\语音库\\噪声无混响\\TestData\\male_%01d_white_20.wav',deg(i));
%     end
    load('./VADdata/male_0_white_0_Rev_600_512_index.mat');
    [IID, correlation] = featureExtract(inPutFilePath,vad1);
    correlation = bsxfun(@plus, correlation, 1);
    correlation = bsxfun(@rdivide, correlation, 2);
    tmp_x = [IID, correlation];
    tmp_y = zeros(size(tmp_x,1), length(deg));
    tmp_y(:, i) = 1;
    train_x = [train_x; tmp_x(1:round(9*size(tmp_x,1)/10),:)];
    train_y = [train_y; tmp_y(1:round(9*size(tmp_x,1)/10),:)];
    test_x = [test_x; tmp_x(round(9*size(tmp_x,1)/10)+1:end,:)];
    test_y = [test_y; tmp_y(round(9*size(tmp_x,1)/10)+1:end,:)];
end
%%
%model train
rand('state',0)
%train dbn
dbn.sizes = [100 100];
opts.numepochs =  10;
opts.batchsize = 128;
opts.momentum  =   0.5;
opts.alpha     =   0.1;
dbn = dbnsetup(dbn, train_x, opts);
dbn = dbntrain(dbn, train_x, opts);
%unfold dbn to nn
nn = dbnunfoldtonn(dbn, length(deg));
nn.output = 'softmax';
%train nn
opts.numepochs =  50;
opts.batchsize = 128;
opts.validation = 1;
nn.learningRate = 0.1;
nn.dropoutFraction = 0.5;
opts.momentum  =   0.9;
nn = nntrain(nn, train_x, train_y, opts);
nn.learningRate = 0.01;
opts.momentum  =   0.9;
nn = nntrain(nn, train_x, train_y, opts);
[er, bad] = nntest(nn, test_x, test_y);
[er2, bad] = nntest2(nn, test_x, test_y);


