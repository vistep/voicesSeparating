clc;clear;close all;
fs = 16000;

deg = [10,320,60,280;
    20,300,50,270;
    20,280,70,310;
    40,290,10,330;
    70,340,30,280];
Rev = '';
degEst=cell(3,size(deg,1));
for times = 1:3
    for i = 1:size(deg,1)
        inPutFilePath = sprintf('./mixedvoice/4sources/%d_%d_%d_%d_white_0%s.wav',deg(i,1),deg(i,2)-360,deg(i,3),deg(i,4)-360,Rev);
        dnnModel = sprintf('./model/20dB.mat');
        [output,ami] = sepIter(inPutFilePath,times,4,dnnModel,0.1);
        degEst{times,i}=ami;
        str1 = strsplit(inPutFilePath,'/');
%         audiowrite(sprintf(['./output/outFemale1_' str1{end}]),output{1},fs);
%         audiowrite(sprintf(['./output/outFemale2_' str1{end}]),output{2},fs);
%         audiowrite(sprintf(['./output/outMale2_' str1{end}]),output{3},fs);
    end
end
tmp = degEst';
