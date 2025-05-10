%% OFDM using WLAN Toolbox
%  LS estimation of CFR over LLTF subcarriers coded on 16/10/2019
clc;close all;clear all;
% Create the HE packet configuration and transmit waveform.
cfgSU = wlanHESUConfig; %wlanHESUConfig creates a single user (SU) high efficiency (HE)format configuration object. This object contains the transmit
%parameters for the HE-SU format of IEEE P802.11ax/D3.1 standard.
cfgSU.ChannelBandwidth='CBW20';
cfgSU.MCS = 8;   %256 QAM Modulation and coding rate = 3/4. Applicable only for user data. Not to preamble
cfgSU.HELTFType =1;
cfgSU.GuardInterval = 0.8;
cfgSU.APEPLength=0;% Data field carry PSDU's. Specify PSDU length
fs = wlanSampleRate(cfgSU); % Get baseband sample rate% 20MHz=BW
disp(cfgSU)

chanBW = cfgSU.ChannelBandwidth;%default 20MHz channel
psdu = randi([0 1], getPSDULength(cfgSU)*8, 1); % Create a PSDU, getPSDULength(cfgSU)=100 bytes
txWaveform = wlanWaveformGenerator(psdu,cfgSU,'WindowTransitionTime',0); % Disable windowing);
%Produce a waveform containing an 802.11ax HE single user packet 
%WAVEFORM is a complex Ns-by-Nt matrix 

ind = wlanFieldIndices(cfgSU);
LLTF_transmitted = txWaveform((ind.LLTF(1):ind.LLTF(2)), :);

% Configure a TGax channel with 20 MHz bandwidth.
tgax = wlanTGaxChannel('ChannelBandwidth','CBW20');
tgax.EnvironmentalSpeed=0;
tgax.CarrierFrequency=2.4e9;
tgax.LargeScaleFadingEffect = 'PathLoss and shadowing';    
tgax.NumPenetratedWalls = 2 ;%Number of walls between transmitter and receiver. Accounts for the wall penetration loss in the path loss calculation.
tgax.WallPenetrationLoss = 5; % penetration loss of a single wall in dB
 tgax.RandomStream = 'mt19937ar with seed';% source of the random number stream. mt19937ar alogorithm generates normally distributed random numbers.
 tgax.Seed = 10;% initial seed of the random number stream
 tgax.SampleRate = 100e6;%%%%%% Do not change this sample rate. For < 100e6, pathgains 1st row dont match to tgax(impulse input)
 tgax.PathGainsOutputPort = true;
tgax.DelayProfile='Model-D';%Dealy profile model is Model-B
tgax.ChannelBandwidth='CBW20';
tgax.TransmitReceiveDistance=10;% in meters, breakpoint distance that obeys freespace pathloss model for Model B is 5m
disp(tgax)

 % Pass through a fading indoor TGax channel
[tgax_output,pathgains] = tgax(txWaveform);%% note Pathgains are independent of the input signal(values or the number of samples Ns) and depends only on the propagation MOdel:
reset(tgax); % Reset channel for different realization

info_tgax = info(tgax);
% The PathDelays provides the delay in secods of each path (non-zero)
nonZeroTapIdx = round(info_tgax.PathDelays*tgax.SampleRate)+1;
% ChannelFilterCoefficients is an Np-by-Nh where Nh is the number of
% impulse response samples. This gives us the length of the channel impulse response.
% Create the channel impulse response by setting non-zero paths to the path
% gains returned by the channel
Nh = size(info_tgax.ChannelFilterCoefficients,2);
impr = zeros(Nh,1);
impr(nonZeroTapIdx) = pathgains(1,:);

figure(1)
time = (1/tgax.SampleRate)*(0:length(impr)-1);
stem(time,abs(impr));grid on;
xlabel('Time (sec)');
ylabel('|Amplitude|');
title('Channel Impulse Response Model-D'); 

%%% 11ax FADING channel
rxWaveform=tgax_output;

idxLLTF = wlanFieldIndices(cfgSU,'L-LTF');
LLTF_rx=rxWaveform(idxLLTF(1):idxLLTF(2),:);%Time domain received samples
%LLTF_rx=rxWaveform(161:320)
a=[ LLTF_rx(33:96) LLTF_rx(97:160)]
%%% Note LLTF1 and LLTF2 received are same! as Txed are same
LLTF_rx_discardCP=LLTF_rx(33:160); %without CP

