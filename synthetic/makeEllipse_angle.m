% Function to make ellipses in an NxN domain. 
%
% The equation of an ellipse with centre at [x0,y0] and angle of inclination
% of theta degrees with the horizontal, semi major axis a, and semi minor
% axis b is: 
% y = ( ( (x - x0))*cosd(theta) + (y - y0)*sind(theta))/a)^2
%      + ( ( (x - x0)*sind(theta) - (y - y0)*cosd(theta))/b)^2. This
%      equation can be verified by applying translation and rotation 2D
%      matrices to a simple non-rotated ellipse centred at the origin.
%
% Input: Ellipse geometry is provided in the cell eList. Each row of eList
% carries the geometry information of a single ellipse. The first column
% has the centre, the second has the semi-minor axis, the third column has
% the semi-major axis and the fourth column has angle of inclination of the
% major axis with the horizontal.
%
% For example, if we want two ellipses with centres 
% at [x1,y1] and [x2,y2], semi-major axes a1,a2,
% semi-minor axes b1,b1 and angle of inclination of major axis with the
% horizontal theta1,theta2, eList will be:
% eList{1,1} = [y1,x1]; eList{1,2} = b1; eList{1,3} = a1; eList{1,4} = theta1;
% eList{2,1} = [y2,x2]; eList{2,2} = b2; eList{2,3} = a2; eList{2,4} = theta2;
% Note that the y's and x's are interchanged in the eList structure to
% reflect the Matlab matrix indexing system.


function E1 = makeEllipse_angle(N,eList)

s = (size(eList));

if (s(1) <= 3)
    s = s(1);
else
    s = max(s);
end

E1 = zeros(N,N);

for i = 1:1:N
    for j = 1:1:N
        for k = 1:1:s
            c = eList{k,1};
            a = eList{k,2};
            b = eList{k,3};
            theta = eList{k,4};
            %if ( ((i - c(1))/a)^2 + ((j - c(2))/b)^2 ) <i= 1
            expEll = ( ( (i - c(1))*cosd(theta) + (j - c(2))*sind(theta))/a)^2;
            expEll = expEll + ( ( (i - c(1))*sind(theta) - (j - c(2))*cosd(theta))/b)^2;
            if expEll <= 1
                E1(i,j) = 1;
                break
            end
        end
    end
end
