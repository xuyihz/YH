%% Transfer APDL to MGT file
% read APDL
%
% Xu Yi, 2022.6.19

%%
close all; clear; clc;

%% 读取APDL文件数据
fileID = fopen('..\..\ANSYS\ANSYS_Files\3.SelfStress.ansys.txt','r');   % Open file for reading.

% 初始化
tline = '1';
para_data = zeros(5,1); % 参数数据
node_data = []; % 节点数据
element_data = [];  % 单元数据
support_data = [];  % 约束数据
element_init_data = []; % 初应力数据
% 读取文件数据
while tline ~= -1   % If the file is empty and contains only the end-of-file marker, then fgetl returns tline as a numeric value -1.
    C = strsplit(tline, ',');   % 在指定分隔符处拆分字符串或字符向量
    switch string(C{1}) % 判断每行的第一个字符串
        case 'ET'
            if double(string(C{3}(end-2:end))) == 180   % 最后三位为180
                para_data(1) = 1;   % 1定义为索
            end
        case 'R'
            para_data(2) = double(string(C{3}));    % 面积 mm^2
        case 'MP'
            switch string(C{2})
                case ' EX'
                    para_data(3) = double(string(C{4}));    % 弹性模量 N/mm^2
                case ' PRXY'
                    para_data(4) = double(string(C{4}));    % 泊松比
                case ' DENS'
                    para_data(5) = double(string(C{4}));    % 密度 kg/m^3
            end
        case 'N'
            node_data_temp = node_data;
            node_temp(1) = double(string(C{2}));    % 节点号
            node_temp(2) = double(string(C{3}));    % 节点坐标X
            node_temp(3) = double(string(C{4}));    % 节点坐标Y
            node_temp(4) = double(string(C{5}));    % 节点坐标Z
            node_data = [node_data_temp; node_temp];
        case 'EN'
            element_data_temp = element_data;
            element_temp(1) = double(string(C{2})); % 单元号
            element_temp(2) = double(string(C{3})); % 单元节点号1
            element_temp(3) = double(string(C{4})); % 单元节点号2
            element_data = [element_data_temp; element_temp];
        case 'D'
            switch string(C{3})
                case ' UX'
                    support_data_temp = support_data;
                    support_temp(1) = double(string(C{2})); % 约束单元号
                    support_temp(2) = 1;    % X向约束。对应MGT为100000
                    support_data = [support_data_temp; support_temp];
                case ' UY'
                    support_data_temp = support_data;
                    support_temp(1) = double(string(C{2})); % 约束单元号
                    support_temp(2) = 2;    % Y向约束。对应MGT为010000
                    support_data = [support_data_temp; support_temp];
                case ' UZ'
                    support_data_temp = support_data;
                    support_temp(1) = double(string(C{2})); % 约束单元号
                    support_temp(2) = 3;    % Z向约束。对应MGT为001000
                    support_data = [support_data_temp; support_temp];
            end
        case 'INISTATE'
            switch string(C{2})
                case ' DEFINE'
                    element_init_data_temp = element_init_data;
                    element_init_temp(1) = double(string(C{3})); % 初应力单元号
                    element_init_temp(2) = double(string(C{7})); % 初应力值
                    element_init_data = [element_init_data_temp; element_init_temp];
            end
    end
    tline = fgetl(fileID);  % 读取文件中的行，并删除换行符
end
fclose('all');
% 合并数据 element_data & element_init_data
element_data_temp = element_data;
element_data = [element_data_temp, zeros(length(element_data(:, 1)), 1)];
for i = 1:length(element_data(:, 1))
    for j = 1:length(element_init_data(:, 1))
        if element_data(i, 1) == element_init_data(j, 1)
            element_data(i, 4) = element_init_data(j, 2);
            break
        end
    end
end

%% 保存数据
save('../Data/YH_APDL.mat',...
    'para_data',...
    'node_data',...
    'element_data',...
    'support_data');
