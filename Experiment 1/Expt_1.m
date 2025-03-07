%Copyright [2025] [Indian Institute of Science, Bangaluru]
%SPDX-License-Identifier: Apache-2.0
% To obtain the channel impulse response (CIR) for various delay profiles and 
% to obtain the statistics of channel amplitude or the channel envelope

clc;close all;clear all;
cfgSU = wlanHESUConfig; % creates a single user (SU) high efficiency (HE)format configuration object. 
%This object contains the transmit parameters for the HE-SU format of IEEE P802.11ax/D3.1 standard.
cfgSU.ChannelBandwidth='CBW20';
% 'CBW20' | 'CBW40' |'CBW80' (default) | 'CBW160' | 'CBW320'
cfgSU.MCS = 0;   %BPSK Modulation and coding rate = 1/2. 
cfgSU.HELTFType =1;% 1x HE-LTF, 2x HE-LTF, and 4x HE-LTF, 
%with symbol duration of 3.2, 6.4, and 12.8 µs, resp ectively.
cfgSU.GuardInterval = 0.8; % 0.8, 1.6, 3.2 µs
cfgSU.APEPLength=100;% Data field carry PSDU's. Specify PSDU length


% Configure a tgaxChannel channel with 20 MHz bandwidth.
tgaxChannel = wlanTGaxChannel('ChannelBandwidth','CBW20');
tgaxChannel.CarrierFrequency=2.4e9; %default is 5.25GHz   
tgaxChannel.SampleRate = 100e6;
tgaxChannel.PathGainsOutputPort = true;
tgaxChannel.DelayProfile='Model-D';
tgaxChannel.LargeScaleFadingEffect = 'PathLoss';

% release(tgaxChannel)
tgaxChannel.TransmitReceiveDistance=15;% in meters, breakpoint distance that obeys freespace pathloss model for Model B is 5m
PL_dB=info(tgaxChannel).Pathloss
tgaxChannel.NumPenetratedWalls = 2 ;%Number of walls between transmitter and receiver. Accounts for the wall penetration loss in the path loss calculation.
tgaxChannel.WallPenetrationLoss = 2.5; % penetration loss of a single wall in dB
PL_updated_dB=info(tgaxChannel).Pathloss
info_tgaxChannel=info(tgaxChannel)
warning('off','all');

numPackets =5000;
CIR=[];
for kk = 1:numPackets 
psdu = randi([0 1], getPSDULength(cfgSU)*8, 1); % Create a PSDU, getPSDULength(cfgSU)=100 bytes
txWaveform = wlanWaveformGenerator(psdu,cfgSU);
%Produce a waveform containing an 802.11ax HE single user packet 
%WAVEFORM is a complex Ns-by-Nt matrix where
% Ns is the number of time domain samples, Nt is the number of transmitting antennas

% Pass through a fading indoor tgaxChannel channel
[tgaxChannel_output,pathgains] = tgaxChannel(txWaveform);%% note Pathgains are independent of the input signal(values or the number of samples Ns) and depends only on the propagation MOdel:
reset(tgaxChannel);   % reset function resets the filters and creates a new channel realization. 

% The PathDelays provides the delay in seconds of each path (non-zero)
nonZeroTapIdx = round(info_tgaxChannel.PathDelays*tgaxChannel.SampleRate)+1;
Nh = size(info_tgaxChannel.ChannelFilterCoefficients,2);
% ChannelFilterCoefficients is an Np-by-Nh where Nh is the number of
% impulse response samples. Nh gives us the length of the channel impulse response.
impr = zeros(Nh,1);
% Create the CIR by setting non-zero paths to the path gains returned by the channel
impr(nonZeroTapIdx) = pathgains(1,:);
impr_abs=abs(impr);
    size(impr_abs);  %[Nh 1]
    CIR=[CIR impr_abs]; 
    size(CIR);% matrix of size Nh X L = Nh X numPkts
    % each row of CIR is ensemble of R.V corresponding to a particular channel tap
tap_index=CIR(nonZeroTapIdx(4), :); % 4th non-zero channel tap for NLOS  (d>=10 for channel model D)
%tap_index=CIR(nonZeroTapIdx(1), :); % consider always 1st non-zero channel tap for LOS  (d<=10 for channel model D)
size(tap_index);% [1 X Numpkts] has random variables corresponding to 4th tap for all the processed packets
 
end

figure(1)
tt=1:length(txWaveform);
subplot(2,1,1)
plot((tt/20e6),abs(txWaveform));grid on;

xlabel('Time (sec)');
ylabel('|Amplitude|');
title('waveform into fading 11ax channel'); 
subplot(2,1,2)
plot((tt/20e6),abs(tgaxChannel_output));grid on;
xlabel('Time (sec)');
ylabel('|Amplitude|');
title('waveform out of fading 11ax channel'); 

ind=wlanFieldIndices(cfgSU);
figure(2)
preamble=txWaveform((ind.LSTF(1):ind.HELTF(2)));
tt1=1:length(preamble);
plot((tt1/20e6),abs(preamble));grid on;
xticks([0 10 20 30 40]*1e-6);
xlabel('Time (sec)');
ylabel('|Amplitude|');
title('Preamble'); 

figure(3)
time = (1/tgaxChannel.SampleRate)*(0:length(impr)-1);grid on;
stem(time,impr_abs);%h(n)is same as impulse_response
grid on;
xlabel('Time (sec)');
ylabel('|Amplitude|');
title('Channel Impulse Response Model-D'); 
legend('nonZero Tap Index')
% save(sprintf('Impulse_response_fading_channel_1_%02d',ii), 'impr_abs');

 figure(4)   
AA4=histogram(tap_index); %exponential PDF  
size(tap_index); %[1 X Numpkts]
AA4.Normalization='pdf';
AA4.FaceColor=[0 1 1];
% axis([0 10 0 1])
   hold on ;
  zz1 = fitdist(tap_index','rayleigh')
  zz2= fitdist(tap_index','nakagami')
zz3=fitdist(tap_index','rician')

  l1=0;l2=max(tap_index);
x= l1:((l2-l1)/1000):l2;
hold on; grid on;
% y1=raylpdf(x,zz1.B);
y1=pdf('rayleigh',x,zz1.B);
%y = pdf(name,x,A) returns the probability density function (pdf) for the 
%one-parameter distribution family specified by name and the distribution parameter A, evaluated at the values in x.

y2=pdf('nakagami',x,zz2.mu,zz2.omega);
%y = pdf(name,x,A,B) returns the pdf for the two-parameter distribution family specified
%by name and the distribution parameters A and B, evaluated at the values in x
y3=pdf('rician',x,zz3.s, zz3.sigma);

plot(x,y1,'r:','LineWidth',1);hold on;
plot(x,y2,'g-.','LineWidth',1);grid on;
plot(x,y3,'k-.','LineWidth',1);grid on;
legend('Histogram for 5000 realizations \newline  for channel tap index - i','Rayleigh PDF fit','Nakagami PDF fit','Rician PDF fit','Location','NorthEast')
 %*******
title('|h_i| ')
xlabel('x');
 ylabel('Probability density function f_X(x)');
 
