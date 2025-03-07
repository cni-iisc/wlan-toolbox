function rmsEVM = hePlotEVMPerSubcarrier(eqDataSym,cfgRx,evmSubcarrierPlot,varargin)
% hePlotEVMPerSubcarrier Plots EVM per subcarrier for all spatial streams
%
%   RMSEVM = hePlotEVMPerSubcarrier(EQDATASYM,CFGRX,EVMSUBCARRIERPLOT)
%   plots EVM per subcarriers averaged over symbols for all spatial
%   streams.
%
%   RMSEVM is the EVM of EQDATASYM in decibels.
%   
%   EQDATASYM are the demodulated HE-Data field OFDM symbols for a user,
%   specified as a Nsd-by-Nsym-by-Nss matrix of real or complex values,
%   where Nsd is the number of data subcarriers in the HE-Data field and
%   Nsym is the number of OFDM symbols, and Nss is the number of spatial
%   streams.
%
%   CFGRX is the format configuration object of type <a href="matlab:help('wlanHERecoveryConfig')">wlanHERecoveryConfig</a>.
%
%   EVMSUBCARRIERPLOT is a system object of type <a href="matlab:help('dsp.ArrayPlot')">dsp.ArrayPlot</a>.
%
%   RMSEVM = hePlotEVMPerSubcarrier(...,USERIDX,NUMUSERS) displays user
%   number and number of user information in the figure title.

%   Copyright 2019 The MathWorks, Inc.

[Nsd,~,Nss] = size(eqDataSym); 
rmsEVMPerSC = zeros(Nsd,Nss);

if nargin == 5
    userIdx = varargin{1};
    numUsers = varargin{2};
elseif nargin == 4
    userIdx = varargin{1};
    numUsers = 1; % Number of users are unKnown, prefix this to 1
end

EVM = comm.EVM;
EVM.ReferenceSignalSource = 'Estimated from reference constellation';
EVM.ReferenceConstellation = wlanReferenceSymbols(cfgRx);

for iss = 1:Nss
    for isd = 1:Nsd
        rmsEVMPerSC(isd,iss) = EVM(eqDataSym(isd,:,iss).');
        release(EVM);
    end
end

ofdmInfo = wlanHEOFDMInfo('HE-Data',cfgRx.ChannelBandwidth,cfgRx.GuardInterval,[cfgRx.RUSize cfgRx.RUIndex]);
dataInd = ofdmInfo.ActiveFFTIndices(ofdmInfo.DataIndices);
Nfft = ofdmInfo.FFTLength;

evmFFT = nan(Nfft,Nss);
rmsEVM = 20*log10(rmsEVMPerSC/100);
evmFFT(dataInd,:) = rmsEVM;
evmSubcarrierPlot.XOffset = -Nfft/2;

str = cell(Nss,1);
for iss=1:Nss
    str{iss} = sprintf('Spatial stream %d',iss);
end

evmSubcarrierPlot.ChannelNames = str;
if nargin>3
    evmSubcarrierPlot.Name = sprintf('EVM per subcarrier, user#%d/%d',userIdx,numUsers);
else
    evmSubcarrierPlot.Name = sprintf('EVM per subcarrier');
end
evmSubcarrierPlot(evmFFT)
evmSubcarrierPlot.show
release(evmSubcarrierPlot);

end