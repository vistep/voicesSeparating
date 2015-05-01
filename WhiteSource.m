% 利用MIT的HRTR数据和白噪声信号生成具有方向性的噪声信号，0-180度，正前方到正后方

%读入的白噪声信号
inPutFilePath = 'F:\科研\研究方向\2009年声源定位\仿真\data\Speech\white.wav';
[inPutData fs] = wavread(inPutFilePath);

for azimuth = 0:5:180
    %读入MIT Compact HRTF数据，0～180度
    inPutFilePath = sprintf('F:\\科研\\研究方向\\2009年声源定位\\仿真\\data\\MITHRIR\\elev0\\H0e%03da.dat',azimuth);
    hrir = readraw(inPutFilePath);
    hrir_L = hrir(:,1);
    hrir_R = hrir(:,2);
    x_L = conv(inPutData,hrir_L);
    x_R = conv(inPutData,hrir_R);
    
    %语音信号的范围[-1  1]
    MaxValue = max(max(abs(x_L)),max(abs(x_R)));
    MaxValue = MaxValue + MaxValue/1000;
    x_L = x_L/MaxValue;
    x_R = x_R/MaxValue;

    y = [x_L,x_R];
    %方向性的噪声信号
    outPutFilePath = sprintf('F:\\科研\\研究方向\\2009年声源定位\\仿真\\data\\Speech\\方位白噪声\\WhiteNoise%03d.wav',azimuth);
    wavwrite(y,fs,outPutFilePath);
end