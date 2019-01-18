clear all

%%求收益率的方差和均值
%获取收益率
yield = xlsread('SData2.xls','IDXQTTN','Y2:Y245');
avg_yield_day = mean(yield);
std_yield_day = std(yield);

%%生成随机价格曲线，进行模拟
PortValue = 100000000;
TradeDayofYear = 252;
TradeDayTimeLong = 252;
RisklessReturn = 0.03;
TradeFee = 0.0002;
Riskmulti = [2 2.5 3 3.5 4];
GuarantRatio = [0.95 1];
adjustCycle = [1 5 10 20];
ParamsMatrix = zeros(length(Riskmulti)*length(GuarantRatio)*length(adjustCycle),6);
num = 0;
for x = 1:length(GuarantRatio)
    for y = 1:length(Riskmulti)
        for z = 1:length(adjustCycle)
            num = num + 1;
            ParamsMatrix(num,1:3) = [GuarantRatio(x),Riskmulti(y),adjustCycle(z)];
        end
    end
end

%模拟1000次
testnum = 1000;
mean = avg_yield_day;
std = std_yield_day;
index0 = 3144.76;
indexmatrix = zeros(testnum,TradeDayTimeLong+1);
for i = 1:testnum
    sdata = RandnPrice(index0,mean,std,TradeDayTimeLong);
    sdatamatrix(i,:) = [index0;sdata];
end

SumTradeFee = zeros(testnum,1);
portvalue_new = zeros(testnum,1);
testreturn = zeros(testnum,1);
portFreez = zeros(testnum,1);
%testvolatility = zeros(testnum,1);
for testno = 1:length(ParamsMatrix)
    for k = 1:testnum
        TRiskmulti = ParamsMatrix(testno,2);
        TGuarantRatio = ParamsMatrix(testno,1);
        TadjustCycle = ParamsMatrix(testno,3);
        [F,E,A,G,SumTradeFee(k),portFreez(k)] = CPPI_hjn(PortValue,TRiskmulti,TGuarantRatio,TradeDayTimeLong,TradeDayofYear,TadjustCycle,RisklessReturn,TradeFee,sdatamatrix(k,:));
        testreturn(k) = (A(TradeDayTimeLong + 1) - A(1))/A(1);
        portvalue_new(k) = A(TradeDayTimeLong + 1);
    end
    ParamsMatrix(testno,4) = sum(testreturn)/testnum;
    ParamsMatrix(testno,5) = sum(SumTradeFee)/testnum;
    ParamsMatrix(testno,6) = sum(portvalue_new)/testnum;
end
format long;
ParamsMatrix
[max_v,index] = max(ParamsMatrix)

% figure;
% subplot(2,1,1)
% plot(sdatamatrix(666,:))
% xlabel('t');
% ylabel('price')
% legend('HS300-simulation')
% subplot(2,1,2)
% plot(A,'-.')
% hold on
% plot(E,'-x')
% plot(F,'-k')
% plot(G,'--')
% legend('PortValue','RiskAsset','GuarantRatio','RisklessAsset')
% xlabel('t');
% ylabel('price')







