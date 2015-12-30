clc;clear all;close all;
%%
%feature extract
deg = [270:10:350,0:10:90];
% deg = 0:10:90;
train_x = [];
train_y = [];
test_x = [];
test_y = [];
for i = 1:length(deg)
    inPutFilePath = sprintf(['E:\\Document\\科研相关\\语音库\\180度声源\\female1_' num2str(deg(i)) '_white_20_Rev_600.wav']);
    [IID, correlation] = featureExtract2(inPutFilePath);
    correlation = bsxfun(@plus, correlation, 1);
    correlation = bsxfun(@rdivide, correlation, 2);
    tmp_x = [IID, correlation];
%     tmp_x = correlation;
    tmp_y = zeros(size(tmp_x,1), length(deg));
    tmp_y(:, i) = 1;
    train_x = [train_x; tmp_x(1:round(9*size(tmp_x,1)/10),:)];
    train_y = [train_y; tmp_y(1:round(9*size(tmp_x,1)/10),:)];
    test_x = [test_x; tmp_x(round(9*size(tmp_x,1)/10)+1:end,:)];
    test_y = [test_y; tmp_y(round(9*size(tmp_x,1)/10)+1:end,:)];
end
for i = 1:length(deg)
    inPutFilePath = sprintf(['E:\\Document\\科研相关\\语音库\\180度声源\\male1_' num2str(deg(i)) '_white_20_Rev_600.wav']);
    [IID, correlation] = featureExtract2(inPutFilePath);
    correlation = bsxfun(@plus, correlation, 1);
    correlation = bsxfun(@rdivide, correlation, 2);
    tmp_x = [IID, correlation];
%     tmp_x = correlation;
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


