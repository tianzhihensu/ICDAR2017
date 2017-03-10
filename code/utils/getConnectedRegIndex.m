function [ connected_reg_index_struct ] = getConnectedRegIndex( seed_map )
%VALIDATEBOUND ��ȡһ�����������е���ͨ��������ͨ������ÿ����ͨ�����index��Ϊstruct��һ��Ԫ�أ�����һ��ͨ�ð汾
% note:
%   seed_map��seed��Ԫ��ֵΪ1����seedԪ��Ϊ0
%
%   �˴���ʾ��ϸ˵��
% Input:
%   seed_map: Ҫ�����Ԫ�ؾ���
%
% Output:
%   connected_reg_index_struct: ��ͨ�����indexes��ɵ�struct

% ���ȶ�ԭedgeMap������չ�����ں��ڵ�����
[row, col] = size(seed_map);
seed_map_temp = zeros(row + 2, col + 2); % ������߿�
seed_map_temp(2:row + 1, 2:col + 1) = seed_map;
% ������Ԫ��ֵΪ1������
[r, c, ~] = find(seed_map_temp == 1);
existing_index = [r c];

count = 0;
% ���ѭ����ÿѭ��һ�Σ����ҵ�һ����ͨ����
% ֻҪ����Ϊ1��Ԫ�أ��ͼ�����ѭ��
while ~isempty(existing_index)
    count = count + 1;
    count
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
    seed_map_remove_boudnary = seed_map_temp(2:end-1, 2:end-1);
    target_index = find(seed_map_remove_boudnary == -1);
    connected_reg_index_struct(count).indexes = target_index;
    seed_map_temp(find(seed_map_temp == -1)) = 0;  % ��0
    target_index = [];
    % �ٴ�������Ԫ��ֵΪ1������
    [r, c, ~] = find(seed_map_temp == 1);
    existing_index = [r c];
end

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

