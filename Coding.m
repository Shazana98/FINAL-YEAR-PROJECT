close all,  clear all, clc

myFolder1 = 'C:\Users\shaza\OneDrive\Documents\MATLAB\PSM\DRIVE\training\images';
myFolder2 = 'C:\Users\shaza\OneDrive\Documents\MATLAB\PSM\DRIVE\training\1st_manual';
fileList1 = dir(fullfile(myFolder1, '*.tif'));
fileList2 = dir(fullfile(myFolder2, '*.gif')); % Change to whatever pattern you need.
numFiles1 = length(fileList1);
numFiles2 = length(fileList2);
baseFileNames1 = {fileList1.name}';
baseFileNames2 = {fileList2.name}';

for I1 = 1:numFiles1
	firstBaseName = baseFileNames1{I1};
	firstFullFileName = fullfile(myFolder1, firstBaseName);
    fprintf(1, 'Now reading %s\n', firstFullFileName)
	image1 = imread(firstFullFileName);
    R = imresize(image1, [900 1000]);
    R1 = im2double(R);
    
    G = R1(:,:,2);
    C = adapthisteq(G);
    se = strel('disk', 3);
    O = imopen(C, se);
    
    gamma = 0.65;  %aspect ratio 
    psi = 0; %phase 
    theta = 125; %orientation 
    bw = 0.15; %bandwidth or effective width 
    lambda = 10; %wave1ength 
    pi = 180;
    for x = 1:900
        for y = 1:1000

            x_theta = O(x,y)*cos(theta)+O(x,y)*sin(theta); 
            y_theta = -O(x,y).*sin(theta)+O(x,y).*cos(theta);

            sigma = (1/pi*(sqrt(log(2)/2))*((2.^bw+1)/(2.^bw-1)))*lambda;

            gb(x,y) = exp(-0.5*((x_theta.^2/sigma)+((gamma.^2*y_theta.^2)/sigma)))*cos(2*pi*((x_theta/lambda)+psi)); 
        end
    end
    
    se = strel('disk', 8);
    tP = imtophat(gb,se);
    
    V = imread('C:\Users\shaza\OneDrive\Documents\MATLAB\PSM\DRIVE\training\mask\21_training_mask.gif');
    VR = imresize(V,[900 1000]);
    VR = im2double(VR);
    
    T = graythresh(tP);
    [T,EM] = graythresh(tP);
    BW = imbinarize(tP, T);
    BW2 = im2double(BW);
    BW = BW2.*VR;
    
    subplot(4,5,I1), imshow(BW, []);
    title('Result');
    
    for I2 = 1:numFiles2
        secondBaseName = baseFileNames2{I2};
        secondFullFileName = fullfile(myFolder2, secondBaseName);
        fprintf(1, 'Now reading %s\n', secondFullFileName)
        image2 = imread(secondFullFileName);
        R = imresize(image2, [900 1000]);
        R2 = im2double(R);
        
        sumindex = R2 + BW;
        TP = length(find(sumindex == 2));
        TN = length(find(sumindex == 0));
        substractindex = R2 - BW;
        FP = length(find(substractindex == -1));
        FN = length(find(substractindex == 1));
        
        Accuracy = (TP+TN)/(FN+FP+TP+TN)
        peaksnr = psnr(R2,BW)
    end
end 