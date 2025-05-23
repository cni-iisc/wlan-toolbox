function [failCRC,cfgUsers,bitsUsers,eqUserSym] = heSIGBUserFieldDecode(rx,chanEst,noiseVar,cfgRx)
%heSIGBUserFieldDecode Decode HE-SIG-B user field
%
%   [FAILCRC,CFGUSERS] =
%   heSIGBUserFieldDecode(RX,CHANEST,NOISEVAR,CFGUSERS) decode the HE-SIG-B
%   user field given the HE-SIG-B field samples, RX, channel estimate,
%   CHANEST, noise variance, NOISEVAR, and recovery configuration object
%   CFGRX.
%
%   FAILCRC represents the result of the CRC for each user. It is true if
%   the user fails the CRC. It is a logical row vector of size
%   1-by-NumUsers.
%
%   Returned CFGUSERS is a cell array of size 1-by-NumUsers. CFGUSERS is
%   the updated format configuration object after HE-SIG-B user field
%   decoding, of type <a href="matlab:help('wlanHERecoveryConfig')">wlanHERecoveryConfig</a>. The updated format 
%   configuration object CFGUSERS is only returned for the users who pass
%   the CRC.
%
%   RX are the HE-SIG-B field samples.
%
%   CHANEST is a complex Nst-by-1-by-Nr array containing the estimated
%   channel at data and pilot subcarriers, where Nst is the number of
%   occupied subcarriers and Nr is the number of receive antennas.
%
%   NOISEVAR is the noise variance estimate, specified as a nonnegative
%   scalar.
%
%   The input CFGRX is the format configuration object of type 
%   <a href="matlab:help('wlanHERecoveryConfig')">wlanHERecoveryConfig</a>, which specifies the parameters for the HE-MU format.

%   Copyright 2018-2019 The MathWorks, Inc.

chanBW = cfgRx.ChannelBandwidth;

% Demodulate HE-SIGB field
demodUserFieldData = wlanHEDemodulate(rx,'HE-SIG-B',chanBW);

% Extract data and pilots symbols
preheInfo = wlanHEOFDMInfo('HE-SIG-A',chanBW);
demodUserData = demodUserFieldData(preheInfo.DataIndices,:,:);
demodUserPilot = demodUserFieldData(preheInfo.PilotIndices,:,:);

% Estimate and correct common phase error
demodUserData = heCPECorrection(demodUserData,demodUserPilot,chanEst(preheInfo.PilotIndices,:,:),chanBW);

% Merge channels
[userOne20MHz,chanEstOne20MHz] = heSIGBMergeSubchannels(demodUserData,chanEst(preheInfo.DataIndices,:,:),chanBW);

% Perform equalization
[eqUserSym,csi] = preHESymbolEqualize(userOne20MHz,chanEstOne20MHz,noiseVar);

% Return a cell array of objects each representing a user
[bitsUsers,failCRC,cfgUsers] = wlanHESIGBUserBitRecover(eqUserSym,noiseVar,csi,cfgRx);

end