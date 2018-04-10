


InputVideo = VideoReader('challenge_video.mp4');
VidObj =VideoWriter('Challenge_Output');
open(VidObj);
pxmin = 1200;
pymin = 1200;
pxmax = 0;
pymax = 0;
nxmin = 1200;
nymin = 1200;
nxmax = 0;
nymax = 0;

while hasFrame(InputVideo)
    
    
% end
    InputImage = readFrame(InputVideo);
    grayed = rgb2gray(InputImage);
    EqualizedImage = histeq(grayed);
% [rows,columns] = size(EqualizedImage);
%     imshow(EqualizedImage);

% figure;
% imshowpair(grayed, EqualizedImage,'montage');

% figure;imhist(grayed);
% figure;imhist(EqualizedImage);
[counts,x] = imhist(EqualizedImage,16);
 T = adaptthresh(EqualizedImage,0.2);
 binarized = imbinarize(EqualizedImage,T);
 % %% %%%%%%%% Create a trapezoidal mask and replace the below command with it. %
 X = [715 490 170 1032 868 815];
 Y = [402 507 675 686 498 419];
 roi = poly2mask(X,Y,720,1280);
 newbinarized = binarized.*roi;
 fillednewbinarized = bwareaopen(newbinarized,5);
 xfillednewbinarized = bwareafilt(fillednewbinarized,[15,10000]);
 edged = edge(xfillednewbinarized,'Canny','Vertical');
 
 se = strel('line',2.415,135);
 dilated = imdilate(edged,se);
 imshow(edged);
 
 [H,T,R] = hough(dilated);
P  = houghpeaks(H,15,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(dilated,T,R,P,'FillGap',5,'MinLength',7);


imshow(xfillednewbinarized); hold on
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   slope(k) = (xy(2,2)-xy(1,2))/(xy(2,1)-xy(1,1));
   
%    drawnow
%    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 
%    % Plot beginnings and ends of lines
%    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
%    
   slope(k) = (xy(2,2)-xy(1,2))/(xy(2,1)-xy(1,1));
%    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
% 
%    % Plot beginnings and ends of lines
%    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
%    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
     
   if slope(k)>0
%        posSlope = [posSlope, slope(k)];
%        psum = psum + slope(k);
       for z = 1:length(xy)
           if xy(z,2)<pymin
               pymin = xy(z,2);
               pxmin = xy(z,1);
           end
           if xy(z,2)>pymax
               pymax = xy(z,2);
               pxmax = xy(z,1); 
           end
       end
       
%        if xy(1,2)>300
%            px1 = xy(1,1);
%            py1 = xy(1,2);
%        end
%        if xy(:,2)<500
%            pturnSlope = [pturnSlope,slope(k)];
%            pturnsum = pturnsum + slope(k);
%        end    
   else
%        negSlope = [negSlope, slope(k)];
%        nsum = nsum + slope(k);
       for z = 1:length(xy)
           if xy(z,2)<nymin
               nymin = xy(z,2);
               nxmax = xy(z,1);
           end
           if xy(z,2)>nymax
               nymax = xy(z,2);
               nxmin = xy(z,1);
           end
%        if xy(2:2)>500
%            nx1 = xy(1,1);
%            ny1 = xy(1,2);
%        end
%        if xy(2,2)<500
%            nturnSlope = [nturnSlope,slope(k)];
%            nturnsum = nturnsum +slope(k);
%        end
       end
   
   end
    
   
end

% 
% drawnow
%  plot([nxmin nxmax],[nymax nymin],'LineWidth',4,'Color','red');
% 
%  plot([pxmin pxmax],[pymin pymax],'LineWidth',4,'Color','red');
%  hold off

 frame = getframe;
 imaged = frame2im(frame);
 writeVideo(VidObj,imaged);
end

close(VidObj);
