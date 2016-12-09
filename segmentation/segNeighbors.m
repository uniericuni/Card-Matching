function Bmap = segNeighbors(svMap)

%%% function Bmap = segNeighbors(svMap)
%  EECS 504 Foundations of Computer Vision
%
%  Implement the code to compute the adjacency matrix for the superpixel graph
%  captured by svMap
%
%  INPUT:  svMap is an integer image with the value of each pixel being
%           the id of the superpixel with which it is associated
%  OUTPUT: Bmap is a binary adjacency matrix NxN (N being the number of superpixels
%           in svMap).  Bmap has a 1 in cell i,j if superpixel i and j are neighbors.
%           Otherwise, it has a 0.  Superpixels are neighbors if any of their
%           pixels are neighbors.

segmentList = unique(svMap);
segmentNum = length(segmentList);

%%%% IMPLEMENT the calculation of the adjacency
Bmap = sparse(segmentNum, segmentNum);
[h, w] = size(svMap);

for i = 1:h
    for j = 1:w
        if j+1 <= w && svMap(i, j+1) ~= svMap(i, j)
            Bmap(svMap(i, j+1), svMap(i, j)) = 1;
            Bmap(svMap(i, j), svMap(i, j+1)) = 1;
        end
        if i+1 < h
            if j-1 > 0 && svMap(i+1, j-1) ~= svMap(i, j)
                Bmap(svMap(i+1, j-1), svMap(i, j)) = 1;
                Bmap(svMap(i, j), svMap(i+1, j-1)) = 1;
            end
            if svMap(i+1, j) ~= svMap(i, j)
                Bmap(svMap(i+1, j), svMap(i, j)) = 1;
                Bmap(svMap(i, j), svMap(i+1, j)) = 1;
            end
            if j+1 <= w && svMap(i+1, j+1) ~= svMap(i, j)
                Bmap(svMap(i+1, j+1), svMap(i, j)) = 1;
                Bmap(svMap(i, j), svMap(i+1, j+1)) = 1;
            end
        end
    end
end
