function [ homo_regs_index_struct, refined_seed_map ] = detectHomoRegions( seed_map, block_size, thres_b )
%VALIDATEBOUND 给定种子地图（seedmap），
% 找出其所有四连通区域，不符合的过滤掉，这是为当前approach定制的方法，此方法不通用，'utils/'目录下有通用版本
% note:
%   seed_map，seed的元素值为1，非seed元素为0
%
% Input:
%   seed_map: 要处理的元素矩阵
%   block_size: 块大小
%   thres_b: 用于过滤homogenous region的阈值
%
% Output:
%   homo_regs_index_struct: homogenous regions的indexes组成的struct, index
%   是block level

% 首先对原edgeMap进行扩展，便于后期的搜索
[row, col] = size(seed_map);
refined_seed_map = zeros(row + 2, col + 2);  % 初始化，用于存放过滤后的seed_map
seed_map_temp = zeros(row + 2, col + 2); % 设置外边框
seed_map_temp(2:row + 1, 2:col + 1) = seed_map;
% 找所有元素值为1的坐标
[r, c, ~] = find(seed_map_temp == 1);
existing_index = [r c];

count = 0;
% 外层循环
% 只要还有边界，就要检测是否是一个封闭曲线
while ~isempty(existing_index)
    cordinate_stack = existing_index(1, :);
    top = 1;
    
    seed_map_temp(existing_index(1, 1), existing_index(1, 2)) = -1;
    % 内层循环
    while top ~= 0  % 只要栈非空
        cur_point = cordinate_stack(top, :);  % 取栈顶元素
        
        x = cur_point(1, 1);  
        y = cur_point(1, 2);
        next_x = x;
        next_y = y;
        
        % 判断未访问过且为1的第一个周边元素（这里是四连通区域，已访问过的都会被标记为-1），将其压入栈中，从左侧逆时针
        if seed_map_temp(x, y - 1) == 1
            next_y = y - 1;
        elseif seed_map_temp(x + 1, y) == 1
            next_x = x + 1;
        elseif seed_map_temp(x, y + 1) == 1
            next_y = y + 1;
        elseif seed_map_temp(x - 1, y) == 1
            next_x = x - 1;
        end
        
        % 如果找到, 入栈，进入下一轮的搜索
        if ~(next_x == x && next_y == y) 
            top  = top + 1;
            cordinate_stack(top, :) = [next_x, next_y];
            seed_map_temp(next_x, next_y) = -1; % 所有访问过（无论是在栈中，或入栈又出栈了）的都标记为-1
        
        else  % 当前栈顶元素的周边都没有，从栈中弹出该栈顶元素
            cordinate_stack(top, :) = [];
            top = top - 1;
        end
    end
    
    % 当前基于第一个点的所有连通区域都找到，且都标记为-1，找到其index，存放在struct中，
    % 然后将其值置为0，继续下一个连通区域的搜索
    target_index = find(seed_map_temp == -1);
    % 过滤不符合的homogenous regions
    if size(target_index, 1) * block_size^2 >= thres_b  %% 该region的pixel个数是否满足要求
        count = count + 1;
        disp(strcat('valid homogenous regions, count = ', num2str(count)));
        homo_regs_index_struct(count).indexes = target_index;
        seed_map_temp(target_index) = -2;  % 置0
    else
       seed_map_temp(target_index) = 0;  % 置0 
    end
    % 再次找所有元素值为1的坐标
    [r, c, ~] = find(seed_map_temp == 1);
    existing_index = [r c];
end

target_idx = find(seed_map_temp == -2);

refined_seed_map(target_idx) = 1;

end

function [edgeMap] = changeA2B(edgeMap, valueA, valueB)
% 将元素值为A的转为值为B
% Input:
%   edgeMap: 元素所在的矩阵
%   valueA: 元素值A
%   valueB: 元素值B
%
% Output:
%   edgeMap: 转换之后的矩阵
    index = find(edgeMap == valueA);
    edgeMap(index) = valueB;
end