lltfDemod = wlanHEDemodulate(LLTF_rx,'L-LTF',cfgSU);%lltfDemod is 52 X 2
%  SYM = wlanHEDemodulate(RX,FIELDNAME,CFG) demodulates the time-domain
%   received time-domain signal RX (Ns-by-Nr) using OFDM demodulation parameters appropriate for the specified FIELDNAME.
%   SYM is the demodulated frequency-domain signal, returned as a complex  matrix or 3-D array of size 
%Nst-by-Nsym-by-Nr. 
%Nst is the number of active (occupied) subcarriers in the field. 
%Nsym is the number of OFDM symbols. Nr is the number of receive antennas.

%%%ESTIMATION of CHANNEL EVERY SUB-CARRIER using wlanLLTFChannelEstimate
figure(2)
subplot(3,1,1)
est = wlanLLTFChannelEstimate(lltfDemod,chanBW);
est=[est(1:26).' zeros(1,1) est(27:52).'];
kk=[-26:26];
stem(kk,abs(est));
M1=max(abs(est))+0.1*max(abs(est));
axis([-26 26 0 M1]);grid on;
xlabel('subcarrier index');
ylabel('estimated |CFR|');
title("Estimated CFR : using wlanHEDemodulate"+ newline  + "and wlanLLTFChannelEstimate")

%%%%% OWN CODE for channel estimation
yk=lltfDemod (:,1);%%%%%%%% here yk is 52 X 1 obtained from 160X1 rx samples

lltfLower = [1; 1;-1;-1; ...
        1; 1;-1; 1; ...
        -1; 1; 1; 1; ...
        1; 1; 1;-1; ...
        -1; 1; 1;-1; ...
        1;-1; 1; 1; ...
        1; 1;];
    lltfUpper = [1; ...
           -1;-1; 1; 1; ...
           -1; 1;-1; 1; ...
           -1;-1;-1;-1; ...
           -1; 1; 1;-1; ...
           -1; 1;-1; 1; ...
           -1; 1; 1; 1; 1];   %has 52 populated subcarriers before performing IFFT

       % Add null subcarriers to the populated subcarriers  
LLTF_BPSK = [zeros(6,1); lltfLower; 0; lltfUpper; zeros(5,1)]; %length=64
       % first 6 Subcarriers , central subcarrier and last 5 subcarriers are Null
% subcarriers. In total there are 12 null subcarriers and 52 populated subcarriers
Lk=LLTF_BPSK.';  

Lkk=[lltfLower' lltfUpper']
% Lkk=[Lk(7:32) Lk(34:59)]%% 33rd values is zero
for k=1:52
estimated_hk(k)= yk(k)/Lkk(k); % estimated CFR
end
estimated_hk=[estimated_hk(1:26) zeros(1,1) estimated_hk(27:52)];

kk=[-26:26];
figure(2)
subplot(3,1,2)
stem(kk,abs(estimated_hk));
M1=1.1*max(abs(estimated_hk));
axis([-26 26 0 M1]);
grid on; title("Estimated CFR for: using wlanHEDemodulate " + newline  + "& OWN SCRIPT for estimation")
xlabel('subcarrier index');
ylabel('estimated |CFR|');

%%%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
%%%%% DFT of Actual Channel impulse response plot(9 tap filter coefficients) of MODEL B plot
H_K_from_impr=fftshift(fft((impr),64));%%% impr is the actual h(n) of delay profile Model 'B'
%%% first take fft and then do fft shift. 

H_K_from_impr=H_K_from_impr.';
H_K_from_impr=[H_K_from_impr(7:32) zeros(1,1) H_K_from_impr(34:59)];
% null subcarrier index are vomited

kk=[-26:26]; % null subcarrier index are vomited and populated subcarrier index are considered where the LLTF constellation symbols populated
subplot(3,1,3);
stem(kk,abs(H_K_from_impr)); % true Hk computed from actual Channel impulse response(9 tap filter coefficients) of MODEL B'
M2=1.1*max(abs(H_K_from_impr));
axis([-26 26 0 M2]);
grid on;
xlabel('subcarrier index');
ylabel('True |CFR|');
title('DFT of Actual Channel imp response (MODEL-D)');
% legend('The channel is estimated only at the populated subcarriers')

info = wlanHEOFDMInfo('L-LTF',cfgSU);
data = LLTF_BPSK(info.DataIndices,:,:);
 pilots = LLTF_BPSK(info.PilotIndices,:,:);
 % Save all variables from the workspace to LS_estimation_of_CFR_fading_channel.mat:
filename = 'LS_estimation_of_CFR_fading_channel'; %.mat file. Give name other than the matlab script filename!
save(filename)

% wlanHEOFDMInfo('L-LTF',cfgSU)