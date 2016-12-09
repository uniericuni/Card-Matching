function [B] = graphcut(segmentimage,segments,keyindex)

% function [B] = graphcut(segmentimage,segments,keyindex
%
%     EECS Foundation of Computer Vision;
%     Jason Corso
%
% Function to take a superpixel set and a keyindex and convert to a 
%  foreground/background segmentation.
%
% keyindex is the index to the superpixel we wish to use as foreground and
% find its relevant neighbors.

% compute basic adjacency information of superpixels
adjacency = segNeighbors(segmentimage);
%debug
%figure; imagesc(adjacency); title('adjacency');

% normalization for distance calculation based on the image size
% for points (x1,y1) and (x2,y2), distance is
% exp(-||(x1,y1)-(x2,y2)||^2/dnorm)
dnorm = 2*prod(size(segmentimage)/2)^2;

k = length(segments);

capacity = zeros(k+2,k+2);
source = k+1;
sink = k+2;

% this is a single planar graph with an extra source and sink
%
% Capacity of a present edge in the graph is to be defined as the sum of
%  1:  the histogram similarity between the two color histogram feature vectors.
%      use the histintersect function below to compute this similarity 
%  2:  the spatial proximity between the two superpixels connected by the edge.
%      use exp(-D(a,b)) where D is the euclidean distance between superpixels a and b,
%
% source gets connected to every node except sink
%  capacity is with respect to the keyindex superpixel
% sink gets connected to every node except source; 
%  capacity is opposite that of the corresponding source-connection (from each superpixel)
%  in our case, the max capacity on an edge is 3; so, 3 minus corresponding capacity
% 
% superpixels get connected to each other.
%  capacity defined as above.



kfv = segments(keyindex).fv;
kx = segments(keyindex).x;
ky = segments(keyindex).y;

% connect source edges
for i=1:k
    capacity(source,i) = histintersect(kfv,segments(i).fv) * exp(-hypot(kx-segments(i).x,ky-segments(i).y)^2/dnorm);
end

% connect sink edges
for i=1:k
    capacity(i,sink) = 3 - capacity(source,i);
end

% connect internal edges
[a,b] = find(adjacency);
for i = 1:length(a)
    capacity(a(i),b(i)) = 0.25 * ...
                          histintersect(segments(a(i)).fv,segments(b(i)).fv) * ...
                          exp(-hypot(segments(a(i)).x-segments(b(i)).x, ...
                                     segments(a(i)).y-segments(b(i)).y)^2/dnorm);
    
    % we down-weight these capacities, as a function of the
    % average node degree in the graph so that neighborhood connectivity
    % does not overshadow the similarity to the key index.
end

%debug
%figure; imagesc(capacity); title('capacity');

% compute the cut
[~,current_flow] = ff_max_flow(source,sink,capacity,k+2);

% extract the two-class segmentation.
%  the cut will separate all nodes into those connected to the
%   source and those connected to the sink.
%  The current_flow matrix contains the necessary information about
%   the max-flow through the graph.
%
%  Populate the binary matrix B with 1's for those nodes that are connected
%   to the source (and hence are in the same big segment as our keyindex

rc = capacity - current_flow;

% debug 
%figure; imagesc(current_flow); title('current_flow')
%figure; imagesc(current_flow); title('rc')


Q = source;
reachable = zeros(k,1);
while ~isempty(Q)
    Q1 = Q(1);
    Q = Q(2:end);
    paths = find(rc(Q1,1:k)>0);
    % debugging
    %Q1
    %Q
    %paths
    for p=1:length(paths)
       if reachable(paths(p)) ~= 1  % node is not already touched 
           reachable(paths(p)) = 1; % mark it in the reachable set.
           Q = [Q paths(p)];        % add to queue
       end
    end
end
sourceset = find(reachable);

B = zeros(size(segmentimage));
for i = 1:length(sourceset)
    B(segmentimage==sourceset(i)) = 1;
end

end




function c = histintersect(a,b)
    c = sum(min(a,b));
end
