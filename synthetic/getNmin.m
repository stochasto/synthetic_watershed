% Function to obtain number of minima in a marker image.

function nMin = getNmin(marker)
rc = regionprops(marker);
nMin = numel(rc);
end