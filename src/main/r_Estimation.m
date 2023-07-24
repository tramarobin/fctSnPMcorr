function Err=r_Estimation(t,r,n)

Err=abs(r*sqrt((n-2)/(1-r^2))-t);

end