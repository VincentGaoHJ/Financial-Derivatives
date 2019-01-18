clc;
clear; 


X=50; 
Shead=0; 
Stail=100; 
schange = 0.1 r=0.05; 
sig=0.4; 
T=12/12; 
dt=0.1/12 


%Svec - 股价取值的向量 
%tvec - 时间节点的向量 
Svec=Stail:-schange:Shead; 
tvec=0:dt:T;  


% 计算价值矩阵的长和宽 M = length(Svec)-1; 
N = length(tvec)-1;  


% 根据公式计算公式的参数设置 j = 0:M; 
sig2 = sig*sig; 

aj = (dt*j/2).*(r - sig2*j) 
bj = 1 + dt*(sig2*(j.^2) + r); 
cj = -(dt*j/2).*(r + sig2*j);  


% 初始化矩阵 price=zeros(M+1,N+1);  
% 建立三对角矩阵以联立方程组，也就是矩阵求解 
B = diag(aj(3:M),-1) + diag(bj(2:M)) + diag(cj(2:M-1),1); 


% 输入边界条件 % 输入到期日时候的边界条件 
A = linspace(1,1,length(price(:,end))) 

for i=1:length(A)
    if Svec(i) < 40 
        A(i) = 2; 
    elseif 
    	Svec(i) >= 40 && Svec(i) <= 60         
    	A(i) = min(max(Svec(i)-X,0),2); 
   	else         
   		A(i) = 5;     
   	end 
end 


price(:,end) = A;  


% 输入最大值和最小值时候的边界条件P 
price(1,:) = 5*exp(-r*tvec(end:-1:1)); 
price(end,:) = 2*exp(-r*tvec(end:-1:1)); 
price Boundary=zeros(size(B,1),N); 
Boundary(1,:)= aj(2)*5*exp(-r*tvec(end-1:-1:1)); 
Boundary(end,:)= cj(M)*2*exp(-r*tvec(end-1:-1:1)); 


Boundary  


% 利用矩阵循环求解方程组 
for idx = N:-1:1     
	price(2:end-1,idx+1);     
	Boundary(:,idx);
	price(2:end-1,idx)=B\(price(2:end-1,idx+1)-Boundary(:,idx));  
end 


price  


%计算Delta 
delta = linspace(1,1,M); 
for idx = 1:1:M     
	delta(idx) = (price(idx+1,1) - price(idx,1))/schange; 
end 


value = interp1(Svec,price(:,1),50) 


plot(delta(end:-1:1)); 
plot(price(end:-1:1,1));