%Process with video 
%a = VideoReader('video-2.mp4');
%{
for img = 1:a.NumberOfFrames;
    filename=strcat('frame',num2str(img),'.jpg');
    b = read(a, img);
    imshow(b);
    imwrite(b,filename);
end
%}
%Uncomment this out for video processing
%vidObj = VideoReader('yourvideo.avi');
%for img = 1:vidObj.NumberOfFrames;
   % filename=strcat('frame',num2str(img),'.jpg');
  %  I = read(a, img);
 %-------------------------------------------------
  I = imread('runway2.png');
 % runway2.png
 % runway3.png
 % runwaymain.png
 %-------------------------------------------------
    
    %Adds noise to picture to imitate bad weather
    x_noisy=imnoise(I,'gaussian',0,0.02);
    
    %change I to x_noisy to add noise. 
    IG=rgb2gray(I);
    %add back in to combat x_noisy
    %IG = wiener2(IG,[10 10]);

    BWChange = imbinarize(IG);
    Icorrected = imtophat(IG,strel('disk',15));
    BW1 = imbinarize(Icorrected);
    
    marker = imerode(Icorrected, strel('line',6,0));
    Iclean = imreconstruct(marker, Icorrected);
    BW2 = imbinarize(Iclean);
    
    results = ocr(BW2,'TextLayout','Block');
    
    results.Text
    
    % The regular expression, '\d', matches the location of any digit in the
    % recognized text and ignores all non-digit characters.
    regularExpr = '\d';
    
    % Get bounding boxes around text that matches the regular expression
    bboxes = locateText(results,regularExpr,'UseRegexp',true);
    
    digits = regexp(results.Text,regularExpr,'match');
    if(length(digits) ~= 0)
    % draw boxes around the digits
    Idigits = insertObjectAnnotation(IG,'rectangle',bboxes,digits);
    end
    %Change to IG for approch one
    %Change to BW1 for approch two
    BW = edge(BW1,'Roberts');
    [H,T,R] = hough(BW,'Theta',-80:0.1:80);
