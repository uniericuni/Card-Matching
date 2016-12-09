function id = segmentation(im)
    imgray = rgb2gray(im);
    diff = 15;
    [x,y] = size(imgray);
    bg1 = zeros(size(imgray));
    bg2 = bg1;
    bg1 = process_background(imgray, imgray(1,1), bg1, diff, 1, 1);
    bg2 = process_background(imgray, imgray(x,y), bg2, diff, x, y);
    bg = bg1 | bg2;
    
    x1 =60;
    y1=275;
    bg1 = process_background(imgray, imgray(x1,y1), bg, diff, x1, y1);
    bg2 = process_background(imgray, imgray(200,50), bg, diff, 200, 50);
    bg = bg1 | bg2;
    bg = imgaussfilt(double(bg),1);
    bg = uint8(double(1-bg).*double(imgray+2))==0;
    bg = process_background(bg, bg(15,200), bg, 1, 15, 200);
%     figure, imagesc(uint8(double(1-bg).*double(imgray+2))==0);
    id = my_segment(uint8(double(1-bg).*double(imgray+2))==0);
end
    
function id = my_segment(bg)
    thr = 500;
    [w,h] = size(bg);
    id = -ones(w,h).*(~bg);

    ids = find(id==-1);
    q = zeros(w*h,2);
    index = 1;
    while ~isempty(ids)
        head = 1;
        tail = 1;
        [x,y] = ind2sub([w,h],ids(1));
        q(head,:) = [x,y]; 
        tail = tail + 1;
        while head ~= tail
            lx = q(head,1);
            ly = q(head,2);
            head = head + 1;
            if id(lx,ly) >= 0
                continue
            end
            id(lx,ly) = index;
            if lx - 1 >= 1 && id(lx-1,ly) == -1
                q(tail,:) = [lx-1, ly];
                tail = tail + 1;
            end
            if lx + 1 <= w && id(lx+1,ly) == -1
                q(tail,:) = [lx+1, ly];
                tail = tail + 1;
            end
            if ly - 1 >= 1 && id(lx,ly-1) == -1
                q(tail,:) = [lx, ly-1];
                tail = tail + 1;
            end
            if ly + 1 <= h && id(lx,ly+1) == -1
                q(tail,:) = [lx, ly+1];
                tail = tail + 1;
            end
        end
        if length(find(id==index)) < thr
            id(id==index) = 0;
            index = index - 1;
        end
        index = index + 1;
        ids = find(id==-1);
    end
end

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
end