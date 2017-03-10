function [ sign_bg_index_struct ] = detectSignBgReg( homo_regs_index_struct, refined_block_map, luminance_pixel_level, block_size, param_beta, thres_c )
%DETECTSIGNBGREG detect sign background regions.
% a sign background region must satisified two conditions:
% condition 1: hole...
% condition 2: text contrast to background
% 
% Input:
%   homo_regs_index_struct: block_level index
%   refined_block_map:
%   block_size: 
%   param_beta: for computing the threshold thres_h
%
% Output:
%   sign_bg_index_struct:

sign_bg_index_struct = homo_regs_index_struct;

[height_block, width_block] = size(refined_block_map);  % refined_block_map has a free boundary of one pixel width on both row and col
template_map = zeros(height_block, width_block);

scale_factor = block_size^2;

% compute the average luminance of each block, and store in an block map.
luminance_block_level = zeros(height_block, width_block);
for k=2:height_block - 1
    row_point = block_size * (k - 2) + 1;
    for t=2:width_block - 1
        col_point = block_size * (t - 2) + 1;
        cur_block_map = luminance_pixel_level(row_point:row_point + block_size - 1, col_point:col_point + block_size - 1);
        avg_lumi = sum(sum(cur_block_map)) / scale_factor;
        luminance_block_level(k, t) = avg_lumi;
    end
end


neglected_index = [];
for i=1:length(homo_regs_index_struct)
    region_index = homo_regs_index_struct(i).indexes;
    region_size = size(region_index, 1) * scale_factor;
    thres_h = param_beta * region_size;  % calculate the minimum threshold for filtering the hole
    
    % compute the average luminance of current background region.
    avg_bg_luminance = mean(luminance_block_level(region_index));
    
    template_map = zeros(height_block, width_block);  
    template_map(region_index) = 1;
    [sub_map, sub_lumi_map ] = getSubImageMap(template_map, luminance_block_level);  % get the minimum rectangular box surrounding this region.
    
    % before use function getConnectedRegIndex(), each pixel value should
    % be switched. eg: 1 --> 0 and 0 --> 1.
    % reasons: function getConnectedRegIndex() will find regions with the value 1,
    % so we set the bg to 0, while other pixels are set to value 0
    zero_index = find(sub_map == 0);
    one_index = find(sub_map == 1);
    sub_map(zero_index) = 1;
    sub_map(one_index) = 0;
    connected_reg_index_struct = getConnectedRegIndex(sub_map);
    % refine, discard unqualified connected region
    valid_reg_num = 0;
    for j=2:length(connected_reg_index_struct)          % the first element is the boundary connected region, shall be neglected.
        hole_index = connected_reg_index_struct(j).indexes;
        hole_index_num = size(hole_index, 1);
        avg_hole_luminance = mean(sub_lumi_map(hole_index));
        
        % satisfied the two conditions
        if hole_index_num * scale_factor >= thres_h && abs(avg_hole_luminance - avg_bg_luminance) >= thres_c
            valid_reg_num = valid_reg_num + 1;
        end
    end
    
    % record the index of regions that cannot satisfied conditions
    if valid_reg_num < 2
        neglected_index = [neglected_index, i];
    end
end

sign_bg_index_struct(neglected_index) = [];

end

% find the  a minimum rectangular bounding box is defined
% around the region that contains all the white pixels
function [sub_map, sub_lumi_map] = getSubImageMap(entire_map, luminance_map)
    row_sum = sum(entire_map, 1);   % get a row vector, we can find the column boundary of left and right
    col_idx = find(row_sum);
    col_min = col_idx(1, 1) - 1;
    col_max = col_idx(1, end) + 1;
    
    col_sum = sum(entire_map, 2);
    row_idx = find(col_sum);
    row_min = row_idx(1, 1) - 1;
    row_max = row_idx(end, 1) + 1;
    
    sub_map = entire_map(row_min:row_max, col_min:col_max);
    sub_lumi_map = luminance_map(row_min:row_max, col_min:col_max);
end

