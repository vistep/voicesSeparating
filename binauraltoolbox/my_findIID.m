function IID = my_findIID(left_ear, right_ear)
%

[channel_num, data_size] = size(left_ear);
for(i_chan=1:1:channel_num)
    tmp_li = sum(left_ear(i_chan,:).*left_ear(i_chan,:));
    tmp_ri = sum(right_ear(i_chan,:).*right_ear(i_chan,:));
    
    IID(i_chan) = 20*log10(tmp_li/tmp_ri);
end
