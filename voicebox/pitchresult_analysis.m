function [s1pitchest1,s2pitchest1]=pitchresult_analysis(ii,framenum,s1pitchest0,s2pitchest0)
for ii=2:framenum
      s1pitchchange(ii)=abs(s1pitchest0(ii)-s1pitchest0(ii-1));
      s1pitchchangebc1(ii)=abs(s1pitchest0(ii)-2*s1pitchest0(ii-1));
      s1pitchchangebc2(ii)=abs(s1pitchest0(ii)-0.5*s1pitchest0(ii-1));
      s2pitchchange(ii)=abs(s2pitchest0(ii)-s2pitchest0(ii-1));
      s2pitchchangebc1(ii)=abs(s2pitchest0(ii)-2*s2pitchest0(ii-1));
      s2pitchchangebc2(ii)=abs(s2pitchest0(ii)-0.5*s2pitchest0(ii-1));
end
s1pitchest1=[];s2pitchest1=[];s1pitchest1(1)=0;s2pitchest1(1)=0;
for ii=2:framenum
    if s1pitchchange(ii)<=4||s1pitchchangebc1(ii)<=4||s1pitchchangebc2(ii)<=4  
       s1pitchest1(ii)=s1pitchest0(ii);
       s1pitchest1(ii-1)=s1pitchest0(ii-1);
    else
        s1pitchest1(ii)=0;
    end
    if s2pitchchange(ii)<=4||s2pitchchangebc1(ii)<=4||s2pitchchangebc2(ii)<=4
       s2pitchest1(ii)=s2pitchest0(ii);
       s2pitchest1(ii-1)=s2pitchest0(ii-1);
    else
        s2pitchest1(ii)=0;
    end
end
for ii=2:framenum-1
    if  s1pitchest1(ii)==0&&s1pitchest1(ii-1)~=0&&s1pitchest1(ii+1)~=0
        s1pitchest1(ii)=s1pitchest1(ii-1);
    end
    if  s2pitchest1(ii)==0&&s2pitchest1(ii-1)~=0&&s2pitchest1(ii+1)~=0
        s2pitchest1(ii)=s2pitchest1(ii-1);
    end
    if s1pitchest1(ii)~=0&&s1pitchchange(ii)>4&&(abs(s1pitchest1(ii+1)-s1pitchest1(ii-1))<=4||abs(s1pitchest1(ii+1)-2*s1pitchest1(ii-1))<=4||abs(s1pitchest1(ii+1)-0.5*s1pitchest1(ii-1))<=4)
       s1pitchest1(ii)=s1pitchest1(ii-1);
    end
    if s2pitchest1(ii)~=0&&s2pitchchange(ii)>4&&(abs(s2pitchest1(ii+1)-s2pitchest1(ii-1))<=4||abs(s2pitchest1(ii+1)-2*s2pitchest1(ii-1))<=4||abs(s2pitchest1(ii+1)-0.5*s2pitchest1(ii-1))<=4)
       s2pitchest1(ii)=s2pitchest1(ii-1);
    end
end
for ii=2:framenum-1
    if abs(s1pitchest1(ii-1)-s1pitchest1(ii+1))<=1&&abs(s1pitchest1(ii-1)-s1pitchest1(ii))>1
        s1pitchest1(ii)=s1pitchest1(ii-1);
    end
    if abs(s2pitchest1(ii-1)-s2pitchest1(ii+1))<=1&&abs(s2pitchest1(ii-1)-s2pitchest1(ii))>1
        s2pitchest1(ii)=s2pitchest1(ii-1);
    end
end
