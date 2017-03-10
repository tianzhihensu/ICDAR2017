function [ weight_matrix ] = getWeightMatrix( weight_flag, block_size )
%GETWEIGHTMATRIX return weight matrix illustrated on paper "A Low Complexity Sign Detection and Text Localization Method for Mobile Applications"
% details: given weight_flag and size, a specific weight_matrix can be
% defined.
% Input:
%   weight_flag: can be 0, 1, 2. as paper depicts.
%   block_size: the size of block, meanwhile it's also the size of
%   weight_matrix

% Output:
%   weight_matrix:  

weight_matrix = repmat(1, block_size, block_size);

switch weight_flag
    case 0
        mid_index = block_size / 2;
        weight_matrix(1:mid_index, mid_index + 1:end) = -1;
        weight_matrix(mid_index + 1:end, 1:mid_index) = -1;
    case 1
        weight_matrix(1:block_size/2, :) = -1;
    case 2
        weight_matrix(:, block_size/2 + 1:end) = -1;
end



end

