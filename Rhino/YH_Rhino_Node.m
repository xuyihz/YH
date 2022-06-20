%% Transfer txt to mat
%
%
% Xu Yi, 2022.6.20

%%
close all; clear; clc;

%% 读取txt文件数据
n1_fileID = fopen('..\..\Rhino\n1.txt','r');   % Open file for reading.
n2_fileID = fopen('..\..\Rhino\n2.txt','r');   % Open file for reading.
n3_fileID = fopen('..\..\Rhino\n3.txt','r');   % Open file for reading.

% 读取文件数据
for i = 1:3
    switch i
        case 1
            fileID = n1_fileID;
        case 2
            fileID = n2_fileID;
        case 3
            fileID = n3_fileID;
    end
    % 初始化
    tline = '1';
    n = [];
    while tline ~= -1   % If the file is empty and contains only the end-of-file marker, then fgetl returns tline as a numeric value -1.
        C = strsplit(tline, ',');   % 在指定分隔符处拆分字符串或字符向量
        if length(C) == 3
            n_temp = n;
            n_temp_1 = ...
            [double(string(C{1}(2:end))),...
            double(string(C{2})),...
            double(string(C{3}(1:end-1)))];
            n = [n_temp; n_temp_1];
        end
        tline = fgetl(fileID);  % 读取文件中的行，并删除换行符
    end
    switch i
        case 1
            n1 = n; % 内环
        case 2
            n2 = n; % 外环上点 比中点抬高1.5
        case 3
            n3 = n; % 最外环上点
    end
end
fclose('all');

save('..\Data\YH_Rhino_Node.mat', 'n1', 'n2', 'n3');
