%%%%Own script to find Channel Frequency Response (CFR) of the populated subcarriers 
%of HE- LTF field for (MODEL D) Delay Profile

function [CFR,pg]=HELTF_func_avg_est_Hf(cfgSU,Xk,tgax,txWaveform)
L=5000;%L is the Number of channel realizations
hk_hat=[];
for l=1:L
 reset(tgax); % Reset channel for different realization
% Pass the waveform through the fading tgax channel model
[tgax_output,pathgains] = tgax(txWaveform);

%%% 11ax FADING channel
rxWaveform=tgax_output;
ind = wlanFieldIndices(cfgSU);
rxHELTF= rxWaveform((ind.HELTF(1):ind.HELTF(2)), :);
%     HELTF: [721 1040]

A1=size(rxHELTF); % [320  1]
heltfDemod = wlanHEDemodulate(rxHELTF,'HE-LTF',cfgSU.ChannelBandwidth,cfgSU.GuardInterval, cfgSU.HELTFType);
%frequency domain view, its on every subcarrier
%fft(complex numbers)= complex constellation symbols on every subcarrier faded by the channel
%size(heltfDemod) % [242 1]
Yk= heltfDemod;

% channel estimation
% Lkk=[Lk(7:32) Lk(34:59)];%% 33rd values is zero
for kk=1:242
estimated_hk(kk)= Yk(kk)/Xk(kk); % estimated CFR [1 242]
end
% estimated_hk=[estimated_hk(1:121) zeros(1,3) estimated_hk(122:242)];
estimated_hk1=estimated_hk.';%[242 1]
hk_hat=[hk_hat estimated_hk1 ]; % matrix of size 242 X L
hk_abs=abs(hk_hat);
CFR=hk_abs;
pg=hk_abs.^2;% matrix of size 242 X L
 % every column of pg has Hk^2 for k from 1 to 242, 
 %corresponding to one channel realization
end
end