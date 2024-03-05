% Function to obtain the critical hMin for two ellipses
% The process starts with hmin = 0. The number of minima are determined by
% calling the getNmin() function. 
% Input: N -> Size of domain, A -> Image with ellipses, bMin -> minimum minor
% axis
% Output: critHmin -> hmin at which minima merge
%         numInitMin -> Initial minima at 0 hmin

function [critHmin, numInitMin] = getCritMinEllFast(N, A, bMin)

h = 0;
[W Ibin emarker D] = make_watershed(A,h,'Euclidean',0);

%% Initial minima at h = 0

numInitMin = getNmin(emarker);
 
%% Perform hmin iterations

% Initial hmax set to make sure there is only one minimum
hMax = bMin + 1;
[W Ibin emarker D] = make_watershed(A,hMax,'Euclidean',0);
nMin = getNmin(emarker);

numIter = 0;

while ( nMin == 1)
    
    % Sometimes there can be only one min even for 0 hmin
    % Check for this and return
    if (hMax < 1e-6)
        critHmin = 0;
        return
    end
    
    hNew = 0.5*hMax;
    [W Ibin emarker D] = make_watershed(A,hNew,'Euclidean',0);
    nMin = getNmin(emarker);
    hMax = hNew;
    
end  

% Get mid, and compute nmin
h2 = 2.0*hNew;
h1 = hNew;

% Tolerance and difference
diff = 20;
tol = 1e-1;

while (diff > tol)
    %h2 = 2.0*hNew;
    %h1 = hNew;
    hMid = 0.5*(h1 + h2);
    [W Ibin emarker D] = make_watershed(A,hMid,'Euclidean',0);
    nMin = getNmin(emarker);
    
    if (nMin == 1)
        h2 = hMid;
    else
        h1 = hMid;
    end
    
    numIter = numIter + 1;
    diff = h2 - h1;
        
end
    
critHmin = h1;
% while(nMin > 1)
%     h = h + hStep;
%     [W Ibin emarker D] = make_watershed(A,h,'Euclidean',0);
%     nMin = numel(regionprops(emarker));
% end

%  if (thread == 3)
%      disp('Reached here');
%      fprintf('j is %d and thread is %d\n', j, thread);
%  end


