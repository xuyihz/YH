%% Find Ring Coordinate
% 
% 
% Xu Yi, 2022.7.13

%%
close all; clear; clc;

%%
addpath(genpath('Func'))    % 搜索路径中加入Func文件夹及其下所有文件夹
addpath(genpath('Module'))  % 搜索路径中加入Func文件夹及其下所有文件夹

%% 0.导入初始数据
Time_0_name = '0.导入初始数据';   Time_0 = string(datetime);
disp(Time_0_name);   disp(Time_0); % 显示当前时间
% MATLAB数据文件路径
DATA_FDir = '../Data/YH2_ANSYS.mat'; % 计算结果数据
load(DATA_FDir, 'NODE');
load(DATA_FDir, 'ELEM');
load(DATA_FDir, 'Radial_N');
% 其中环向索仅导入了内环
load('../Data/YH.mat',...   % 数据文件位置
    'Node_Coordinate',...   % [节点编号, X坐标, Y坐标, Z坐标]
    'Node_Support',...      % [节点编号, X约束, Y约束, Z约束]
    'Element_Node',...      % [单元编号, 节点编号1, 节点编号2]
    'Element_Property',...  % [单元编号, 索直径编号, 索弹性模量编号]
    'Num_Radial',...        % 榀数
    'Num_n1_n2',...         % n1~n2间的分隔数 (索桁架处)
    'Node_Itvl',...         % 每一榀的节点数
    'iEL_Ring',...          % 内环起始单元编号
    'f1');                  % 垂度
Fext = 'txt';               % 文件后缀
% 参数
AREA = pi*100^2/4;  % 索截面面积 mm^2
EM = 1.9E5;         % 索弹性模量 N/mm^2
F_p = -40e3;        % 作用在内环节点处的外荷载 N

%% 短轴 Radial_N=1
%% 长轴 Radial_N=11
%% 基础数据
% 原点
Origin_NODE = NODE(1, :);   % 内环节点(原点)
% 径向
Radial_t_NODE = NODE(2, :); % 径向上索离内环最近节点
Radial_b_NODE = NODE(2+Num_n1_n2+2, :);   % 径向下索离内环最近节点
Radial_t_ELEM = ELEM(1, :); % 径向上索离内环最近节点应变
Radial_b_ELEM = ELEM(1+Num_n1_n2+1, :); % 径向下索离内环最近节点应变
% 环向
if Radial_N == 1
    index_l_temp =  Node_Coordinate(:, 1) == Node_Itvl*(Num_Radial-1)+1;
elseif Radial_N == 11
    index_l_temp =  Node_Coordinate(:, 1) == Node_Itvl*(Radial_N-2)+1;
end
index_r_temp = Node_Coordinate(:, 1) == Node_Itvl*Radial_N+1;
% 环向节点1 左边的节点
Ring_l_NODE = Node_Coordinate(index_l_temp, :);
% 环向节点1 右边的节点
Ring_r_NODE = Node_Coordinate(index_r_temp, :);

%% 向量
Vector_F = [0, 0, F_p];     % 节点外荷载向量
% 径向上索向量
Vector_Radial_t = Radial_t_NODE(2:4) - Origin_NODE(2:4);
Vector_Radial_t = Vector_Radial_t / norm(Vector_Radial_t)...    % 归一化
    * Radial_t_ELEM(2) * EM * AREA; % F = εEA
% 径向下索向量
Vector_Radial_b = Radial_b_NODE(2:4) - Origin_NODE(2:4);
Vector_Radial_b = Vector_Radial_b / norm(Vector_Radial_b)...
    * Radial_b_ELEM(2) * EM * AREA; % F = εEA
% 环索
% 环索合力向量
Vector_Ring = [0, 0, 0]...
    - (Vector_F + Vector_Radial_t + Vector_Radial_b);
% 原点左环索向量
Vector_Ring_l = Ring_l_NODE(2:4) - Origin_NODE(2:4);
% 原点右环索向量
Vector_Ring_r = Ring_r_NODE(2:4) - Origin_NODE(2:4);
% 求右环索Z更新的坐标
% Vector_Ring_l + para_temp * Vector_Ring_r 与 Vector_Ring同方向
para_temp = ( Vector_Ring_l(1)*Vector_Ring(2) - Vector_Ring(1)*Vector_Ring_l(2) )...
    / ( Vector_Ring(1)*Vector_Ring_r(2) - Vector_Ring_r(1)*Vector_Ring(2) );
Vector_Ring_r(3) = ( Vector_Ring(3)/Vector_Ring(1)...
    *( Vector_Ring_l(1) + para_temp*Vector_Ring_r(1) )...
    - Vector_Ring_l(3) ) / para_temp;
Ring_r_NODE(4) = Origin_NODE(4) + Vector_Ring_r(3); % 右环索Z更新的坐标
Z = Ring_r_NODE(4);
