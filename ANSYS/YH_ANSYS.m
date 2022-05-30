%% Generate APDL file
% 
% ANSYS APDL file
% run ANSYS in batch mode (Maybe)
% Xu Yi, 2022.5.29

%%
close all; clear; clc;

%% 
addpath(genpath('Func'))    % 搜索路径中加入Func文件夹及其下所有文件夹
addpath(genpath('Module'))  % 搜索路径中加入Func文件夹及其下所有文件夹

%% 0.导入初始数据
% 其中环向索仅导入了内环
load('../Data/YH.mat',...   % 数据文件位置
    'Node_Coordinate',...   % [节点编号, X坐标, Y坐标, Z坐标]
    'Node_Support',...      % [节点编号, X约束, Y约束, Z约束]
    'Element_Node',...      % [单元编号, 节点编号1, 节点编号2]
    'Element_Property',...  % [单元编号, 索直径编号, 索弹性模量编号]
    'Num_Radial',...        % 榀数
    'Num_n1_n2',...         % n1~n2间的分隔数 (索桁架处)
    'Node_Itvl',...         % 每一榀的节点数
    'iEL_Ring');            % 内环起始单元编号
% 参数
AREA = pi*100^2/4;  % 索截面面积 mm^2
EM = 1.9E5;         % 索弹性模量 N/mm^2
MD = 7850;          % 索质量密度 kg/mm^2
ISTRAN = 1.0E-2;    % 索初应变
ERR_TOL = 1/1000;   % 误差容许值 mm^2
LSsteps = 20;       % 加载子步数
f2 = -300;  % 下索跨中垂度(向上) mm YH_model.m

%% 1.形态判断
% YH_Module_Shape_Judge(Node_Coordinate, Num_Radial, Node_Itvl);

%% 2.单榀(Radial)自应力模态分析
% Job Name / Job Title
ANSYS_JName = 'Cable';
ANSYS_JTitle = 'The Analysis of Cable';
% 生成的APDL文件的路径
ANSYS_iFdir_1 = '..\..\ANSYS\ANSYS_Files\1.Radial.ansys.txt';
% ANSYS模型的路径
ANSYS_Mdir = '..\..\ANSYS\Model';   % ANSYS模型工作目录
ANSYS_oFdir = '..\..\ANSYS\ANSYS_Files\0.result.out';   % ANSYS模型输入文件
% MATLAB数据文件路径
EPEL_FDir = '../Data/YH_ANSYS.mat'; % 应变(EPEL)数据
% % 生成APDL文件中Model部分
% YH_Module_Model(Node_Coordinate, Node_Support,...
%     Element_Node, Element_Property,...
%     AREA, EM, MD,...
%     ANSYS_JName, ANSYS_JTitle, ANSYS_iFdir_1);
% % 生成APDL文件中SOLU部分
% [EPEL_T_FN, EPEL_B_FN, Fext] = YH_Module_Solu_Radial(Num_Radial, Num_n1_n2, Node_Itvl,...
%     ISTRAN, ERR_TOL, LSsteps,...
%     ANSYS_iFdir_1);
% % 自动调用ANSYS
% status = YH_Module_RunANSYS(ANSYS_JName, ANSYS_Mdir, ANSYS_iFdir_1, ANSYS_oFdir);
% % 把ANSYS APDL输出结果txt转换为MATLAB的.mat文件
% [EPEL_T_N, EPEL_B_N] = YH_Module_EPEL(Num_Radial, Num_n1_n2,...
%     ANSYS_Mdir, EPEL_T_FN, EPEL_B_FN, Fext, EPEL_FDir);

%% 3.下索找形
load('../Data/YH_ANSYS.mat',... % 数据文件位置
    'EPEL_T',...            % 单榀上索自应力模态(应变)
    'EPEL_B');              % 更新的(与上索一致)单榀下索自应力模态(应变)
ANSYS_iFdir_2 = '..\..\ANSYS\ANSYS_Files\2.Form-finding.ansys.txt';
Node_Coordinate = YH_Module_FormFinding(Node_Coordinate, Element_Node,...
    Num_Radial, Num_n1_n2, Node_Itvl,...
    EPEL_T, EPEL_B, f2,...
    AREA, EM, MD,...
    ISTRAN, ERR_TOL, LSsteps,...
    ANSYS_JName, ANSYS_JTitle, ANSYS_iFdir_2,...
    ANSYS_Mdir, ANSYS_oFdir, EPEL_FDir);

%% 4.整体模型自应力模态下分析



