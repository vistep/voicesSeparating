%说明：检验过，准确性挺好
function pitch=singlepitch8kHz(x)
%figure;
%x=s1frame(2,:);
N=length(x);
for m=1:N
    R(m)=sum(x(1:end-m+1).*x(m:end));%求自相关函数
end
[k,v]=findpeaks(R,'q');
[amplitude,num]=max(v);
if R(1)==0
    pitch=0;
elseif length(k)==0
    pitch=0;
elseif amplitude/R(1)<0.28
    pitch=0;
elseif round(k(num))<18||round(k(num))>143                              %基音周期位于[60Hz,500Hz],对于8kHZ采样，基音周期对应的样点数约为[18,143]
        pitch=0;
else
        pitch=round(k(num));
end
end

    