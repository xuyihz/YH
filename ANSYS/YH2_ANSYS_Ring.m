%% form finding the Ring
%
% ANSYS APDL file
% run ANSYS in batch mode
% Xu Yi, 2022.7.18

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
Fext = 'txt';               % 文件后缀
% 参数
AREA = pi*100^2/4;  % 索截面面积 mm^2
INERTIA_M = pi*100^4/64;    % 索惯性矩
EM = 1.9E5;         % 索弹性模量 N/mm^2
MD = 7850e-9;       % 索质量密度 kg/mm^3
ISTRAN = 1.0E-2;    % 索初应变
ERR_TOL = 1/1000;   % 误差容许值 mm^2
LSsteps = 20;       % 加载子步数
% 荷载 N
F_p = [-7, -7]; % Z向上为正 % 刚性杆上线荷载(两端点值)
F_Ring = 40000e3;   % 内环初始预拉力

%% 1.内环索找形
Time_1_name = '1.内环索找形';   Time_1 = string(datetime);
disp(Time_1_name); disp(Time_1);
% Job Name / Job Title
ANSYS_JName = 'Cable';
ANSYS_JTitle = 'The Analysis of Cable';
% 生成的APDL文件的路径
ANSYS_iFdir_1 = '..\..\ANSYS\ANSYS_Files\1.Ring.ansys.txt';
% ANSYS模型的路径
ANSYS_Mdir = '..\..\ANSYS\Model';   % ANSYS模型工作目录
ANSYS_oFdir = '..\..\ANSYS\ANSYS_Files\0.result.out';   % ANSYS输出文件
% MATLAB数据文件路径
DATA_FDir = '../Data/YH2_ANSYS.mat'; % 计算结果数据
% 计算结果输出的变量名
NODE_Ring = []; ELEM_Ring = [];
save(DATA_FDir, 'NODE_Ring', 'ELEM_Ring');

%%
% 内环/中环(合力假想环)的节点坐标
Node_Coordinate_Ring = zeros( Num_Radial*2 , length(Node_Coordinate(1,:)) );
% 内环/中环(合力假想环)的单元节点关系
% 平均到每个内环节点：径向一个单元，环向一个单元
Element_Node_Ring = zeros( Num_Radial*2 , length(Element_Node(1,:)) );
% 节点
for i = 1 : Num_Radial
    % 内环节点
    iNo_temp = 1+(i-1)*Node_Itvl;
    iNo_Row_temp = Node_Coordinate(:,1) == iNo_temp;  % 查找iNo_temp在Node_Coordinate中的序列
    Node_Coordinate_Ring(i,:) = Node_Coordinate(iNo_Row_temp,:);
    % 中环(合力假想环)节点
    iNo_temp = iNo_temp + Num_n1_n2*2 + 1;    % 编号按中环上索节点
    iNo_Row_temp = Node_Coordinate(:,1) == iNo_temp;  % 查找iNo_temp在Node_Coordinate中的序列
    Node_Coordinate_Ring(i+Num_Radial,:) = Node_Coordinate(iNo_Row_temp,:);
end
% 单元：径向
for i = 1 : Num_Radial  % 1 : Num_Radial % 榀
    Element_Node_Ring(i,:) = [ i,...
        Node_Coordinate_Ring(i, 1),...
        Node_Coordinate_Ring(i+Num_Radial, 1)];
end
% 单元：内环
for i = 1 : Num_Radial  % 1 : Num_Radial % 榀
    iE_temp = iEL_Ring + i - 1;
    iE_Row_temp = Element_Node(:,1) == iE_temp;  % 查找iE_temp在Element_Node中的序列
    Element_Node_Ring(i+Num_Radial,:) = Element_Node( iE_Row_temp , :);
end
% 生成找形 APDL文件
oFileName = YH2_Module_FormFinding_Ring(...
    Node_Coordinate_Ring, Element_Node_Ring, Num_Radial,...
    AREA, INERTIA_M, EM, MD,...
    F_Ring, F_p,...
    ANSYS_Mdir, Fext, ERR_TOL, LSsteps,...
    ANSYS_JName, ANSYS_JTitle, ANSYS_iFdir_1);
% 自动调用ANSYS
status = YH_Module_RunANSYS(ANSYS_JName, ANSYS_Mdir, ANSYS_iFdir_1, ANSYS_oFdir);

% % 把ANSYS APDL输出结果txt转换为MATLAB的.mat文件
% YH2_Module_TXT2MAT(oFileName, ANSYS_Mdir, Fext, DATA_FDir)

% 显示时间
Time_temp_name = 'ANSYS计算完毕';   Time_temp = string(datetime);
disp(Time_temp_name);   disp(Time_temp); % 显示当前时间