%{
    figure
    imshow(imadjust(rescale(H)),[],...
        'XData',T,...
        'YData',R,...
        'InitialMagnification','fit');
    xlabel('\theta (degrees)')
    ylabel('\rho')
    axis on
    axis normal 
    hold on
    colormap(gca,hot)
%}
    %Gets HoughPeaks
    P  = houghpeaks(H,5,'threshold',ceil(0.6*max(H(:))));
    %Gets lines
    lines = houghlines(BW,T,R,P,'FillGap',5,'MinLength',7);
    figure, imshow(I),
    %Uncomment out to add the number values 
    %imshow(Idigits),
    hold on
    [rows, columns]=size(I);
    max_len = 0;

    [HHozr,THozr,RHozr] = hough(BW,'Theta',79:0.1:89);

    PHozr = houghpeaks(HHozr,5,'threshold',ceil(0.85*max(HHozr(:))),'NHoodSize',[95 95]);

    linesHozr = houghlines(BW,THozr,RHozr,PHozr,'FillGap',100,'MinLength',1);
    %figure, imshow(I), hold on
    [rowsHozr, columnsHozr]=size(I);
    max_lenHozr = 0;

    items = [];
    totalvalue = [];
    %Adds points to an array.
    for k = 1 : length(lines)
        xy = [1:1];
        xy = [lines(k).point1; lines(k).point2;];
        items = [items; xy];
    end
            %X          Y
    %plot([228 291],[152,153],'LineWidth',2,'Color','green');
    
    %{
    p1 = [228,152]
    squaredDistance = sum((items-repmat(p1', [1, size(items, 2)])).^2, 1)
    [maxSqDist1, indexOfMax1] = max(squaredDistance)
    %}
    %Array of storing the four points
    storeFourPoints = [];
    %Getting the smallest value
    smallestval = 0;
    %Getting the largest value
    largestval = 0;
    %Counter for finding each point. 
    counter = 0;
    %Finding the four points 
    findingPoints(items,smallestval,counter,storeFourPoints,largestval);
    
    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];

        % Plot beginnings and ends of lines
        plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
        plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','yellow');

        %plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
   
        % Determine the endpoints of the longest line segment
        %len = norm(lines(k).point1 - lines(k).point2);
        %if ( len > max_len)
        %    max_len = len;
         %   xy_long = xy;
        %end
    end

%   x1 = xy_long(1,1);
%   y1 = xy_long(1,2);
%   x2 = xy_long(2,1);
%   y2 = xy_long(2,2);
  
   %slope = 0;
  % xLeft = 1;
  % yLeft = slope * (xLeft - x1) + y1;
  % xRight = columns;
  % yRight = slope * (xRight - x1) + y1;
  % plot([xLeft, xRight], [yLeft, yRight], 'LineWidth',1,'Color','green');
   
    for k = 1:length(lines)
        xy = [lines(k).point1; lines(k).point2];
   
        numOfElems = max(max(xy(:,1))-min(xy(:,1)),max(xy(:,2))-min(xy(:,2)) ) ;
        if (diff(xy(:,1)) == 0)           
            y = round(linspace(min(xy(:,2)),max(xy(:,2)),numOfElems));
            x = round(linspace(min(xy(:,1)),max(xy(:,1)),numOfElems));  
        else
            k = diff(xy(:,2)) ./ diff(xy(:,1)); % // the slope
            m = xy(1,2) - k.*xy(1,1); % // The crossing of the y-axis

            x = round(linspace(min(xy(:,1)), max(xy(:,1)), numOfElems));
            y = round(k.*x + m); % // the equation of a line
        end
        % Get the equation of the line
  
  
        x1 = xy(1,1);
        y1 = xy(1,2);
        x2 = xy(2,1);
        y2 = xy(2,2);
        
        slope = (y2-y1)/(x2-x1);
        xLeft = 1;
        yLeft = slope * (xLeft - x1) + y1;
        xRight = columns;
        yRight = slope * (xRight - x1) + y1;
        %Uncomment this out for approch one 
        %plot([xLeft, xRight], [yLeft, yRight], 'LineWidth',1,'Color','green');
        
        
        %plot(x1,y1,'x','LineWidth',2,'Color','yellow');
        %plot(x2,y2,'x','LineWidth',2,'Color','red');
    end

    for k = 1:length(linesHozr)
        xy = [linesHozr(k).point1; linesHozr(k).point2];
   
        numOfElems = max(max(xy(:,1))-min(xy(:,1)),max(xy(:,2))-min(xy(:,2)) ) ;
        if (diff(xy(:,1)) == 0)           
            y = round(linspace(min(xy(:,2)),max(xy(:,2)),numOfElems));
            x = round(linspace(min(xy(:,1)),max(xy(:,1)),numOfElems));  
        else
            k = diff(xy(:,2)) ./ diff(xy(:,1)); % // the slope
            m = xy(1,2) - k.*xy(1,1); % // The crossing of the y-axis

            x = round(linspace(min(xy(:,1)), max(xy(:,1)), numOfElems));
            y = round(k.*x + m); % // the equation of a line
        end
        % Get the equation of the line
        x1 = xy(1,1);
        y1 = xy(1,2);
        x2 = xy(2,1);
        y2 = xy(2,2);
        slope = (y2-y1)/(x2-x1);
        xLeft = 1;
        yLeft = slope * (xLeft - x1) + y1;
        xRight = columnsHozr;
        yRight = slope * (xRight - x1) + y1;
        %Uncomment this out for approch one 
        %plot([xLeft, xRight], [yLeft, yRight], 'LineWidth',1,'Color','green');
    end
    %Uncomment this out for approch one 
    %processed_image(y,x) = 0; % // delete the line
%end

function findingPoints(items,smallestval,counter,storeFourPoints,largestval)
    for k = 1: length(items)
        %Get point 1 in the array
        item11 = items(k,1);
        %Get point 2 in the array
        item12 = items(k,2);
        %Check if value is already added to the storeFourPoints array
        storeCheck = 0;
        %Loop through each storeFourPoints to see if point is added already
        for a = 1: size(storeFourPoints)
           if(item11 == storeFourPoints(a,1))
               %Change value to 1 if added already
               storeCheck = 1;
               break
           end
        end
        %checks if value is 0.
        if(storeCheck == 0)
            itemonearray = item11 * item12;
            if(smallestval == 0)
                smallestval = itemonearray;
                largestval = itemonearray;
            end
            if(itemonearray < smallestval)
                smallestval = itemonearray;
            end
            if(itemonearray > largestval)
                largestval = itemonearray;
            end 
        end
    end
    %Add one to counter to make sure it does not go over 4 looks for only
    %four points
    counter=counter+1;
    if(counter <= 4)
        % Find each point 
        findEachPoint(items,smallestval,counter,storeFourPoints,largestval)
    else
        %Get each value from the returned points
        value1 = storeFourPoints(1,:);
        value2 = storeFourPoints(2,:);
        value3 = storeFourPoints(3,:);
        value4 = storeFourPoints(4,:);
        %Polygon for each point.
        pgon = polyshape([value2(1) value1(1) value3(1) value4(1)],[value2(2),value1(2) value3(2) value4(2)]);
        %Comment this out for approch two 
        h = plot(pgon,'FaceColor','green');
        h.LineStyle = '-';
        h.LineWidth = 1;
        h.EdgeColor = 'red';
    end
end

function findEachPoint(items,smallestval,counter,storeFourPoints,largestval)
   for k = 1: length(items)
        storeCheck = 0;
        item11 = items(k,1);
        item12 = items(k,2);
        %Make 2d array in to 1d. 
        itemonearray = item11 * item12;
        %Gets 3 smallest values
        if(smallestval == itemonearray && counter <= 3)
            for a = 1: size(storeFourPoints)
                if(item11 == storeFourPoints(a,1))
                    storeCheck = 1;
                    break
                end
            end
            if(storeCheck == 0)
                xy = [item11 item12;];
                storeFourPoints = [storeFourPoints; xy];
                smallestval = 0;
                findingPoints(items,smallestval,counter,storeFourPoints,largestval);
                break
            end
        end
        %Gets largest values
        if(largestval == itemonearray)
            for a = 1: size(storeFourPoints)
                if(item11 == storeFourPoints(a,1))
                    storeCheck = 1;
                    break
                end
            end
            if(storeCheck == 0)
                xy = [item11 item12;];
                storeFourPoints = [storeFourPoints; xy];
                largestval = 0;
                findingPoints(items,smallestval,counter,storeFourPoints,largestval);
                break
            end
        end
   end
end


%K Nearest Neighbors example 
%{
P = gallery('uniformdata',[10 2],0);
disp(P);
PQ = [0.5 0.5; 0.1 0.7; 0.8 0.7; 0.5 0.5;0.5 0.5;0.5 0.5;0.5 0.5;0.5 0.5;0.5 0.5;0.5 0.5;];
disp('TEstasdlajsd;ojas;odf');
disp(PQ)

[k,dist] = dsearchn(P,PQ);

plot(P(:,1),P(:,2),'ko')
hold on
plot(PQ(:,1),PQ(:,2),'*g')
hold on
plot(P(k,1),P(k,2),'*r')
plot([PQ(:,1),PQ(:,2)], [P(k,1),P(k,2)], 'LineWidth',1,'Color','green');
legend('Data Points','Query Points','Nearest Points','Location','sw')
%}