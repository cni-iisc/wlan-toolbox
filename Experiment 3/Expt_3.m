%Copyright [2025] [Indian Institute of Science, Bangaluru]
%SPDX-License-Identifier: Apache-2.0
% To plot HE-LTF field of the packet preamble

clc;close all;
clear all;
cfgSU = wlanHESUConfig; %wlanHESUConfig creates a single user (SU) high efficiency (HE)format configuration object. 
%This object contains the transmit parameters for the HE-SU format of IEEE P802.11ax/D3.1 standard.
cfgSU.ChannelBandwidth='CBW20';
% 'CBW20' | 'CBW40' |'CBW80' (default) | 'CBW160' | 'CBW320'
cfgSU.MCS = 0;   %BPSK Modulation and coding rate = 1/2. 
cfgSU.HELTFType =1;% 1x HE-LTF, 2x HE-LTF, and 4x HE-LTF, 
%with symbol duration of 3.2, 6.4, and 12.8 µs, respectively.
cfgSU.GuardInterval = 0.8; % 0.8, 1.6, 3.2 µs
cfgSU.APEPLength=100;% Data field carry PSDU's. Specify PSDU length

chanBW = cfgSU.ChannelBandwidth;%default 20MHz channel
psdu = randi([0 1], getPSDULength(cfgSU)*8, 1); % Create a PSDU, getPSDULength(cfgSU)=100 bytes
txWaveform = wlanWaveformGenerator(psdu,cfgSU);
%Produce a waveform containing an 802.11ax HE single user packet 
%WAVEFORM is a complex Ns-by-Nt matrix containing the generated waveform, where
% Ns is the number of time domain samples, Nt is the number of transmitting antennas

% Configure a TGax channel with 20 MHz bandwidth.
tgax = wlanTGaxChannel('ChannelBandwidth','CBW20');
tgax.CarrierFrequency=2.4e9; %default is 5.25GHz
    
% tgax.NumPenetratedWalls = 2 ;%Number of walls between transmitter and receiver. Accounts for the wall penetration loss in the path loss calculation.
% tgax.WallPenetrationLoss = 5; % penetration loss of a single wall in dB
stream = RandStream('combRecursive','Seed',99);
RandStream.setGlobalStream(stream);
tgax.SampleRate = 100e6;
tgax.PathGainsOutputPort = true;
tgax.DelayProfile='Model-B';
tgax.LargeScaleFadingEffect = 'PathLoss';
tgax.TransmitReceiveDistance=10;% in meters, breakpoint distance that obeys freespace pathloss model for Model B is 5m
info_tgax=info(tgax)

sr= wlanSampleRate(cfgSU);
% Pass through a fading indoor TGax channel
%  reset(tgax); % Reset channel for different realization
[tgax_output,pathgains] = tgax(txWaveform);% note Pathgains are independent of the input signal(values or the number of samples Ns) and depends only on the propagation MOdel:
figure(1)
tt=1:length(txWaveform);
subplot(2,1,1)
plot((tt/sr),abs(txWaveform));grid on;
xticks([0 10 20 30 40 50 60]*1e-6);
xlabel('Time (sec)');
ylabel('|Amplitude|');
title('waveform into fading 11ax channel'); 
subplot(2,1,2)
plot((tt/20e6),abs(tgax_output));grid on;
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

LLTF_transmitted = txWaveform((ind.LLTF(1):ind.LLTF(2)), :);
a11=[ LLTF_transmitted(33:96) LLTF_transmitted(97:160)];
% LLTF1 (64 samples) and LLTF2 (64 samples) are same
a22=[ LLTF_transmitted(1:32) LLTF_transmitted(129:160)];
% Cyclic prefix and second half of LLTF2 are same
figure(3);
subplot(2,1,1)
plot(20*log10(abs(LLTF_transmitted)),'LineWidth',1.5);grid on;
title('power of transmitted LLTF symbol versus sample number')
xlabel('sample number');
ylabel('dB');
subplot(2,1,2)
plot((1:32),20*log10(abs(LLTF_transmitted(1:32))), 'r:','LineWidth',2);hold on;grid on;
plot((33:96),20*log10(abs(LLTF_transmitted(33:96))), 'm:','LineWidth',2);hold on;
plot((97:160),20*log10(abs(LLTF_transmitted(97:160))), 'g:','LineWidth',2);hold on;
plot((129:160),20*log10(abs(LLTF_transmitted(129:160))), 'r:','LineWidth',2);hold on;
xlabel('sample number');
ylabel('dB');



