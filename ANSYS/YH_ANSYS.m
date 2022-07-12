%% Generate APDL file
% 
% ANSYS APDL file
% run ANSYS in batch mode
% Xu Yi, 2022.5.29

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

%% 1.形态判断
Time_1_name = '1.形态判断';   Time_1 = string(datetime);
% disp(Time_1_name); disp(Time_1);
% YH_Module_Shape_Judge(Node_Coordinate, Num_Radial, Node_Itvl);

%% 2.单榀(Radial)自应力模态分析
Time_2_name = '2.单榀(Radial)自应力模态分析';   Time_2 = string(datetime);
disp(Time_2_name);    disp(Time_2);
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

% 生成APDL文件中Model部分
YH_Module_Model(Node_Coordinate, Node_Support,...
    Element_Node, Element_Property,...
    AREA, EM, MD,...    % 下一行最后的1是SupportSwitch,表示全部添加约束
    ANSYS_JName, ANSYS_JTitle, ANSYS_iFdir_1, 1);
% 生成APDL文件中SOLU部分
[EPEL_T_FN, EPEL_B_FN, Fext] = YH_Module_Solu_Radial(Num_Radial, Num_n1_n2, Node_Itvl,...
    ISTRAN, ERR_TOL, LSsteps,...
    ANSYS_iFdir_1);
% 自动调用ANSYS
status = YH_Module_RunANSYS(ANSYS_JName, ANSYS_Mdir, ANSYS_iFdir_1, ANSYS_oFdir);
% 把ANSYS APDL输出结果txt转换为MATLAB的.mat文件
YH_Module_EPEL(Num_Radial, Num_n1_n2,...
    ANSYS_Mdir, EPEL_T_FN, EPEL_B_FN, Fext, EPEL_FDir);

%% 3.下索找形
Time_3_name = '3.下索找形';   Time_3 = string(datetime);
disp(Time_3_name);  disp(Time_3);
load('../Data/YH_ANSYS.mat',... % 数据文件位置
    'EPEL_T',...            % 单榀上索自应力模态(应变)
    'EPEL_B');              % 更新的(与上索一致)单榀下索自应力模态(应变)
ANSYS_iFdir_2 = '..\..\ANSYS\ANSYS_Files\2.Form-finding.ansys.txt';
Node_Coordinate_Update = YH_Module_FormFinding(Node_Coordinate, Element_Node,...
    Num_Radial, Num_n1_n2, Node_Itvl,...
    EPEL_T, EPEL_B, -f1,...
    AREA, EM, MD,...
    ISTRAN, ERR_TOL, LSsteps,...
    ANSYS_JName, ANSYS_JTitle, ANSYS_iFdir_2,...
    ANSYS_Mdir, ANSYS_oFdir, EPEL_FDir);
save('../Data/YH.mat','Node_Coordinate_Update','-append');

%% 4.更新节点坐标后的单榀(Radial)自应力模态分析
%%%%%%%%% 后期修改3，使得计算完3后，新的单榀的应变已保存。可直接进入5
%%%%%%%%% 这样就不用本节
Time_4_name = '4.更新节点坐标后的单榀(Radial)自应力模态分析';   Time_4 = string(datetime);
disp(Time_4_name);    disp(Time_4);
% 生成APDL文件中Model部分
YH_Module_Model(Node_Coordinate_Update, Node_Support,...
    Element_Node, Element_Property,...
    AREA, EM, MD,...    % 下一行最后的1是SupportSwitch,表示全部添加约束
    ANSYS_JName, ANSYS_JTitle, ANSYS_iFdir_1, 1);
% 生成APDL文件中SOLU部分
[EPEL_T_FN, EPEL_B_FN, Fext] = YH_Module_Solu_Radial(Num_Radial, Num_n1_n2, Node_Itvl,...
    ISTRAN, ERR_TOL, LSsteps,...
    ANSYS_iFdir_1);
% 自动调用ANSYS
status = YH_Module_RunANSYS(ANSYS_JName, ANSYS_Mdir, ANSYS_iFdir_1, ANSYS_oFdir);
% 把ANSYS APDL输出结果txt转换为MATLAB的.mat文件
YH_Module_EPEL(Num_Radial, Num_n1_n2,...
    ANSYS_Mdir, EPEL_T_FN, EPEL_B_FN, Fext, EPEL_FDir);

%% 5.整体模型自应力模态下分析
Time_5_name = '5.整体模型自应力模态下分析';   Time_5 = string(datetime);
disp(Time_5_name);  disp(Time_5);
load('../Data/YH.mat',...       % 数据文件位置
    'Node_Coordinate_Update');  % [节点编号, X坐标, Y坐标, Z坐标]
load('../Data/YH_ANSYS.mat',... % 数据文件位置
    'EPEL_T',...            % 单榀上索自应力模态(应变)
    'EPEL_B');              % 更新的(与上索一致)单榀下索自应力模态(应变)
ANSYS_iFdir_3 = '..\..\ANSYS\ANSYS_Files\3.SelfStress.ansys.txt';
co_EPEL_Base = 0.003;  % 以第一个内环节点环索左节点为基准应变 (最大应变约为0.005对应强度设计值)
% 整体自应力模态
[EPEL_Radial,  EPEL_Ring] = YH_Module_SelfStress(Node_Coordinate_Update,...
    Num_Radial, Num_n1_n2, iEL_Ring, EPEL_T, EPEL_B, co_EPEL_Base, EPEL_FDir);
% 生成APDL文件中Model部分
YH_Module_Model(Node_Coordinate_Update, Node_Support,...
    Element_Node, Element_Property,...
    AREA, EM, MD,...    % 下一行最后的0是SupportSwitch,表示仅支座添加约束
    ANSYS_JName, ANSYS_JTitle, ANSYS_iFdir_3, 0);
YH_Module_Solu_Self(Num_Radial, EPEL_Radial, EPEL_Ring, LSsteps,...
    ANSYS_iFdir_3);

%% 运行完毕发邮件通知我
Time_6_name = '发邮件';   Time_6 = string(datetime);
disp(Time_6_name); disp(Time_6);
addpath(genpath('E:\Yi\Cloud\Coding\Matlab\SendMail'))
subject = 'ANSYS运行完毕';
message = strcat('ANSYS运行完毕',...
    Time_0_name, Time_0,...
    Time_1_name, Time_1,...
    Time_2_name, Time_2,...
    Time_3_name, Time_3,...
    Time_4_name, Time_4,...
    Time_5_name, Time_5,...
    Time_6_name, Time_6);
attachments = 0;
SendMailto163(subject, message, attachments);

% %% 运行完毕后自动关机
% system('shutdown.exe -s -t 300');
