function chanEst = heChannelToChannelEstimate(chan,cfg)
%heChannelToChannelEstimate Return the perfect channel estimate for HE fields
%   CHANEST = heChannelToChannelEstimate(CHAN,CFG) incorporates any
%   precoding applied, and the cyclic shifts per space-time stream to form
%   the perfect channel estimate, CHANEST, as estimated using the HE-LTF
%   fields.
%
%   CHANEST is a Nst-by-Nsym-by-Nsts-by-Nr array where where Nst is the
%   number of active (occupied) subcarriers, Nsym is the number of symbols,
%   Nsts is the number of space-time streams, and Nr is the number of
%   receive antennas.
%
%   CHAN is the frequency domain channel response for active subcarriers
%   and is a Nst-by-Nsym-by-Nt-by-Nr array where Nt is the number of
%   transmit antennas.
%
%   CFG is a format configuration object of type <a href="matlab:help('wlanHESUConfig')">wlanHESUConfig</a>.  

%   Copyright 2019 The MathWorks, Inc.

%#codegen

W = getPrecodingMatrix(cfg); % Nst-by-Nsts-by-Ntx

% Apply spatial mapping and cyclic shift
tmp = sum(bsxfun(@times,chan,permute(W,[1 4 3 5 2])),3); % Nst-by-Nsym-by-1-by-Nr-by-Nsts

% Scale the channel estimate down as the HE demodulator does not try to
% scale by Nsts the practical channel estimate is scaled.
tmp = tmp/sqrt(sum(cfg.NumSpaceTimeStreams)); 

% Permute to Nst-by-Nsym-by-Nsts-by-Nr
chanEst = permute(tmp,[1 2 5 4 3]);

end