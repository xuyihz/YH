%% Generate APDL file
% 
% ANSYS APDL file
% run ANSYS in batch mode
% Xu Yi, 2022.7.10

%%
close all; clear; clc;

%% 
addpath(genpath('Func'))    % 搜索路径中加入Func文件夹及其下所有文件夹
addpath(genpath('Module'))  % 搜索路径中加入Func文件夹及其下所有文件夹

%% 0.导入初始数据
Time_0_name = '0.导入初始数据';   Time_0 = string(datetime);
disp(Time_0_name);   disp(Time_0); % 显示当前时间
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
% 参数
AREA = pi*100^2/4;  % 索截面面积 mm^2
EM = 1.9E5;         % 索弹性模量 N/mm^2
MD = 7850;          % 索质量密度 kg/mm^2
ISTRAN = 1.0E-2;    % 索初应变
ERR_TOL = 1/1000;   % 误差容许值 mm^2
LSsteps = 20;       % 加载子步数

%% 5.整体模型自应力模态下分析
load('../Data/YH_ANSYS.mat',... % 数据文件位置
    'EPEL_T',...            % 单榀上索自应力模态(应变)
    'EPEL_B');              % 更新的(与上索一致)单榀下索自应力模态(应变)
ANSYS_iFdir_3 = '..\..\ANSYS\ANSYS_Files\3.SelfStress.ansys.txt';
% MATLAB数据文件路径
EPEL_FDir = '../Data/YH_ANSYS.mat'; % 应变(EPEL)数据
% Job Name / Job Title
ANSYS_JName = 'Cable';
ANSYS_JTitle = 'The Analysis of Cable';
co_EPEL_Base = 0.003;  % 以第一个内环节点环索左节点为基准应变 (最大应变约为0.005对应强度设计值)
% 整体自应力模态
[EPEL_Radial,  EPEL_Ring] = YH_Module_SelfStress(Node_Coordinate,...
    Num_Radial, Num_n1_n2, iEL_Ring, EPEL_T, EPEL_B, co_EPEL_Base, EPEL_FDir);
% 生成APDL文件中Model部分
YH_Module_Model(Node_Coordinate, Node_Support,...
    Element_Node, Element_Property,...
    AREA, EM, MD,...    % 下一行最后的0是SupportSwitch,表示仅支座添加约束
    ANSYS_JName, ANSYS_JTitle, ANSYS_iFdir_3, 0);
YH_Module_Solu_Self(Num_Radial, EPEL_Radial, EPEL_Ring, LSsteps,...
    ANSYS_iFdir_3);
