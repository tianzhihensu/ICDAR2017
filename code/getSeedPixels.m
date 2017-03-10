function [ seed_pixels_map, block_map ] = getSeedPixels( luminance_map, block_size, weight_flag_list, thres_u )
%GETSEEDPIXELS get seed pixels of an image by the luminance of block of
%size K * K
%   
% Input:
%   luminance_map: a matrix of same size to image, each element is the
%   luminance value of correspond pixel
%   block_size: a scale value, block is square
%   weight_matrics:
%   thres_u: the threshold of block luminance

% Output:
%   seed_pixels_map: each seed pixel is assigned to value 1, while other
%   pixels to value 0.
%   block_map: in this map, each block is regarded as a point, if a block
%   is homogenous,then the corresponding point (xi, yi) is assigned to 1.

[img_height, img_width] = size(luminance_map);
seed_pixels_map = zeros(img_height, img_width);

% get the block number in row and col direction.
row_block_num = floor(img_height / block_size);
col_block_num = floor(img_width / block_size);

block_map = zeros(row_block_num, col_block_num);  % block_map is used to record a block is homogenous or not.
temp_block_map = zeros(row_block_num + 2, col_block_num + 2); % store intermediate result, free boundry
% get weight matrics
M = size(weight_flag_list, 2);  % get the number of weight matrix
weight_matrix_list = zeros(block_size, block_size, M);  % initialization
for i=1:M
    weight_matrix_list(:, :, i) = getWeightMatrix(weight_flag_list(i), block_size);
end

% traverse each block, check homogenous
for i=1:row_block_num
    idx_row = (i - 1) * block_size + 1;  % current row index
    for j=1:col_block_num
        idx_col = (j - 1) * block_size + 1;  % current col index
        cur_block_luminance_map = luminance_map(idx_row:idx_row + block_size - 1, idx_col:idx_col + block_size - 1);
        vector_I = cur_block_luminance_map(:);
        % convert uint8 to double
        vector_I = double(vector_I);
        
        % initialize homogenous feature vector
        vector_homo_feature = zeros(1, M);
        % compute homogenous features
        for k=1:M
            weight_matrix_k = weight_matrix_list(:, :, k);
            result_intermediate = vector_I' * weight_matrix_k(:);
            vector_homo_feature(1, k) = abs(2/(block_size^2) * sum(result_intermediate));
        end
        
        % L_infinate norm, get the maximum one.
        if max(vector_homo_feature) <= thres_u
            temp_block_map(i + 1, j + 1) = 1;
        end
        
    end
end

% refine block homogenous regions, at least one of its four neighbor has
% the value 1
for i=2:row_block_num + 1
    for j=2:col_block_num + 1
        if temp_block_map(i, j) == 1 && (temp_block_map(i - 1, j) == 1 || temp_block_map(i, j + 1) == 1 || temp_block_map(i + 1, j) == 1 || temp_block_map(i, j - 1) == 1)
            block_map(i - 1, j - 1) = 1;
        end            
    end
end

% restore to pixel level
seed_pixels_map(1:block_size * row_block_num, 1:block_size * col_block_num) = kron(block_map, ones(block_size, block_size));
end

