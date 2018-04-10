%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ENPM 673 Perception For Autonomous Robotics

% Project 1 - Spring 2018
% To detect Lanes from the given Video - 80 points
% To predict turns - 20 points
% To detected curved Lanes in Challenge Video - 50 points
% 
% Code By: Mayank Pathak
%          115555037
%
% Dependencies: This code doesn't uses any functions of this file,
%               therefore NO dependencies.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

InputVideo = VideoReader('../Input/project_video.mp4')
VidObj =VideoWriter('Project_Output','MPEG-4');
VidObj.FrameRate = 20;
open(VidObj);
xintersept = 0;
while hasFrame(InputVideo)
    InputImage = readFrame(InputVideo);
    grayed = rgb2gray(InputImage);
    EqualizedImage = histeq(grayed);
    [rows,columns] = size(EqualizedImage);

binarized = imbinarize(EqualizedImage,0.99);
%%%%%%%% Create a trapezoidal mask and replace the below command with it. %
X = [ 546 534 221 1157 1007 702 ];
Y = [ 425 473 700 702 557 427 ];
roied = poly2mask(X,Y,720,1280);
newbinarized = binarized.*roied;

edged_Canny = edge(newbinarized,'Canny','vertical');       %edged using Roberts method
se = strel('line',2.415,135);
dilated = imdilate(edged_Canny,se);

[H,T,R] = hough(edged_Canny);
P  = houghpeaks(H,5,'threshold',ceil(0.3*max(H(:))));
lines = houghlines(dilated,T,R,P,'FillGap',5,'MinLength',7);

posSlope = [];
pturnSlope = [];
negSlope = [];
nturnSlope = [];
psum = 0;
nsum = 0;
pturnsum = 0;
nturnsum = 0;
imshow(InputImage); hold on
for k = 1:length(lines)
   xy = [lines(k).point1; lines(k).point2];
   slope(k) = (xy(2,2)-xy(1,2))/(xy(2,1)-xy(1,1));
     
   if slope(k)>0
       posSlope = [posSlope, slope(k)];
       psum = psum + slope(k);
       for z = 1:length(xy)
           if xy(z,1)<pxmin
               pxmin = xy(z,1);
           end
           if xy(z,1)>pxmax
               pxmax = xy(z,1);
           end
           if xy(z,2)<pymin
               pymin = xy(z,2);
           end
           if xy(z,2)>pymax
               pymax = xy(z,2);
           end
       end
       
       if xy(1:2)>300
           px1 = xy(1,1);
           py1 = xy(1,2);
       end
       if xy(:,2)<500
           pturnSlope = [pturnSlope,slope(k)];
           pturnsum = pturnsum + slope(k);
       end    
   else
       negSlope = [negSlope, slope(k)];
       nsum = nsum + slope(k);
      for z = 1:length(xy)
           if xy(z,1)<nxmin
               nxmin = xy(z,1);
           end
           if xy(z,1)>nxmax
               nxmax = xy(z,1);
           end
           if xy(z,2)<nymin
               nymin = xy(z,2);
           end
           if xy(z,2)>nymax
               nymax = xy(z,2);
           end
       end
       if xy(2:2)>500
           nx1 = xy(1,1);
           ny1 = xy(1,2);
       end
       if xy(2,2)<500
           nturnSlope = [nturnSlope,slope(k)];
           nturnsum = nturnsum +slope(k);
       end
   end
   
end

pmeanSlope = psum/length(posSlope);
nmeanSlope = nsum/length(negSlope);
pturnmean = pturnsum/length(pturnSlope);
nturnmean = nturnsum/length(nturnSlope);


Lx1 = round(((480-ny1)/nmeanSlope)+nx1);
Lx2 = round(((650-ny1)/nmeanSlope)+nx1);
Rx1 = round(((650-py1)/pmeanSlope)+px1);
Rx2 = round(((480-py1)/pmeanSlope)+px1);
drawnow
v = [Lx1 480; Lx2 650; Rx1 650; Rx2 480];
f = [1 2 3 4];
patch('Faces',f,'Vertices',v,'EdgeColor','red','FaceColor','red','FaceAlpha',0.2,'EdgeAlpha',0.2);

% Calculating b for 1st line 

bleft = 480/(nmeanSlope*Lx1);
bright = 480/(pmeanSlope*Rx2);

xintersept = round(bright -bleft/(nmeanSlope - pmeanSlope));
yintersept = round(nmeanSlope*xintersept+bleft);

uppermid = (Lx1+Rx2)/2;
lowermid = (Lx2+Rx1)/2;

str1 = [string(uppermid)];
str2 = [string(lowermid)];


if lowermid - uppermid > 60
        t = text(590,570,'Left Turn Ahead','Color','blue','FontSize',15);
elseif any(lowermid- uppermid <40)
        t = text(590,570,'Straight Road Ahead','Color','green','FontSize',15);
end

frame = getframe();
img = frame2im(frame);
writeVideo(VidObj,img);
hold off
end

 close(VidObj);

   
   
   