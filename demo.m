clear;
clc;
close all;
%% Load file
load TDL_h2.mat
f_s = 1/0.1e-3;      % Sampling rate    
f_tau = 1/300e-9;   % 
t_t = linspace(0,10,size(h,1));
t_tau = 300e-6:300e-6:size(h,2)*300e-6;
freq = linspace(-f_s/2,f_s/2,length(t_t));
freq_tau = linspace(-f_tau/2,f_tau/2,size(h,2));
%% Data scan
close all;
figposi = [300 50 700 400];
figure('Name','Data Scan','Position',figposi,'PaperPositionMode','auto');
plot(freq,abs(fftshift(fft(sum(h,2)))),'k-');hold on; 
xlabel('Frequency/Hz');
ylabel('Power');
set(gca,'FontSize',12,'FontName','Times New Roman');
grid minor;
print('Datascan.jpg','-djpeg','-r600');
%% Q1 The power delay profile of this channel
PowerDelayProfile=mean(abs(h).^2,1);  % The power delay profile of this channel
close all;
figposi = [300 50 700 400];
figure('Name','Q1','Position',figposi,'PaperPositionMode','auto');
plot(t_tau/1e-6,PowerDelayProfile,'k-o');
xlabel('Time/us');
ylabel('Power');
set(gca,'FontSize',12,'FontName','Times New Roman');
grid minor;
print('Q1.jpg','-djpeg','-r600');
%% Q2 RMS delay spread of the channel
avgPathGains = sum(abs(h).^2,1)/size(h,1);
totPowerG=sum(avgPathGains);  %  求第四行的所有的path的gain加起来
pathDelays = (1/f_tau:1/f_tau:9/f_tau).*PowerDelayProfile;
avgDelay=sum(pathDelays.*avgPathGains)/totPowerG*1e6;  %在iPad lecture3 P29第一个公式；单位是微秒，因为是乘以10的6次方
sqrDelay=sum(pathDelays.^2.*avgPathGains)/totPowerG*1e12;  %在iPad lecture3 P29第二个公式 加权均值，用每一个path的power加权；单位是皮秒，微秒的平方，因为是乘以10的12次方
rmsDelaySpread=sqrt(sqrDelay-avgDelay^2);    %标准差 在iPad lecture3 P29第三个公式；
%% Q3 The frequency coherence function of the channel
FrequencyCoherentFunction=fftshift(fft(PowerDelayProfile));
close all;
figposi = [300 50 700 400];
figure('Name','Q1','Position',figposi,'PaperPositionMode','auto');
plot(freq_tau,FrequencyCoherentFunction,'k-o');
xlabel('Frequency/Hz');
ylabel('Power');
set(gca,'FontSize',12,'FontName','Times New Roman');
grid minor;
print('Q3.jpg','-djpeg','-r600');
%% Q4 Compare the coherent bandwidth estimated using either the frequency coherence function or the RMS delay spread
% coherent bandwidth of the frequency coherence function
% 找到频率相干函数的峰值和对应的位置
[max_value, max_index] = max(FrequencyCoherentFunction);
% 找到频率相干函数下降到峰值一半的位置
half_max_value = max_value / 2;
left_half_index = find(FrequencyCoherentFunction(1:max_index) < half_max_value, 1, 'last');
right_half_index = find(FrequencyCoherentFunction(max_index:end) < half_max_value, 1) + max_index - 1;
% 计算相干带宽
Bc_fcf = 1/(abs(right_half_index - left_half_index));
% coherent bandwidth of the RMS delay spread
Bc_RMS = 1/(5*rmsDelaySpread);
%% Q5 The time coherence function of the channel 
% 计算时间相干函数
autocorrelation_function = PowerDelayProfile.*conj(PowerDelayProfile); % 计算自相关函数
% 归一化自相关函数
autocorrelation_function = autocorrelation_function / max(autocorrelation_function);
close all;
figposi = [300 50 700 400];
figure('Name','Q5','Position',figposi,'PaperPositionMode','auto');
plot(t_tau/1e-6,autocorrelation_function,'k-o');
xlabel('Time/us');
ylabel('Power');
set(gca,'FontSize',12,'FontName','Times New Roman');
grid minor;
print('Q5.jpg','-djpeg','-r600');
%% Q6 The Doppler spectrum of the channel
doppler_spectrum = abs(fftshift(fft(sum(h,2))));
doppler_spectrum_tcf = abs(fftshift(fft(autocorrelation_function)));
[max_value, max_index] = max(doppler_spectrum);
half_max_value = max_value / 2;
left_half_index = find(doppler_spectrum(1:max_index) > half_max_value, 1, 'first');
right_half_index = find(doppler_spectrum(max_index:end) > half_max_value, 1, 'last') + max_index - 1;
doppler_freq_spread = abs(freq(right_half_index)-freq(left_half_index));
close all;
figposi = [300 50 700 400];
figure('Name','Q6','Position',figposi,'PaperPositionMode','auto');
plot(freq_tau,doppler_spectrum_tcf,'k-o');
xlabel('Time/us');
ylabel('Power');
set(gca,'FontSize',12,'FontName','Times New Roman');
grid minor;
print('Q6.jpg','-djpeg','-r600');
%% Q7 Compare coherent time estimated using either the time coherence function or the Doppler frequency 
Tc_doppler_freq = 9/(16*pi*doppler_freq_spread);
Tc_time_coherence_func = (sum((1/f_tau:1/f_tau:9/f_tau).*doppler_spectrum_tcf));
%% Q8 The speed of the mobile terminal, assuming the carrier frequency is 3GHz/30GHz respectively
c = 3e8;
v_user_3G = doppler_freq_spread/3e9*c;
v_user_30G = doppler_freq_spread/30e9*c;