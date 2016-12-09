function background = process_background(im, c, ib, diff, x, y)
im = double(im);
c = double(c);
[w,h] = size(im);
q = zeros(w*h*2,2);
q(1,:) = [x,y];
head = 1;
tail = 2;
reached = ib;
background = ib;
while head ~= tail
    lx = q(head,1);
    ly = q(head,2);
%     [head,tail,lx,ly,reached(lx,ly)]
    head = head+1;
    if reached(lx,ly) == 1
        continue
    end
    reached(lx,ly) = 1;
    if abs(c-im(lx,ly)) < diff
        background(lx,ly) = 1;
        if lx - 1 >= 1 && reached(lx-1,ly) == 0
            q(tail,:) = [lx-1, ly];
            tail = tail + 1;
        end
        if lx + 1 <= w && reached(lx+1,ly) == 0
            q(tail,:) = [lx+1, ly];
            tail = tail + 1;
        end
        if ly - 1 >= 1 && reached(lx,ly-1) == 0
            q(tail,:) = [lx, ly-1];
            tail = tail + 1;
        end
        if ly + 1 <= h && reached(lx,ly+1) == 0
            q(tail,:) = [lx, ly+1];
            tail = tail + 1;
        end
    end
end
head