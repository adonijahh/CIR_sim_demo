clear all
clf
                                      
avgPathGainsDb=[0 -3.6 -7.2 -10.8 -18 -25.2];  %dB每一个path的相对power
pathDelays = [0 1 1.9 3 5.3 7]*1e-6;     % second  delta_tao=1 us，有6个path进来，单位微秒
avgPathGains= 10.^(avgPathGainsDb/10);

TapDelays =(0:1:7)*10^(-6)                  %second 每一微秒一个采样
TapGains = interp1(pathDelays, avgPathGains, TapDelays,'linear')
TapGainsDb = 10*log10(TapGains);         
 
fs = 1000;           % Hz   delta_t=1/fs ， sampling rate=1000Hz，对应1ms采一个样，间隔1ms
fDoppler =100;        %  Hz
numSamples=10000; % 10000个采样点，10000*0.1 ms=1 s
h=zeros(numSamples,length(TapGains));

totPowerG=sum(avgPathGains)  %  求第四行的所有的path的gain加起来
avgDelay=sum(pathDelays.*avgPathGains)/totPowerG*10^6  %在iPad lecture3 P29第一个公式；单位是微秒，因为是乘以10的6次方
sqrDelay=sum(pathDelays.^2.*avgPathGains)/totPowerG*10^12  %在iPad lecture3 P29第二个公式 加权均值，用每一个path的power加权；单位是皮秒，微秒的平方，因为是乘以10的12次方
rmsDelaySpread=sqrt(sqrDelay-avgDelay^2)    %标准差 在iPad lecture3 P29第三个公式；
 
rchan = comm.RayleighChannel('SampleRate',fs, ...
    'PathDelays',TapDelays, ...
    'AveragePathGains',TapGainsDb, ...
    'MaximumDopplerShift',fDoppler, ...
    'NormalizePathGains', false,...%为true时，是分开的。为false时，重合的：第10行和第34行
    'PathGainsOutputPort',true,...
    'Visualization','off');

data=randi([0 1],numSamples,1); %对应14行
[chanout1,h]=rchan(data); % h(t,tao) is the complex  path gain 

PowerDelayProfile=mean(abs(h).^2);   % verified 在iPad lecture3 P28第三个公式，跟TapGainsDb非常靠近或者一样，用来验证。
% plot(0:1:7,10*log10(PowerDelayProfile))  %第10行和第34行应该是一个结果
% hold on
% plot(0:1:7,TapGainsDb) %为什么0:1:7，为了横轴从0到7

FrequencyCoherentFunction=fft(PowerDelayProfile); %傅里叶变换
FrequencyCoherentFunction=fftshift(FrequencyCoherentFunction); %把傅里叶变换结果放到中间去了
Cof=abs(FrequencyCoherentFunction)/max(abs(FrequencyCoherentFunction));% normalised autocorrelation factor；相关系数

plot(-4*10^6/7:10^6/7:3*10^6/7,Cof, 'k*-') %
%  
grid minor


%最后生成的图像你要加横轴纵轴标题名  
%comment是关掉plot34-36行