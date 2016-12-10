%LICENSE CONDITIONS
% 
% Copyright (2005), University of British Columbia.
% 
% This software for the detection of invariant keypoints is being made
% available for individual research use only.  Any commercial use or any
% redistribution of this software requires a license from the University
% of British Columbia.
% 
% The following patent has been issued for methods embodied in this
% software: "Method and apparatus for identifying scale invariant
% features in an image and use of same for locating an object in an
% image," David G. Lowe, US Patent 6,711,293 (March 23,
% 2004). Provisional application filed March 8, 1999. Asignee: The
% University of British Columbia.
% 
% For further details on obtaining a commercial license, contact David
% Lowe (lowe@cs.ubc.ca) or the University-Industry Liaison Office of the
% University of British Columbia. 
% 
% THE UNIVERSITY OF BRITISH COLUMBIA MAKES NO REPRESENTATIONS OR
% WARRANTIES OF ANY KIND CONCERNING THIS SOFTWARE.
% 
% This license file must be retained with all copies of the software,
% including any modified or derivative versions.

function num = match(image1, image2, showResult)
% This function reads two images, finds their SIFT features, and
%   displays lines connecting the matched keypoints.  A match is accepted
%   only if its distance is less than distRatio times the distance to the
%   second closest match.
% It returns the number of matches displayed.

% Find SIFT keypoints for each image
[im1, des1, loc1] = sift(image1);
[im2, des2, loc2] = sift(image2);

% For efficiency in Matlab, it is cheaper to compute dot products between
%  unit vectors rather than Euclidean distances.  Note that the ratio of 
%  angles (acos of dot products of unit vectors) is a close approximation
%  to the ratio of Euclidean distances for small angles.
%
% distRatio: Only keep matches in which the ratio of vector angles from the
%   nearest to second nearest neighbor is less than distRatio.
distRatio = 0.6;   

% For each descriptor in the first image, select its match to second image.
des2t = des2';                          % Precompute matrix transpose
for i = 1 : size(des1,1)
   dotprods = des1(i,:) * des2t;        % Computes vector of dot products
   [vals,indx] = sort(acos(dotprods));  % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
   if (vals(1) < distRatio * vals(2))
      match(i) = indx(1);
   else
      match(i) = 0;
   end
end

if showResult
% Create a new image showing the two images side by side.
im3 = appendimages(im1,im2);

% Show a figure with lines joining the accepted matches.
    figure('Position', [100 100 size(im3,2) size(im3,1)]);
    colormap('gray');
    imagesc(im3);
    hold on;
    cols1 = size(im1,2);
    for i = 1: size(des1,1)
    if (match(i) > 0)
        line([loc1(i,2) loc2(match(i),2)+cols1], ...
             [loc1(i,1) loc2(match(i),1)], 'Color', 'c');
    end
    end
hold off;
end

% calculate error
num = sum(match > 0);

%{
if num==0
    error=inf;
else
    error=0;
    count=0;
    for i=1:size(des1,1)
        if(match(i)>0)
            error=error+norm(des1(i,:)-des2(match(i),:));
            count=count+1;
        end
    end
    error=error/count;
end
%}