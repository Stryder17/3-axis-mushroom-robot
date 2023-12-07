clc;
clear;
clear('cam');

cam = webcam('CyberTrack H4');

while true
    RGB = snapshot(cam);
    figure(1)
    imshow(RGB) % Original image
    
    % Convert RGB image to HSV color space
    I = rgb2hsv(RGB);
    
    % Define thresholds for white color in HSV space
    channel1Min = 0;   % Hue (range from 0 to 1)
    channel1Max = 1;
    
    channel2Min = 0;   % Saturation (range from 0 to 1)
    channel2Max = 0.1;
    
    channel3Min = 0.9; % Value (range from 0 to 1)
    channel3Max = 1;
    
    % Create mask based on chosen histogram thresholds
    whiteMask = ( (I(:,:,1) >= channel1Min) & (I(:,:,1) <= channel1Max) ) & ...
                (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
                (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
    
    % Initialize output masked image based on input image
    maskedRGBImage = RGB;
    
    % Set background pixels where whiteMask is false to zero
    maskedRGBImage(repmat(~whiteMask, [1 1 3])) = 0;
    
    figure(2);
    clf;
    imshow(maskedRGBImage) % Display the masked image
    
    % Calculate the centroid of the largest white object
    CC = bwconncomp(whiteMask);
    
    if CC.NumObjects > 0
        s = regionprops(CC, 'Centroid', 'Area');
        
        % Find the largest connected component
        [~, idx] = max([s.Area]);
        centroid = s(idx).Centroid;
        centroidX = centroid(1);
        centroidY = centroid(2);
        
        % Plot the location of the centroid
        hold on
        plot(centroidX, centroidY, 'm*', 'markersize', 32);
        hold off
    end
clear s
arduinoPort = 'COM3';

clear arduino
% Open a serial connection to Arduino
s = serialport(arduinoPort, 9600);
configureTerminator(s, "LF");

% Convert coordinates to a string and send to Arduino
coordinatesString = sprintf('%d,%d\n', centroidX, centroidY);
write(s, coordinatesString, "uint8");

% Close the serial connection
clear s;
clear arduino
end
