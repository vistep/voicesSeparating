tf_L_tmp=[];
tf_R_tmp=[];
for i = 1:size(f_index,2)
    if(f_index(1,i))
        tf_L_tmp=[tf_L_tmp,tf_L(:,i,2)];
        tf_R_tmp=[tf_R_tmp,tf_R(:,i,2)];
    end
end
        