%% Copyright and Disclaimer
% 
% Copyright (c) 2015, Xing Di
% Copyright (c) 2013, Cheggoju Naveen
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
%     * Neither the name of the Stevens Institution of Technology nor the names
%       of its contributors may be used to endorse or promote products derived
%       from this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
% 

%% SIFT
% img: input image
% f_num: expected output feature amount
% mask: RIO
% feature: columns of features
% loc: corresponding coordinate
function [feature,loc]=SIFT(img, f_num, mask)

    %% Initiate image
    fprintf('Initiate image ...\n');
    img=rgb2gray(img);
    if nargin>2
        img=img+uint8(~mask).*255;
    end
    img=im2double(img);
    [row,column]=size(img);
    origin=img;

    %% DoG Pyramid / Scalespace Extrema
    % building DoG pyramid
    % sigma: gaussian parameter
    % level: pyramid level
    % octave: sampling level

    % init process
    fprintf('Building DoG pyramid ...\n');
    sigma0=sqrt(2);
    octave=3;
    level=3;
    D=cell(1,octave);
    for i=1:octave
        D(i)=mat2cell(zeros(row*2^(2-i)+2,column*2^(2-i)+2,level),row*2^(2-i)+2,column*2^(2-i)+2,level);
    end
    
    % first image in first octave is created by interpolating the original one.
    temp_img=kron(img,ones(2));
    temp_img=padarray(temp_img,[1,1],'replicate');
    % figure(2);
    % subplot(2,2,1);
    % imshow(origin);
    % title('original image');
    
    %create the DoG pyramid.
    for i=1:octave
        temp_D=D{i};
        for j=1:level
            scale=sigma0*sqrt(2)^(1/level)^((i-1)*level+j);
            p=(level)*(i-1);
            % figure(1);
            % h = gcf;
            % mtit(h,'DoG Pyramid');
            % subplot(octave,level,p+j);
            f=fspecial('gaussian',[1,floor(6*scale)],scale);
            L1=temp_img;
            if(i==1&&j==1)
                L2=conv2(temp_img,f,'same');
                L2=conv2(L2,f','same');
                temp_D(:,:,j)=L2-L1;
                % imshow(uint8(255 * mat2gray(temp_D(:,:,j))));
                L1=L2;
            else
                L2=conv2(temp_img,f,'same');
                L2=conv2(L2,f','same');
                temp_D(:,:,j)=L2-L1;
                L1=L2;
                if(j==level)
                    temp_img=L1(2:end-1,2:end-1);
                end
                % imshow(uint8(255 * mat2gray(temp_D(:,:,j))));
            end
        end
        D{i}=temp_D;
        temp_img=temp_img(1:2:end,1:2:end);
        temp_img=padarray(temp_img,[1,1],'both','replicate');
    end
    
    %% Local extrema / Keypoint Localization
    % search each pixel in the DoG map to find the extrema point
    % extrema: local extrema in DOG pyramid
    
    fprintf('Search for local extrema ...\n');
    interval=level-1;
    number=0;
    for i=2:octave+1
        number=number+(2^(i-octave)*column)*(2*row)*interval;
    end
    extrema=zeros(1,4*number);
    flag=1;
    for i=1:octave
        [m,n,~]=size(D{i});
        m=m-2;
        n=n-2;
        volume=m*n/(4^(i-1));
        for k=2:interval      
            for j=1:volume
                x=ceil(j/n);
                y=mod(j-1,m)+1;
                sub=D{i}(x:x+2,y:y+2,k-1:k+1);
                large=max(max(max(sub)));
                little=min(min(min(sub)));
                if(large==D{i}(x+1,y+1,k))
                    temp=[i,k,j,1];
                    extrema(flag:(flag+3))=temp;
                    flag=flag+4;
                end
                if(little==D{i}(x+1,y+1,k))
                    temp=[i,k,j,-1];
                    extrema(flag:(flag+3))=temp;
                    flag=flag+4;
                end
            end
        end
    end
    idx= extrema==0;
    extrema(idx)=[];
    [m,n]=size(img);
    x=floor((extrema(3:4:end)-1)./(n./(2.^(extrema(1:4:end)-2))))+1;
    y=mod((extrema(3:4:end)-1),m./(2.^(extrema(1:4:end)-2)))+1;
    ry=y./2.^(octave-1-extrema(1:4:end));
    rx=x./2.^(octave-1-extrema(1:4:end));
    % figure(2);
    % subplot(2,2,2);
    % imshow(origin);
    % hold on
    % plot(ry,rx,'r+');
    % title('labeled with local extrema');
    
    %% Keypoint thresholding / Accurate Keypoint Localization
    % eliminate the point with low contrast or poorly localized on an edge
    % x:|,y:-- x is for vertial and y is for horizontal
    % value comes from the paper.
    
    fprintf('Threshold keypoint ...\n');
    threshold=0.1;
    r=10;
    extr_volume=length(extrema)/4;
    [m,n]=size(img);
    secondorder_x=conv2([-1,1;-1,1],[-1,1;-1,1]);
    secondorder_y=conv2([-1,-1;1,1],[-1,-1;1,1]);
    for i=1:octave
        for j=1:level
            test=D{i}(:,:,j);
            temp=-1./conv2(test,secondorder_y,'same').*conv2(test,[-1,-1;1,1],'same');
            D{i}(:,:,j)=temp.*conv2(test',[-1,-1;1,1],'same')*0.5+test;
        end
    end
    
    % threshold on small contrast
    for i=1:extr_volume
        x=floor((extrema(4*(i-1)+3)-1)/(n/(2^(extrema(4*(i-1)+1)-2))))+1;
        y=mod((extrema(4*(i-1)+3)-1),m/(2^(extrema(4*(i-1)+1)-2)))+1;
        rx=x+1;
        ry=y+1;
        rz=extrema(4*(i-1)+2);
        z=D{extrema(4*(i-1)+1)}(rx,ry,rz);
        if(abs(z)<threshold)
            extrema(4*(i-1)+4)=0;
        end
    end
    idx=find(extrema==0);
    idx=[idx,idx-1,idx-2,idx-3];
    extrema(idx)=[];
    extr_volume=length(extrema)/4;
    x=floor((extrema(3:4:end)-1)./(n./(2.^(extrema(1:4:end)-2))))+1;
    y=mod((extrema(3:4:end)-1),m./(2.^(extrema(1:4:end)-2)))+1;
    ry=y./2.^(octave-1-extrema(1:4:end));
    rx=x./2.^(octave-1-extrema(1:4:end));
    % figure(2)
    % subplot(2,2,3);
    % imshow(origin);
    % hold on
    % plot(ry,rx,'g+');
    % title('accurate keypoints 1');
    
    % threshold on localization
    for i=1:extr_volume
        x=floor((extrema(4*(i-1)+3)-1)/(n/(2^(extrema(4*(i-1)+1)-2))))+1;
        y=mod((extrema(4*(i-1)+3)-1),m/(2^(extrema(4*(i-1)+1)-2)))+1;
        rx=x+1;
        ry=y+1;
        rz=extrema(4*(i-1)+2);
        Dxx=D{extrema(4*(i-1)+1)}(rx-1,ry,rz)+D{extrema(4*(i-1)+1)}(rx+1,ry,rz)-2*D{extrema(4*(i-1)+1)}(rx,ry,rz);
        Dyy=D{extrema(4*(i-1)+1)}(rx,ry-1,rz)+D{extrema(4*(i-1)+1)}(rx,ry+1,rz)-2*D{extrema(4*(i-1)+1)}(rx,ry,rz);
        Dxy=D{extrema(4*(i-1)+1)}(rx-1,ry-1,rz)+D{extrema(4*(i-1)+1)}(rx+1,ry+1,rz)-D{extrema(4*(i-1)+1)}(rx-1,ry+1,rz)-D{extrema(4*(i-1)+1)}(rx+1,ry-1,rz);
        deter=Dxx*Dyy-Dxy*Dxy;
        
        % Harris operator
        iter=4*(i-1)+4;
        R(i)=(Dxx+Dyy)/deter; 
        R_threshold=(r+1)^2/r;
        if(deter<0||R(i)>R_threshold)
            extrema(iter)=0;
            R(i)=inf;
        end
    end
    
    % top f_num features
    if nargin>1
        [num,idx]=sort(R);
        iter=4.*(idx(f_num+1:end)-1)+4;
        extrema(iter)=0;
    end
    
    % accuration
    idx=find(extrema==0);
    idx=[idx,idx-1,idx-2,idx-3];
    extrema(idx)=[];
    extr_volume=length(extrema)/4;
    x=floor((extrema(3:4:end)-1)./(n./(2.^(extrema(1:4:end)-2))))+1;
    y=mod((extrema(3:4:end)-1),m./(2.^(extrema(1:4:end)-2)))+1;
    ry=y./2.^(octave-1-extrema(1:4:end));
    rx=x./2.^(octave-1-extrema(1:4:end));
    % figure(2)
    % subplot(2,2,4);
    % imshow(origin);
    % hold on
    % plot(ry,rx,'b+');
    % title('accurate keypoints 2');
    
    %% Orientation Assignment
    
    fprintf('Search for dominant orientation ...\n');
    kpori=zeros(1,36*extr_volume);
    minor=zeros(1,36*extr_volume);
    f=1;
    flag=1;
    for i=1:extr_volume
        % search in the certain scale
        scale=sigma0*sqrt(2)^(1/level)^((extrema(4*(i-1)+1)-1)*level+(extrema(4*(i-1)+2)));
        width=2*round(3*1.5*scale);
        count=1;
        x=floor((extrema(4*(i-1)+3)-1)/(n/(2^(extrema(4*(i-1)+1)-2))))+1;
        y=mod((extrema(4*(i-1)+3)-1),m/(2^(extrema(4*(i-1)+1)-2)))+1;
        
        % make sure the point in the searchable area
        if(x>(width/2)&&y>(width/2)&&x<(m/2^(extrema(4*(i-1)+1)-2)-width/2-2)&&y<(n/2^(extrema(4*(i-1)+1)-2)-width/2-2))
            rx=x+1;
            ry=y+1;
            rz=extrema(4*(i-1)+2);
            reg_volume=width*width;
            weight=fspecial('gaussian',width,1.5*scale);
            reg_mag=zeros(1,count);
            reg_theta=zeros(1,count);
            for l=(rx-width/2):(rx+width/2-1)
                for k=(ry-width/2):(ry+width/2-1)
                    reg_mag(count)=sqrt((D{extrema(4*(i-1)+1)}(l+1,k,rz)-D{extrema(4*(i-1)+1)}(l-1,k,rz))^2+(D{extrema(4*(i-1)+1)}(l,k+1,rz)-D{extrema(4*(i-1)+1)}(l,k-1,rz))^2);
                    reg_theta(count)=atan2((D{extrema(4*(i-1)+1)}(l,k+1,rz)-D{extrema(4*(i-1)+1)}(l,k-1,rz)),(D{extrema(4*(i-1)+1)}(l+1,k,rz)-D{extrema(4*(i-1)+1)}(l-1,k,rz)))*(180/pi);
                    count=count+1;
                end
            end
            
            % create histogram
            mag_counts=zeros(1,36);
            for x=0:10:359
                mag_count=0;
                for j=1:reg_volume
                    c1=-180+x;
                    c2=-171+x;
                    if(c1<0||c2<0)
                        if(abs(reg_theta(j))<abs(c1)&&abs(reg_theta(j))>=abs(c2))
                            mag_count=mag_count+reg_mag(j)*weight(ceil(j/width),mod(j-1,width)+1);
                        end
                    else
                        if(abs(reg_theta(j)>abs(c1)&&abs(reg_theta(j)<=abs(c2))))
                            mag_count=mag_count+reg_mag(j)*weight(ceil(j/width),mod(j-1,width)+1);
                        end
                    end
                end
                mag_counts(x/10+1)=mag_count;
            end
            
            % find the max histogram bar and the ones higher than feature_percentage
            [maxvm,~]=max(mag_counts);
            feature_percentage = 0.8;
            kori=find(mag_counts>=(feature_percentage*maxvm));
            kori=(kori*10+(kori-1)*10)./2-180;
            kpori(f:(f+length(kori)-1))=kori;
            f=f+length(kori);
            temp_extrema=[extrema(4*(i-1)+1),extrema(4*(i-1)+2),extrema(4*(i-1)+3),extrema(4*(i-1)+4)];
            temp_extrema=padarray(temp_extrema,[0,length(temp_extrema)*(length(kori)-1)],'post','circular');
            long=length(temp_extrema);
            minor(flag:flag+long-1)=temp_extrema;
            flag=flag+long;
        end
    end
    idx= minor==0;
    minor(idx)=[];
    extrema=minor;
    idx= kpori==0;
    kpori(idx)=[];
    extr_volume=length(extrema)/4;
    
    %% Feature descriptor
    
    fprintf('Build descriptor ...\n');
    d=4; % In David G. Lowe experiment,divide the area into 4*4.
    pixel=4;
    feature=zeros(d*d*8,extr_volume);
    
    loc=zeros(2,extr_volume);
    for i=1:extr_volume
        descriptor=zeros(1,d*d*8);% feature dimension is 128=4*4*8;
        width=d*pixel;
        % x,y centeral point and prepare for location rotation
        x=floor((extrema(4*(i-1)+3)-1)/(n/(2^(extrema(4*(i-1)+1)-2))))+1;
        y=mod((extrema(4*(i-1)+3)-1),m/(2^(extrema(4*(i-1)+1)-2)))+1;
        loc(:,i)=[x;y];
        z=extrema(4*(i-1)+2);
        if((m/2^(extrema(4*(i-1)+1)-2)-pixel*d*sqrt(2)/2)>x&&x>(pixel*d/2*sqrt(2))&&(n/2^(extrema(4*(i-1)+1)-2)-pixel*d/2*sqrt(2))>y&&y>(pixel*d/2*sqrt(2)))
            sub_x=(x-d*pixel/2+1):(x+d*pixel/2);
            sub_y=(y-d*pixel/2+1):(y+d*pixel/2);
            sub=zeros(2,length(sub_x)*length(sub_y));
            j=1;
            for p=1:length(sub_x)
                for q=1:length(sub_y)
                    sub(:,j)=[sub_x(p)-x;sub_y(q)-y];
                    j=j+1;
                end
            end
            distort=[cos(pi*kpori(i)/180),-sin(pi*kpori(i)/180);sin(pi*kpori(i)/180),cos(pi*kpori(i)/180)];
            
            % accordinate after distort
            sub_dis=distort*sub;
            fix_sub=ceil(sub_dis);
            fix_sub=[fix_sub(1,:)+x;fix_sub(2,:)+y];
            patch=zeros(1,width*width);
            for p=1:length(fix_sub)
                patch(p)=D{extrema(4*(i-1)+1)}(fix_sub(1,p),fix_sub(2,p),z);
            end
            temp_D=(reshape(patch,[width,width]))';
            
            % create weight matrix.
            mag_sub=temp_D;        
            temp_D=padarray(temp_D,[1,1],'replicate','both');
            weight=fspecial('gaussian',width,width/1.5);
            mag_sub=weight.*mag_sub;
            theta_sub=atan((temp_D(2:end-1,3:1:end)-temp_D(2:end-1,1:1:end-2))./(temp_D(3:1:end,2:1:end-1)-temp_D(1:1:end-2,2:1:end-1)))*(180/pi);
            
            % create orientation histogram
            for area=1:d*d
                cover=pixel*pixel;
                ori=zeros(1,cover);
                magcounts=zeros(1,8);
                for angle=0:45:359
                    magcount=0;
                    for p=1:cover;
                        x=(floor((p-1)/pixel)+1)+pixel*floor((area-1)/d);
                        y=mod(p-1,pixel)+1+pixel*(mod(area-1,d));
                        c1=-180+angle;
                        c2=-180+45+angle;
                        if(c1<0||c2<0)
                            if (abs(theta_sub(x,y))<abs(c1)&&abs(theta_sub(x,y))>=abs(c2))
                              ori(p)=(c1+c2)/2;
                              magcount=magcount+mag_sub(x,y);
                            end
                        else
                            if(abs(theta_sub(x,y))>abs(c1)&&abs(theta_sub(x,y))<=abs(c2))
                                ori(p)=(c1+c2)/2;
                                magcount=magcount+mag_sub(x,y);
                            end
                        end              
                    end
                    magcounts(angle/45+1)=magcount;
                end
                descriptor((area-1)*8+1:area*8)=magcounts;
            end
            descriptor = descriptor./norm(descriptor);
                
            % cap 0.2
            for j=1:numel(descriptor)
                if(abs(descriptor(j))>0.2)
                    descriptor(j)=0.2;        
                end
            end
            descriptor = descriptor./norm(descriptor);
        else
            continue;
        end
        feature(:,i)=descriptor';
    end
    index=find(sum(feature));
    feature=feature(:,index);
    loc=loc./2;
 
end
