clear;
clc;
addpath('./utils/');

% parameter settings
block_size_list = [];
weight_flag_list = [0, 1, 2];
thres_u = 4;  %%%%%%% used for choosing seed pixels.  ----- discuss later
param_alpha = 10000;    %%%%%%% used for computing the parameter thres_b.     ------- discuss later
param_beta = 0.009;      %%%%%%% used for computing the parameter thres_h.     ------- discuss later
thres_c = 20;    %%%%%% used for filtering the holes.


img_dir = './img_for_test/';
img_lists = dir(img_dir);

block_size = 4;  %%%%%%%%%% discuss later

for i = 3:length(img_lists)
    tic
%   img_path = strcat(img_dir, '/', img_lists(i).name);
    img_path = strcat(img_dir, '/img_22.jpg');
    img = imread(img_path);
    YCbCr_space = rgb2ycbcr(img);
    img_luminance_pixel_level = YCbCr_space(:, :, 1);  % get luminance channel
    
    %% step1: get seed pixels
    [seed_pixels_map, block_map] = getSeedPixels(img_luminance_pixel_level, block_size, weight_flag_list, thres_u);
    
    %% step2: detect homogenous regions, the preceeding result is a input of this step.
    % note: 
    % 1. refined_seed_map has an extra one pixel boundry;
    % 2. homo_regs_index_struct is in block level index
    [img_height, img_width, ~] = size(img);
    thres_b = img_height * img_width * block_size / param_alpha;  %%%%%%% used for filtering unqualified homogenous regions. 
    [homo_regs_index_struct, refined_block_map] = detectHomoReg(block_map, block_size, thres_b);
    
    %% step3: detect sign background regions. 
    sign_bg_index_list = detectSignBgReg(homo_regs_index_struct, refined_block_map, img_luminance_pixel_level, block_size, param_beta, thres_c);
    
    %%  further process: remove the free boundary of extra one pixel, meanwhile restore the pixel level background map
    [block_height, block_width] = size(refined_block_map);
    final_block_bg_map_temp = zeros(block_height, block_width);
    for i=1:length(sign_bg_index_list)
        bg_index = sign_bg_index_list(i).indexes;
        final_block_bg_map_temp(bg_index) = 1;
    end
    final_block_bg_map = final_block_bg_map_temp(2 : block_height - 1, 2 : block_width - 1);
    
    final_pixel_bg_map = zeros(img_height, img_width);
    final_pixel_bg_map(1 : (block_height - 2) * block_size, 1 : (block_width - 2) * block_size) = kron(final_block_bg_map, ones(block_size, block_size));
    
    toc
    % show 
    imshow(final_pixel_bg_map);
end