clc;
clear;
X=8;
S0=10;
r=0.1;
sig=0.5;
T=1;
%Svec - Vector of stock prices (i.e. grid points)
%tvec - Vector of times (i.e. grid points)
oType='PUT';
Svec=0:0.1:S0+10;
tvec=0:0.01:T;

% Get the number of grid points
M = length(Svec)-1;
N = length(tvec)-1;
% Get the grid sizes (assuming equi-spaced points)
dt = tvec(2)-tvec(1);

% Calculate the coefficients
% To do this we need a vector of j points
j = 0:M;
sig2 = sig*sig;
aj = (dt*j/2).*(r - sig2*j);
bj = 1 + dt*(sig2*(j.^2) + r);
cj = -(dt*j/2).*(r + sig2*j);

% Pre-allocate the output
price=zeros(M+1,N+1);

% Form the tridiagonal matrix
B = diag(aj(3:M),-1) + diag(bj(2:M)) + diag(cj(2:M-1),1);


% Specify the boundary conditions
switch oType
    case 'CALL'
        % Specify the expiry time boundary condition
        price(:,end) = max(Svec-X,0);
        % Put in the minimum and maximum price boundary conditions
        % assuming that the largest value in the Svec is
        % chosen so that the following is true for all time
        price(1,:) = 0;
        price(end,:) = (Svec(end)-X)*exp(-r*tvec(end:-1:1));
        Boundary=zeros(size(B,1),N);
        Boundary(1,:)= 0;
        Boundary(end,:)= cj(M)*(Svec(end)-X)*exp(-r*tvec(end-1:-1:1));
    case 'PUT'
        % Specify the expiry time boundary condition
        price(:,end) = max(X-Svec,0);
        % Put in the minimum and maximum price boundary conditions
        % assuming that the largest value in the Svec is
        % chosen so that the following is true for all time
        price(1,:) = (X-Svec(1))*exp(-r*tvec(end:-1:1));
        price(end,:) = 0;
        Boundary=zeros(size(B,1),N);
        Boundary(1,:)= aj(2)*(X-Svec(1))*exp(-r*tvec(end-1:-1:1));
        Boundary(end,:)= 0;
end

% Solve at each node
for idx = N:-1:1
    price(2:end-1,idx)=B\(price(2:end-1,idx+1)-Boundary(:,idx));

end

plot(price(:,1));


