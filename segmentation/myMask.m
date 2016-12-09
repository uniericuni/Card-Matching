classdef myMask < handle
	properties
		mask;
        reached;
	end
	methods
		function h = myMask(data)
		  h.mask = data	;
          h.reached = zeros(size(data));
		end
	end
end