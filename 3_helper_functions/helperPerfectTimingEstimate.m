function [offset,mag] = helperPerfectTimingEstimate(pathGains,pathFilters)
%helperPerfectTimingEstimate perfect timing estimation
%   [OFFSET,MAG] = helperPerfectTimingEstimate(PATHGAINS,PATHFILTERS)
%   performs perfect timing estimation. To find the peak of the channel
%   impulse response, the function first reconstructs the impulse response
%   from the channel path gains array PATHGAINS and the path filter impulse
%   response matrix PATHFILTERS. The function returns the estimated timing
%   offset OFFSET in samples and the channel impulse response magnitude
%   MAG.
%
%   PATHGAINS must be an array of size Ncs-by-Np-by-Nt-by-Nr-by-Nl, where
%   Ncs is the number of channel snapshots, Np is the number of paths, Nt
%   is the number of transmit antennas, Nr is the number of receive
%   antennas, and Nl is the number of links. The channel impulse response
%   is averaged across all channel snapshots and summed across all transmit
%   antennas and receive antennas before timing estimation.
%
%   PATHFILTERS must be a matrix of size Np-by-Nh where Nh is the number of
%   impulse response samples. The path filters is assumed to be the same
%   for all links.
%
%   OFFSET is a vector of length Nl indicating estimated timing offset, an
%   integer number of samples relative to the first sample of the channel
%   impulse response reconstructed from PATHGAINS and PATHFILTERS.
%
%   MAG is a matrix of size Nh-by-Nr-by-Nl giving the impulse response
%   magnitude for each receive antenna.

%   See also helperPerfectChannelEstimate.

%   Copyright 2019 The MathWorks, Inc.

%#codegen

validateInputs(pathGains,pathFilters);

% Get number of paths 'Np', number of transmit antennas 'Nt' and number
% of receive antennas 'Nr' in the path gains array
[~,Np,Nt,Nr,Nl] = size(pathGains);

% Get number of channel impulse response samples 'Nh'
Nh = size(pathFilters,2);

% Create channel impulse response array 'h' for each impulse response
% sample, receive antenna and transmit antenna
h = zeros(Nh,Nr,Nt,Nl,'like',pathGains);

% Average the path gains array across all time elements (1st
% dimension), and permute to switch the antenna dimensions. The
% pathGains are now of size Np-by-Nr-by-Nt-by-Nl
pathGains = permute(mean(pathGains,1),[2 4 3 1 5]);

% For each path, add its contribution to the channel impulse response
% across all transmit and receive antennas
for nl = 1:Nl
    for np = 1:Np
        h(:,:,:,nl) = h(:,:,:,nl) + bsxfun(@times,pathFilters(np,:).',pathGains(np,:,:,:,nl));
    end
end

% Combine the transmit antennas in the channel impulse response array,
% leaving a matrix of impulse response samples versus receive antennas
h = sum(h,3);

% Take the magnitude of the impulse response matrix
mag = abs(h);

% Find the peak of the impulse response magnitude after summing across
% receive antennas and return the offset to the peak location
[~,peakindex] = max(sum(mag,2));
offset = squeeze(peakindex - 1);

end

function validateInputs(pathGains,pathFilters)
% Check inputs
    
    % Validate channel path gains
    assert(~(ndims(pathGains)>5),'The number of dimensions in the path gains %d must be less than or equal to 5',ndims(pathGains));
    
    % Validate path filters impulse response
    assert(~(size(pathGains,2)~=size(pathFilters,1)),'The number of paths (2nd dimension size) in the path gains %d must equal the number of paths (1st dimension size) in the path filters %d.',size(pathGains,2),size(pathFilters,2));
    
end