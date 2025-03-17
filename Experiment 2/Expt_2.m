%%%% Program to find Channel Frequency Response (CFR) of the 
%populated subcarriers of HE-LTF field 
 clc;close all;clear all;
% Create the HT packet configuration and transmit waveform.
cfgSU = wlanHESUConfig; %wlanHESUConfig creates a single user (SU) high efficiency (HE)format configuration object. This object contains the transmit
    %parameters for the HE-SU format of IEEE P802.11ax/D3.1 standard.
cfgSU.ChannelBandwidth='CBW20';
cfgSU.APEPLength=100;% Data field carry PSDU's. Specify PSDU length

chanBW = cfgSU.ChannelBandwidth;%default 20MHz channel
psdu = randi([0 1], getPSDULength(cfgSU)*8, 1); % Create a PSDU, getPSDULength(cfgSU)=100 bytes
txWaveform = wlanWaveformGenerator(psdu,cfgSU); % Ns x Nt
Tx_power=mean(txWaveform.*conj(txWaveform))  % 1.0038W
ind=wlanFieldIndices(cfgSU);
HELTF_transmitted = txWaveform((ind.HELTF(1):ind.HELTF(2)), :);

%% 
% Configure a TGax channel with 20 MHz bandwidth.
tgax = wlanTGaxChannel('ChannelBandwidth','CBW20');
tgax.TransmitReceiveDistance=12;% in meters, breakpoint distance that obeys freespace pathloss model for Model B is 5m
tgax.LargeScaleFadingEffect = 'PathLoss';    
tgax.SampleRate = 100e6;
tgax.PathGainsOutputPort = true;
tgax.DelayProfile='Model-D';

info_tgax=info(tgax)
PL_updated_dB=info(tgax).Pathloss

% Pass the impulse input through the TGax channel 
input = zeros(100,1); input(1) = 1;
impr1 = tgax(input);
impr1=impr1.';

 % Pass through a fading indoor TGax channel
[tgax_output,pathgains] = tgax(txWaveform);
info_tgax = info(tgax);
% The PathDelays provides the delay in secods of each path (non-zero)
nonZeroTapIdx = round(info_tgax.PathDelays*tgax.SampleRate)+1;
Nh = size(info_tgax.ChannelFilterCoefficients,2);
impr = zeros(Nh,1);
impr(nonZeroTapIdx) = pathgains(1,:);

figure(1);
plot(abs(impr),'x');grid on;
hold on; 
plot(abs(impr1),'o');
legend('CIR from pathgains','CIR from impulse input');
xlabel('Samples')
ylabel('|Channel impulse response|')

figure(2)
time = (1/tgax.SampleRate)*(0:length(impr)-1);
stem(time,abs(impr));grid on
xlabel('Time (sec)');
ylabel('|Amplitude|');
title('Channel Impulse Response Model D')

Xk=wlanHEDemodulate(HELTF_transmitted,'HE-LTF',chanBW,cfgSU.GuardInterval,cfgSU.HELTFType);
HELTF_Tx_power=mean(Xk.*conj(Xk)) ; % 1W
% disp('HE-LTF transmit symbol is')
%  disp(real(Xk))


[CFR,pg]=Expt_2_HELTF_func_avg_est_Hf(cfgSU,Xk,tgax,txWaveform);

% To sketch 5 realizations and average of 5000 realizations
kk=1:242;
figure(3)
plot(kk,(CFR(:,90)));grid on;
title("Channel Frequency Response Model D")
xlabel('subcarrier index (242 subcarriers)');
ylabel('|H_i|');

figure(4)
plot(kk,(mean(pg,2)),'k--');grid on;% Find the mean column-wise
hold on;
plot(kk,(pg(:,10)));hold on;%Plot  for every subcarrier
plot(kk,(pg(:,40)));hold on;
plot(kk,(pg(:,90)));hold on;
title("Plot for 3 channel realizations "+newline+"and average of 5000 channel realizations "+newline+" for TGax 20MHz channel Model D")
xlabel('subcarrier index (242 subcarriers)');
ylabel('|H_i|^2');
legend('Average')


 row_vec1=CFR(72,:);%each row is the ensemble of sampled random variable 
  %correspondng to a subcarrier index, k, here k=72 ie |H72|
figure(5)   
AA3=histogram(row_vec1);   
AA3.Normalization='pdf';
AA3.FaceColor=[0 1 1];
   hold on ;
  zz1 = fitdist(row_vec1','rayleigh')
  l1=0;l2=max(row_vec1);
x1= l1:((l2-l1)/1000):l2;
hold on; grid on;
 y1=raylpdf(x1,zz1.B);

plot(x1,y1,'r:','LineWidth',1);hold on;
    grid on;
    title('|H_7_2| -> Rayleigh distribution')
    xlabel('x');
    ylabel('Probability distribution function f(x)');
    legend("Histogram for 5000 realizations for "+newline+"subcarrier index 72(choosen at random)",'Rayleigh distribution fit')

 row_vec2=pg(72,:);%each row is the ensemble of sampled random variable 
  %correspondng to a subcarrier index, k, here k=72 ie |H72|^2
  mu_Hi_squared=mean(row_vec2)%% 
   std_dev=std(row_vec2);%% 
   variance= std_dev.^2 ;
   
figure(6)   
AA3=histogram(row_vec2); %exponential PDF  
AA3.Normalization='pdf';
AA3.FaceColor=[0 1 1];
   hold on ;
   lambda2=1/mu_Hi_squared;
x = linspace(0,6*std_dev,4000);
y = lambda2*(exp(-(lambda2.*x)));
xlim([0 6*std_dev]);
plot(x,y,'b-','LineWidth',2);
    grid on;
    title('|H_7_2|^2 -> Exponential distribution')
    xlabel('x');
    ylabel('Probability distribution function f(x)');
    legend("Histogram for 5000 realizations for "+newline+"subcarrier index 72(choosen at random)",'Exponential distribution fit')

allocInfo = ruInfo(cfgSU);
disp('Allocation info:')
disp(allocInfo)
showAllocation(cfgSU)