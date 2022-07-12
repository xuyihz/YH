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
Fext = 'txt';               % 文件后缀
% 参数
AREA = pi*100^2/4;  % 索截面面积 mm^2
EM = 1.9E5;         % 索弹性模量 N/mm^2
MD = 7850e-9;       % 索质量密度 kg/mm^3
ISTRAN = 1.0E-2;    % 索初应变
ERR_TOL = 1/1000;   % 误差容许值 mm^2
LSsteps = 20;       % 加载子步数

%% 1.索网找形
Time_1_name = '1.索网找形';   Time_1 = string(datetime);
disp(Time_1_name); disp(Time_1);
% Job Name / Job Title
ANSYS_JName = 'Cable';
ANSYS_JTitle = 'The Analysis of Cable';
% 生成的APDL文件的路径
ANSYS_iFdir_1 = '..\..\ANSYS\ANSYS_Files\1.Radial.ansys.txt';
% ANSYS模型的路径
ANSYS_Mdir = '..\..\ANSYS\Model';   % ANSYS模型工作目录
ANSYS_oFdir = '..\..\ANSYS\ANSYS_Files\0.result.out';   % ANSYS输出文件
% MATLAB数据文件路径
DATA_FDir = '../Data/YH2_ANSYS.mat'; % 计算结果数据
save(DATA_FDir, 'DATA_FDir');

% 单榀荷载 N
F_cr_ori = 4000e3;
F_cl_ori = -20e3;
F_p_ori = [-40e3, 0];   % Z向上为正
for j = 1 : 1   % 上/下索 1上2下
    F_cr = ones(Num_n1_n2+1, 1) * F_cr_ori;
    F_cl = ones(Num_n1_n2, 1) * F_cl_ori(j) * sign(1.5-j);  % sign(0.5)=1; sign(-0.5)=-1;
    F_p = ones(Num_n1_n2, 1) * F_p_ori(j);
end
% 单榀上/下索的坐标
Node_Coordinate_Radial = zeros( Num_n1_n2+2 , length(Node_Coordinate(1,:)) );
for i = 1 : 1   % 1 : Num_Radial % 榀
    iNo_Start = 1+(i-1)*Node_Itvl;
    iNo_Row_Start = find( Node_Coordinate(:,1) == iNo_Start );  % 查找iNo_Start在Node_Coordinate中的序列
    for j = 1 : 1   % 上/下索 1上2下
        Node_Coordinate_Radial(1,:) = Node_Coordinate(iNo_Row_Start,:);
        for k = 1 : Num_n1_n2
            iNo_Row_M = iNo_Row_Start + (j-1)*Num_n1_n2 + k ;
            Node_Coordinate_Radial(1+k,:) = Node_Coordinate(iNo_Row_M,:);
        end
        iNo_Row_End = iNo_Row_Start + Num_n1_n2*2 + j;
        Node_Coordinate_Radial(end,:) = Node_Coordinate(iNo_Row_End,:);
    end
end
%
Element_Node_Radial = zeros( Num_n1_n2+1 , length(Element_Node(1,:)) );
for i = 1 : 1   % 1 : Num_Radial % 榀
    for j = 1 : 1   % 上/下索 1上2下
        iE_Row_Start = 1 + (Num_n1_n2+1) * (i-1) + (Num_n1_n2+1) * Num_Radial * (j-1);
        iE_Row_End = iE_Row_Start + Num_n1_n2;
        Element_Node_Radial = Element_Node( iE_Row_Start : iE_Row_End , :);
    end
end
% 生成找形 APDL文件
oFileName = YH2_Module_FormFinding(...
    Node_Coordinate_Radial, Element_Node_Radial,...
    AREA, EM, MD,...
    F_cr, F_cl, F_p,...
    ANSYS_Mdir, Fext, ERR_TOL, LSsteps,...
    ANSYS_JName, ANSYS_JTitle, ANSYS_iFdir_1);

%%
% 自动调用ANSYS
status = YH_Module_RunANSYS(ANSYS_JName, ANSYS_Mdir, ANSYS_iFdir_1, ANSYS_oFdir);
% 把ANSYS APDL输出结果txt转换为MATLAB的.mat文件
YH2_Module_TXT2MAT(oFileName, ANSYS_Mdir, Fext, DATA_FDir)
