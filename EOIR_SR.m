%% IS 566 Project
% Umit Mert CAGLAR
% 2403685

%% Introduction
clc
clear
close all
show_images = 0;
%% Image loading

EO = imread ('EO.png');
IR = imread ('IR.png');

EO_dims = size(EO);
EO_height = EO_dims(1);
EO_width = EO_dims(2);
EO_channels = EO_dims(3);

IR_dims = size(IR);
IR_height = IR_dims(1);
IR_width = IR_dims(2);
if length(IR_dims) < 3
    IR_channels = 1;
else
    IR_channels = IR_dims(3);
end
fprintf('EO image had %d width and %d height \n',EO_width,EO_height);
fprintf('EO image has %d channels\n',EO_channels);

fprintf('IR image had %d pixels width and %d pixels height \n',IR_width,IR_height);
fprintf('IR image has %d channels\n',IR_channels);

EO_Original = EO;
IR_Original = IR;
EO = imresize(EO,[round(EO_height/2) round(EO_width/2)], 'nearest');
IR = imresize(IR,[round(IR_height/2) round(IR_width/2)], 'nearest');

%%
% figure
% imshow(EO)
% title('Electro-Optical Image')
% 
% figure
% imshow(IR)
% title('Infra-Red Thermal Image')


%% Image Resizing
fprintf('Resizing IR image to EO image dimensions with bicubic interpolation \n');

%resized_IR = imresize(IR,[EO_height EO_width], 'bicubic');
resized_IR = imresize(IR,[round(EO_height/2) round(EO_width/2)], 'bicubic');

% 
% 
if show_images
    figure
    imshow(resized_IR)
    title('Resized IR Image')
end

if show_images
    figure
    imshowpair(EO,resized_IR,'montage')
    title('EO and IR of a cargo barge')
end
%% Sharpning Truecolor (RGB) Image

sharpened_EO = imsharpen(EO,'Threshold',0.1);
if show_images
    figure
    imshowpair(EO,sharpened_EO,'montage')
    title('Original and Sharpened EO')
end
%% Sharpening Thermal (IR) Image

sharpened_IR = imsharpen(resized_IR,'Threshold',0.1);
if show_images
    figure
    imshowpair(resized_IR,sharpened_IR,'montage')
    title('Original and Sharpened IR')
end

%% Image preprocessing
if show_images
    figure
    imhist(resized_IR);
    title('Resized IR image histogram')
end

histogram_equalized_IR = histeq(resized_IR);
if show_images
    figure
    imhist(histogram_equalized_IR);
    title('Equalized IR image histogram')
end
if show_images
    figure
    imshowpair(resized_IR,histogram_equalized_IR,'montage')
    title('Original and histogram equalized IR')
end
%% Image Filters

sigma = 0.5;
alpha = 0.1;

IR_local_laplacian = locallapfilt(resized_IR, sigma, alpha,'NumIntensityLevels', 512);
if show_images
    figure
    imshowpair(resized_IR, IR_local_laplacian, 'montage')
    title('Local laplacian')
end
%IR_laplacian_3x3_filtered = imfilter(resized_IR, lap_mask_3, 'same');


%% Comparing histogram equalized image with filters
if show_images
    figure
    imshowpair(histogram_equalized_IR, IR_local_laplacian,'montage')
    title('Histogram Eq vs local laplacian')
end

%% Image histogram of local laplacian IR
if show_images
    figure
    imhist(IR_local_laplacian);
    title('Local Laplacian applied IR image histogram')
end

%% Metrics

EO = imresize(EO,[EO_height EO_width], 'bicubic');
PSNR_EO = psnr(EO,EO_Original);
SSIM_EO = ssim(EO,EO_Original);
RMSE_EO = sqrt(mean((EO(:)-EO_Original(:)).^2));
fprintf('The Root mean square error is %.3f. \n', RMSE_EO);
fprintf('EO image PSNR value %.3f.  \n',PSNR_EO);
fprintf('EO image SSIM value %.3f.  \n',SSIM_EO);

EO = imresize(sharpened_EO,[EO_height EO_width], 'bicubic');
PSNR_Sharpened_EO = psnr(EO,EO_Original);
SSIM_Sharpened_EO = ssim(EO,EO_Original);
fprintf('EO Sharpened image PSNR value %.3f.  \n',PSNR_Sharpened_EO);
fprintf('EO Sharpened image SSIM value %.3f.  \n',SSIM_Sharpened_EO);

IR = imresize(IR,[IR_height IR_width], 'bicubic');
PSNR_IR = psnr(IR,IR_Original);
fprintf('IR image PSNR value %.3f.  \n',PSNR_IR);

IR = imresize(sharpened_IR,[IR_height IR_width], 'bicubic');
PSNR_IR_sharp = psnr(IR,IR_Original);
fprintf('IR Sharpened image PSNR value %.3f.  \n',PSNR_IR_sharp);

IR = imresize(IR_local_laplacian,[IR_height IR_width], 'bicubic');
PSNR_IR_laplacian = psnr(IR,IR_Original);
fprintf('IR with local Laplacian image PSNR value %.3f.  \n',PSNR_IR_laplacian);


