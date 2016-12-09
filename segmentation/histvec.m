function v = histvec(image,mask,b)

% function v = histvec(image,mask,b)
%
%     EECS 504 Foundation of Computer Vision;
%     Jason Corso
%
%  For each channel in the image, compute a b-bin histogram (uniformly space
%  bins in the range 0:1) of the pixels in image where the mask is true. 
%  Then, concatenate the vectors together into one column vector (first
%  channel at top).
%
%  mask is a matrix of booleans the same size as image.
% 
%  normalize the histogram of each channel so that it sums to 1.
%
%  You CAN use the hist function.
%  You MAY loop over the channels.

chan = size(image,3);

c = 1/b;       % bin offset
x = c/2:c:1;   % bin centers

%%%%% IMPLEMENT below this line into a 3*b by 1 vector  v
%%  3*b because we have a color image and you have a separate 
%%  histogram per color channel

e = 0:c:1;     % bin edges
v = zeros(chan, 1);
for i = 1:chan
    imc = image(:, :, i);
    imMask = imc(mask);
    
    v((i-1)*b+1) = sum( imMask <= c );
    for j = 2:b
        v((i-1)*b+j) = sum( imMask > (j-1)*c & imMask <= j*c );
    end
end

v = v / sum(mask(:));
