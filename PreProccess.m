
function postProcData = PreProccess(preProcData, FrameSize, FrameShift)

%
% postProcData: outputData. martrix, FrameZize*frameAmount
% newFrameAmount: output parameter. Maybe the size of voiceData will be change in preproccess.
% preProcData:  inputData. vector, voiceDataCnt*1
% FrameZize:    input parameter.
% FrameShift:   input parameter.

voiceDataCnt = size(preProcData,1);
frameAmount = floor(voiceDataCnt / (FrameSize-FrameShift) ) - 1; % consider frameShift, and give up the last frame

% step 1: preEmphasize
% b = [0.92727435, -1.8544941, 0.92727435];
% a = [1.0000000, -1.9059465, 0.91140240];
% a = [1,          - 1.9059465,   0.9114024];
% b = [0.46363718, - 0.92724705,  0.46363718];
% a = [1, 0.98];
% b = 1;
% postEmpData = filter(b, a, preProcData(:)); % function "filter" must use a vector

% step 2: enFrame, martrix, FrameZize*frameAmount
inc = FrameSize - FrameShift;
indExFrame = inc .* (0:(frameAmount-1)); 
indInFrame = (1:FrameSize)';
framedData = zeros(FrameSize,frameAmount);
framedData(:) = preProcData(indExFrame(ones(FrameSize,1),:)+indInFrame(:,ones(1,frameAmount)));

% step 3: enWindow
hammingWindow = hamming(FrameSize);
postProcData = framedData .* hammingWindow(:,ones(1,frameAmount));
