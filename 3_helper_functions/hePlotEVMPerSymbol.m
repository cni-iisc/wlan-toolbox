function rmsEVM = hePlotEVMPerSymbol(eqDataSym,cfgRx,evmSymPlot,varargin)
% hePlotEVMPerSymbol Plots EVM per symbols for all spatial streams
%
%   RMSEVM = hePlotEVMPerSymbol(EQDATASYM,CFGRX,EVMSYMPLOT) plots EVM per
%   symbol averaged over subcarriers for all spatial streams.
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
%   EVMSYMPLOT is a system object of type <a href="matlab:help('dsp.ArrayPlot')">dsp.ArrayPlot</a>.
%
%   RMSEVM = hePlotEVMPerSymbol(...,USERIDX,NUMUSERS) displays user
%   number and number of user information in the figure title.

%   Copyright 2019 The MathWorks, Inc.

[~,~,Nss] = size(eqDataSym);

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

rmsEVMPerSym = permute(EVM(eqDataSym),[2 3 1]);

str = cell(Nss,1);
for iss=1:Nss
    str{iss} = sprintf('Spatial stream %d',iss);
end

evmSymPlot.ChannelNames = str;
if nargin>3
    evmSymPlot.Name = sprintf('EVM per symbol, user#%d/%d',userIdx,numUsers);    
else
    evmSymPlot.Name = sprintf('EVM per symbol');
end

rmsEVM = 20*log10(rmsEVMPerSym/100);
evmSymPlot(rmsEVM);
evmSymPlot.show
release(evmSymPlot);

end