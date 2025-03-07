function hePlotEQConstellation(eqDataSym,cfgRx,ConstellationDiagram,varargin)
% hePlotEQConstellation Plot equalized constellation for all spatial streams
%
%   hePlotEQConstellation(EQDATASYM,CFGRX,CONSTELLATIONDIAGRAM) plots
%   equalized constellation for all spatial streams. 
%
%   EQDATASYM are the demodulated HE-Data field OFDM symbols for a user,
%   specified as a Nsd-by-Nsym-by-Nss matrix of real or complex values,
%   where Nsd is the number of data subcarriers in the HE-Data field and
%   Nsym is the number of OFDM symbols, and Nss is the number of spatial
%   streams.
%
%   CFGRX is the format configuration object of type <a href="matlab:help('wlanHERecoveryConfig')">wlanHERecoveryConfig</a>.
%
%   CONSTELLATIONDIAGRAM is a system object of type <a href="matlab:help('comm.ConstellationDiagram')">comm.ConstellationDiagram</a>.
%
%   hePlotEQConstellation(...,USERIDX,NUMUSERS) displays user number and
%   number of user information in the figure title.

%   Copyright 2019 The MathWorks, Inc.

if nargin==5
    userIdx = varargin{1};
    numUsers = varargin{2};
elseif nargin==4
    userIdx = varargin{1};
    numUsers = 1;
end

[Nsd,Nsym,Nss] = size(eqDataSym);
eqDataSymPerSS = reshape(eqDataSym,Nsd*Nsym,Nss);

str = cell(Nss,1);
for iss=1:Nss
    str{iss} = sprintf('Spatial stream %d',iss);
end

ConstellationDiagram.ReferenceConstellation = wlanReferenceSymbols(cfgRx);
ConstellationDiagram(eqDataSymPerSS);
show(ConstellationDiagram);

if nargin>3
    ConstellationDiagram.Name = sprintf('Equalized data symbols, user #%d/%d',userIdx,numUsers);
else
    ConstellationDiagram.Name = sprintf('Equalized data symbols');
end
ConstellationDiagram.ChannelNames = str;
release(ConstellationDiagram);

end