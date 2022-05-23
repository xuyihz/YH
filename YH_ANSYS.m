%% Generate MGT file
% ANSYS APDL file
% run ANSYS in batch mode
% Xu Yi, 2022.5.21

%%
close all; clear; clc;

%% 
load('./Data/YH.mat',...    % 数据文件位置
    'Node_Coordinate',...   % [节点编号, X坐标, Y坐标, Z坐标]
    'Node_Support',...      % [节点编号, X约束, Y约束, Z约束]
    'Element_Node',...      % [单元编号, 节点编号1, 节点编号2]
    'Element_Property');    % [单元编号, 索直径编号, 索弹性模量编号]

%%


ANSYS_dir = "C:\Program Files\ANSYS Inc\v202\ANSYS\bin\winx64\ANSYS202.exe";
ANSYS_Fdir = "E:\项目\2022余杭国际体育中心\计算模型\ANSYS\ANSYS_Files";
ANSYS_Mdir = "E:\项目\2022余杭国际体育中心\计算模型\ANSYS\Model";
ANSYS_iFile = "test.ansys.txt";
ANSYS_oFile = "result.out";

% -b: batch模式; -p: license; -dir: 工作目录; -i: 输入文件; -o: 输出文件
command = sprintf('"%s" -b -p ane3fl -dir "%s" -i "%s\\%s" -o "%s\\%s"',...
    ANSYS_dir, ANSYS_Mdir, ANSYS_Fdir, ANSYS_iFile, ANSYS_Fdir, ANSYS_oFile);
% status = 0 表示成功运行
status = system(command);
