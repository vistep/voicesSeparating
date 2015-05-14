close all;
figure()
plot(abs(tf_L(:,1000,1)))
hold on
plot(abs(tf_R(:,1000,1)),'r')
hold off
title('1st source')

figure()
plot(abs(tf_L(:,1000,2)))
hold on
plot(abs(tf_R(:,1000,2)),'r')
hold off
title('2nd source')