function [ homo_regs_index_struct, refined_seed_map ] = detectHomoRegions( seed_map, block_size, thres_b )
%VALIDATEBOUND �������ӵ�ͼ��seedmap����
% �ҳ�����������ͨ���򣬲����ϵĹ��˵�������Ϊ��ǰapproach���Ƶķ������˷�����ͨ�ã�'utils/'Ŀ¼����ͨ�ð汾
% note:
%   seed_map��seed��Ԫ��ֵΪ1����seedԪ��Ϊ0
%
% Input:
%   seed_map: Ҫ�����Ԫ�ؾ���
%   block_size: ���С
%   thres_b: ���ڹ���homogenous region����ֵ
%
% Output:
%   homo_regs_index_struct: homogenous regions��indexes��ɵ�struct, index
%   ��block level

% ���ȶ�ԭedgeMap������չ�����ں��ڵ�����
[row, col] = size(seed_map);
refined_seed_map = zeros(row + 2, col + 2);  % ��ʼ�������ڴ�Ź��˺��seed_map
seed_map_temp = zeros(row + 2, col + 2); % ������߿�
seed_map_temp(2:row + 1, 2:col + 1) = seed_map;
% ������Ԫ��ֵΪ1������
[r, c, ~] = find(seed_map_temp == 1);
existing_index = [r c];

count = 0;
% ���ѭ��
% ֻҪ���б߽磬��Ҫ����Ƿ���һ���������
while ~isempty(existing_index)
    cordinate_stack = existing_index(1, :);
    top = 1;
    
    seed_map_temp(existing_index(1, 1), existing_index(1, 2)) = -1;
    % �ڲ�ѭ��
    while top ~= 0  % ֻҪջ�ǿ�
        cur_point = cordinate_stack(top, :);  % ȡջ��Ԫ��
        
        x = cur_point(1, 1);  
        y = cur_point(1, 2);
        next_x = x;
        next_y = y;
        
        % �ж�δ���ʹ���Ϊ1�ĵ�һ���ܱ�Ԫ�أ�����������ͨ�����ѷ��ʹ��Ķ��ᱻ���Ϊ-1��������ѹ��ջ�У��������ʱ��
        if seed_map_temp(x, y - 1) == 1
            next_y = y - 1;
        elseif seed_map_temp(x + 1, y) == 1
            next_x = x + 1;
        elseif seed_map_temp(x, y + 1) == 1
            next_y = y + 1;
        elseif seed_map_temp(x - 1, y) == 1
            next_x = x - 1;
        end
        
        % ����ҵ�, ��ջ��������һ�ֵ�����
        if ~(next_x == x && next_y == y) 
            top  = top + 1;
            cordinate_stack(top, :) = [next_x, next_y];
            seed_map_temp(next_x, next_y) = -1; % ���з��ʹ�����������ջ�У�����ջ�ֳ�ջ�ˣ��Ķ����Ϊ-1
        
        else  % ��ǰջ��Ԫ�ص��ܱ߶�û�У���ջ�е�����ջ��Ԫ��
            cordinate_stack(top, :) = [];
            top = top - 1;
        end
    end
    
    % ��ǰ���ڵ�һ�����������ͨ�����ҵ����Ҷ����Ϊ-1���ҵ���index�������struct�У�
    % Ȼ����ֵ��Ϊ0��������һ����ͨ���������
    target_index = find(seed_map_temp == -1);
    % ���˲����ϵ�homogenous regions
    if size(target_index, 1) * block_size^2 >= thres_b  %% ��region��pixel�����Ƿ�����Ҫ��
        count = count + 1;
        disp(strcat('valid homogenous regions, count = ', num2str(count)));
        homo_regs_index_struct(count).indexes = target_index;
        seed_map_temp(target_index) = -2;  % ��0
    else
       seed_map_temp(target_index) = 0;  % ��0 
    end
    % �ٴ�������Ԫ��ֵΪ1������
    [r, c, ~] = find(seed_map_temp == 1);
    existing_index = [r c];
end

target_idx = find(seed_map_temp == -2);

refined_seed_map(target_idx) = 1;

end

function [edgeMap] = changeA2B(edgeMap, valueA, valueB)
% ��Ԫ��ֵΪA��תΪֵΪB
% Input:
%   edgeMap: Ԫ�����ڵľ���
%   valueA: Ԫ��ֵA
%   valueB: Ԫ��ֵB
%
% Output:
%   edgeMap: ת��֮��ľ���
    index = find(edgeMap == valueA);
    edgeMap(index) = valueB;
end