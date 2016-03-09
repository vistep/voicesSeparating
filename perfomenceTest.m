clc;clear;close all;
L = 473000;
for SNR = 20
    for deg = 10:10:90
        sepPath = sprintf('./output/修正性别/outMale_female_male_%02d.wav',deg);
        origPath = sprintf('E:\\Document\\科研相关\\语音库\\180度声源\\female2.wav');
        [y1,fs1] = audioread(sepPath);
        [y2,fs2] = audioread(origPath);
        if (fs2==44100)
            y2 = resample(y2,fs1,fs2);
        end
        s1 = strsplit(sepPath,'/');
        s2 = strsplit(origPath,'\\');
        p1 = strcat('./output/分离语音/', s1(end));
        p2 = strcat('./output/原语音/', s2(end));
        %         audiowrite(p1{1}, y1(1:L), fs1);
%         audiowrite(p2{1}, y2(1:L,2), fs2);
        audiowrite(p2{1}, y2, fs1);
    end
end

