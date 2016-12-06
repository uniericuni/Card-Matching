function C = harris(dx,dy,Whalfsize)

% function C = harris(dx,dy,Whalfsize)
%
%     EECS Foundation of Computer Vision;
%     Jason Corso
%
%   I is the image (GRAY, DOUBLE)
%   or
%   dx is the horizontal gradient image
%   dy is the vertical gradient image
%
%   If you call it with the Image I, then you need set parameter dy to []
%
%   Whalfsize is the half size of the window.  Wsize = 2*Whalfsize+1
%
%   Corner strength is taken as min(eig) and not the det(T)/trace(T) as in
%   the original harris method.  Just for simplicity
%
%  output
%   C is an image (same size as dx and dy) where every pixel contains the
%   corner strength.  


if (isempty(dy))
   im = dx;
   dy = conv2(im,fspecial('sobel'),'same');
   dx = conv2(im,fspecial('sobel')','same'); 
end


%%%%%%%%% fill in below
% Corner strength is to be taken as min(eig) and not the det(T)/trace(T) as in
%  the original harris method.

length = 2*Whalfsize+1;
box = ones(length, length);
xx = conv2(dx.*dx, box, 'same');
xy = conv2(dx.*dy, box, 'same');
yy = conv2(dy.*dy, box, 'same');
% formula solution for eigen of 2x2 matrix
T = xx+yy;
D = xx.*yy-xy.*xy;
C = (T-sqrt(T.*T-4.*D))./2;
C = abs(C);

%%%%%%%% done
