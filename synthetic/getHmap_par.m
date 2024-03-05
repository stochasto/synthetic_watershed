% Function to obtain the critical hmin map for two ellipses in various configurations.
% The first ellipse has its major axis inclined at 90 degrees to the horizontal, 
% we call this position 'vertical'. Throughout the course of the experiment, the 
% first ellipse is stationary, while the second ellipse is placed at
% different points on the plane, at various angles. By angle, we mean the inclination of
% the major axis of the second ellipse with the horizontal. 
%
% USAGE: Suppose we want to determine the critical hmin maps for an angle 
% of inclination of the second ellipse, say 30. 
% The function call is: [hf nf] = getHmap_par(1200, [100 200 100 200], [30]);
% where A = [100 200 100 200] has the semi minor and major axes of the two
% ellipses, see below for a description.
% The following steps are followed
% 1. We determine a smaller region than the domain, within which the center
% of the second ellipse is placed. 
% 2. One of the angles is chosen, say 30 degrees. The second ellipse will
% be placed at each point of this subdomain, at 30 degrees. For each point,
% we get a certain overlap of the two ellipses and different number of
% initial minima.
% 3. We call the function getCritMinEllFast(), which determines the
% critical hmin and the number of minima at each point.
% 4. The maps are written out as excel files.


% The end result is a series of 2D maps, at each point it carries the 
% critical hmin and the number of initial minima. 
% Inputs: A -> array with major and minor axes of ellipses. 
%         A(1); % Semi minor axis of central ellipse
%         A(2); % Semi major axis of central ellipse
%         A(3); % Semi minor axis of moving ellipse
%         A(4); % Semi major axis of moving ellipseA(1) ;
%         theta -> array with angles, number of angles are numAngles
%         N -> size of domain, it should be large enough to accomodate all
%         overlaps.
% Output: hMap -> Cell of size (numAngles,1), has map of critical hmin
%         nMap -> Cell of size (numAngles,1), has map of initial minima at
%         0 hmin.
% To read in the excel files written by the code use the following:
% Say we had b1 = 50; a1 = 100; b2 = 50; a2 = 100 and theta = 90; use
% hMap = readmatrix('hMapf_a1_100_b1_50_a2_100_b2_50_theta_90.xlsx','Sheet','90');
% Then display this hMap by the command:
% imagesc(hMap), colormap(jet), colorbar, axis square, axis image

function [hMap nMap] = getHmap_par(N, A, theta)

%% Get ellipse dimensions

b1 = A(1); % Semi minor axis of central ellipse
a1 = A(2); % Semi major axis of central ellipse

b2 = A(3); % Semi minor axis of moving ellipse
a2 = A(4); % Semi major axis of moving ellipse

%% Angle and map dimensions

numAngles = max(size(theta));

xc = 0.5*N;
yc = 0.5*N;

% Limits for centres, with a tolerance
xmin = xc - (b1 + a2) - 5;
xmax = xc + (b1 + a2) + 5;
ymin = yc - (a1 + a2) - 5;
ymax = yc + (a1 + a2) + 5;

% xmin = xc - (b1 + b2) - 5;
% xmax = xc + (b1 + b2) + 5;
% ymin = yc - (a1 + b2) - 5;
% ymax = yc + (a1 + b2) + 5;

%% Steps, decides the step size on the grid
xStep = 1;
yStep = 1;

%xStep = 50;
%yStep = 50;

%% The sub-grid
numX = floor((xmax - xmin)/xStep + 1);
numY = floor((ymax - ymin)/yStep + 1);

% Coordinates of roi
roiX = linspace(xmin, xmax, numX);
roiY = linspace(ymin, ymax, numY);

% Actual coordinates of center
[roi2X, roi2Y] = meshgrid(roiX, roiY);

% Indices of output cell
[i2, j2] = meshgrid(1:1:numX, 1:1:numY);

%% Setup dimensions cell

eList = cell(2,4);

% Central ellipse
eList{1,1} = [yc xc];
eList{1,2} = b1;
eList{1,3} = a1;
eList{1,4} = 90;

% Moving ellipse
eList{2,2} = b2;
eList{2,3} = a2;

%% Allocate output cells

hMap = cell(numAngles,1);
nMap = cell(numAngles,1);
%heightMap = cell(numAngles,1);
%spanMap = cell(numAngles,1);

%% Parallel

numThreads = 32;
delete(gcp('nocreate'));
parpool(numThreads);

nTot = numX*numY;
nPoints = floor( (nTot + numThreads - 1)/numThreads );

%% Iterate over the plane and angles

tic;
for i = 1:1:numAngles
    eList{2,4} = theta(i);
    
    % grid format
    hMap{i} = zeros(numY, numX);
    nMap{i} = zeros(numY, numX);
    
    % grid adapted to parallelization
    critHmin = zeros(nPoints,numThreads);
    numInit = zeros(nPoints,numThreads);
    
    parfor thread = 1:1:numThreads
        
        %thread
        eTemp = eList;
        hA = zeros(nPoints,1);
        nA = zeros(nPoints,1);
        
        for j = 1:1:nPoints
            ind = (thread - 1)*nPoints + j;
            if (ind <= nTot)
            eTemp{2,1} = [roi2Y(ind) roi2X(ind)];
            E1 = makeEllipse_angle(N,eTemp); 
            [hA(j),nA(j)] = getCritMinEllFast(N, E1, min(b1,b2));
            end
        end
        critHmin(:,thread) = hA;
        numInit(:,thread) = nA;
    end
    hMap{i} = reshape(critHmin(1:nTot),[numY, numX]);
    nMap{i} = reshape(numInit(1:nTot),[numY, numX]);
end
toc
     
%% Write to excel

resultDir = '.'

for i = 1:1:numAngles
    
    fileStr = strcat('a1_',num2str(a1),'_b1_',num2str(b1),'_a2_',num2str(a2),'_b2_',num2str(b2));
    fileStr = strcat(fileStr,'_theta_',num2str(theta(i)));
    
    hMapFile = strcat('hMapf_',fileStr,'.xlsx');
    nMapFile = strcat('nMapf_',fileStr,'.xlsx');
    
    sheetName = strcat(num2str(theta(i)));
    writematrix(hMap{i},hMapFile,'Sheet',sheetName);
    writematrix(nMap{i},nMapFile,'Sheet',sheetName);
end


