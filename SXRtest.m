clc;clear;close all;
orignal = [];
separated = [];
var = [];
for SNR = 20
    for deg = 60
        sepPath = sprintf('E:\\MatlabCode\\PESQ\\pesq\\pesq\\Debug\\SMAD\\origin\\female_%d_R.wav',deg);
        origPath = sprintf('E:\\MatlabCode\\PESQ\\pesq\\pesq\\Debug\\SMAD\\output\\out_female_male_0_%d_white_20.wav',deg);
        [ySep,fs1] = audioread(sepPath);
        [yOri,fs2] = audioread(origPath);
        ySep = ySep(1:442000);
        yOri = yOri(1:442000);
        separated = [separated; ySep'];
        orignal = [orignal; yOri'];
        var = [var; [SNR, deg]];
    end
end

[SDRduet,SIRduet,SARduet,permduet]=bss_eval_sources(orignal,separated);