%% Generate APDL file
% Form-Finding
% ANSYS APDL file
% run ANSYS in batch mode (Maybe)
% Xu Yi, 2022.5.29

%%
close all; clear; clc;

%% 
addpath(genpath('Func'))        % 搜索路径中加入Func文件夹及其下所有文件夹

%%
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
load('../Data/YH_ANSYS.mat',... % 数据文件位置
    'EPEL_T',...            % 单榀上索自应力模态(应变)
    'EPEL_B');              % 更新的(与上索一致)单榀下索自应力模态(应变)

%% ANSYS APDL
fileID = fopen('..\..\ANSYS\ANSYS_Files\3.Form-finding.ansys.txt','w');   % Open or create new file for writing. Discard existing contents, if any.

%%
% 把EPEL_T的数据导入APDL同名数组
Row_E = length(EPEL_T(:,1));
Col_E = length(EPEL_T(1,:));
fprintf(fileID,'*DIM, EPEL_T, ARRAY, %d, %d\n', Row_E, Col_E);
for i = 1 : Row_E
    for j = 1 : Col_E
        fprintf(fileID,'EPEL_T(%d,%d)=%d\n', i, j, EPEL_T(i,j));
    end
end
% 把EPEL_B的数据导入APDL同名数组
Row_E = length(EPEL_B(:,1));
Col_E = length(EPEL_B(1,:));
fprintf(fileID,'*DIM, EPEL_B, ARRAY, %d, %d\n', Row_E, Col_E);
for i = 1 : Row_E
    for j = 1 : Col_E
        fprintf(fileID,'EPEL_B(%d,%d)=%d\n', i, j, EPEL_B(i,j));
    end
end

%%
ISTRAN = 1.0E-2;    % 索初应变
ERR_TOL = 1/1000;   % 误差容许值 mm^2
LSsteps = 20;       % 加载子步数

%%
fprintf(fileID,'/PREP7\n'); % 进入前处理模块
% 初应变
% INISTATE, Action, Val1, Val2, Val3, Val4, Val5, Val6, Val7, Val8, Val9 
% Defines initial-state data and parameters.
fprintf(fileID,'INISTATE, SET, DTYP, EPEL\n');  % Strain data
% ESEL, Type, Item, Comp, VMIN, VMAX, VINC, KABS
% Selects a subset of elements.
fprintf(fileID,'ESEL, ALL\n');  % 选中所有单元
% INISTATE, DEFINE, ID, EINT, KLAYER, PARMINT, Cxx, Cyy, Czz, Cxy, Cyz, Cxz
fprintf(fileID,'INISTATE, DEFINE, , , , , %f\n', ISTRAN);
fprintf(fileID,'FINISH\n');

% 求解 (迭代)
fprintf(fileID,'!逐点去约束法(迭代)\n');

%%% 循环 %%% 榀数 I : Num_Radial
% *DO, Par(循环变量名，如I), IVAL(起始值), FVAL(终止值), INC(步长)
% Defines the beginning of a do-loop.
fprintf(fileID,'*DO, I, 1, %d, 1\n', Num_Radial);

% 内环 第一个四杆单元的 节点 和 4个单元 的编号
fprintf(fileID,'iNo_N_des = 1+%d*(I-1)\n', Node_Itvl);
fprintf(fileID,'iNo_E_des1 = (%d+1)*(I-1)+1\n', Num_n1_n2);
fprintf(fileID,'iNo_E_des2 = iNo_E_des1+(%d+1)*%d\n', Num_n1_n2, Num_Radial);
fprintf(fileID,'*IF, I, EQ, 1, THEN\n');    % if i == 1
fprintf(fileID,'iNo_E_des3 = %d+%d-1\n', iEL_Ring, Num_Radial);
fprintf(fileID,'*ELSE\n');    % else
fprintf(fileID,'iNo_E_des3 = %d-2+I\n', iEL_Ring);
fprintf(fileID,'*ENDIF\n');    % end
fprintf(fileID,'iNo_E_des4 = %d-1+I\n', iEL_Ring);

% 初始化
% 保证每点开始时，四杆单元的单元1、单元2的应变为EPEL_T、EPEL_B读入
% 保证每点开始时，四杆单元的单元3、单元4的应变为ISTRAN
fprintf(fileID,'EPEL1 = EPEL_T(%d*3*I-1,2)\n', Num_n1_n2);
fprintf(fileID,'EPEL2 = EPEL_B(%d*3*I-1,2)\n', Num_n1_n2);
fprintf(fileID,'EPEL3 = %f\n', ISTRAN);
fprintf(fileID,'EPEL4 = %f\n', ISTRAN);

fprintf(fileID,'/PREP7\n'); % 进入前处理模块
% 删除某点约束
% DDELE, NODE, Lab, NEND, NINC, Rkey
% Deletes degree-of-freedom constraints.
fprintf(fileID,'DDELE, iNo_N_des, ALL\n');  % 删除目标节点假想约束
fprintf(fileID,'FINISH\n');

%%% 循环 %%% 力迭代法
fprintf(fileID,'Flag = 9\n');
% Loops repeatedly through the next *ENDDO command.
% 1 表示永远循环。 除非语句中有跳出循环命令(如IF里的EXIT)
fprintf(fileID,'*DOWHILE, Flag\n');
%%% 最多循环9次。 % 注释掉下面这行，相当于Flag = 9 ＞ 0，会永远循环除非IF里的EXIT结束
% fprintf(fileID,'Flag = Flag - 1\n');
% 
fprintf(fileID,'/SOLU\n');              % 进入求解模块
fprintf(fileID,'ANTYPE, 0\n');          % Perform a static analysis.
fprintf(fileID,'NLGEOM, ON\n');         % Includes large-deflection effects in a static or full transient analysis.
fprintf(fileID,'SSTIF, ON\n');          % 应力刚度
fprintf(fileID,'NSUBST, %d\n', LSsteps);% Specifies the number of substeps to be taken this load step.
fprintf(fileID,'OUTRES, ALL, LAST\n');  % 输出结果
%
fprintf(fileID,'SOLVE\n');  % 求解
fprintf(fileID,'FINISH\n'); % 退出模块
%
fprintf(fileID,'/POST1\n'); % 进入后处理模块
fprintf(fileID,'*GET, USUM, NODE, iNo_N_des, U, SUM\n');    % 提取节点总位移

%%% 读写文件
% Opens a "command" file.
fprintf(fileID,'*CFOPEN, 1.USUM, txt, , APPEND\n');  % *CFOPEN, Fname, Ext, --, Loc
% Writes data to a file in a formatted sequence.
fprintf(fileID,'*VWRITE, USUM\n');  % *VWRITE, Par1, Par2,...
% (3F8.4)表示3个参数都是用(F8.4)格式输出，或者用(F8.4,F8.4,F8.4)单个表示.
fprintf(fileID,'(F8.4)\n');         % Fortran格式描述符(此行在命令行输入会报错，只能直接读取文件执行)
% Closes the "command" file.
fprintf(fileID,'*CFCLOS\n');

% 
% ETABLE, Lab(名称), Item(提取项), Comp, Option
% Fills a table of element values for further processing.
fprintf(fileID,'ETABLE, EPELT, LEPEL, 1\n');    % 定义单元表: 应变 (需要计算后才有应变可以提取)
fprintf(fileID,'*GET, EPEL3, ELEM, iNo_E_des3, ETAB, EPELT\n');    % 提取单元3应变(环索1)
fprintf(fileID,'*GET, EPEL4, ELEM, iNo_E_des4, ETAB, EPELT\n');    % 提取单元4应变(环索2)

fprintf(fileID,'FINISH\n'); % 退出模块
%
fprintf(fileID,'/PREP7\n'); % 进入前处理模块
% 更新初始应变
fprintf(fileID,'INISTATE, SET, DTYP, EPEL\n');  % Strain data
% INISTATE, DEFINE, ID, EINT, KLAYER, PARMINT, Cxx, Cyy, Czz, Cxy, Cyz, Cxz
fprintf(fileID,'EPEL1 = EPEL_T(%d*3*I-1,2)\n', Num_n1_n2);
fprintf(fileID,'EPEL2 = EPEL_B(%d*3*I-1,2)\n', Num_n1_n2);
fprintf(fileID,'INISTATE, DEFINE, iNo_E_des1, , , , EPEL1\n');
fprintf(fileID,'INISTATE, DEFINE, iNo_E_des2, , , , EPEL2\n');
fprintf(fileID,'INISTATE, DEFINE, iNo_E_des3, , , , EPEL3\n');
fprintf(fileID,'INISTATE, DEFINE, iNo_E_des4, , , , EPEL4\n');

fprintf(fileID,'FINISH\n'); % 退出模块
% 控制节点坐标与原节点相同
fprintf(fileID,'*IF, USUM, LT, %f, EXIT\n', ERR_TOL);   % 如果误差小于容许值，则跳出循环
fprintf(fileID,'*ENDDO\n'); % 结束循环，激活新循环

%%% 读写文件
fprintf(fileID,'*CFOPEN, 3EPEL_Ring, txt, , APPEND\n');  % *CFOPEN, Fname, Ext, --, Loc
fprintf(fileID,'*VWRITE, iNo_E_des1, EPEL1\n'); % *VWRITE, Par1, Par2,...
fprintf(fileID,'(F4.0,E16.4)\n');                % Fortran格式描述符(此行在命令行输入会报错，只能直接读取文件执行)
fprintf(fileID,'*VWRITE, iNo_E_des2, EPEL2\n'); % *VWRITE, Par1, Par2,...
fprintf(fileID,'(F4.0,E16.4)\n');                % Fortran格式描述符(此行在命令行输入会报错，只能直接读取文件执行)
fprintf(fileID,'*VWRITE, iNo_E_des3, EPEL3\n'); % *VWRITE, Par1, Par2,...
fprintf(fileID,'(F4.0,E16.4)\n');                % Fortran格式描述符(此行在命令行输入会报错，只能直接读取文件执行)
fprintf(fileID,'*VWRITE, iNo_E_des4, EPEL4\n'); % *VWRITE, Par1, Par2,...
fprintf(fileID,'(F4.0,E16.4)\n');                % Fortran格式描述符(此行在命令行输入会报错，只能直接读取文件执行)
fprintf(fileID,'*CFCLOS\n');

% 加回约束
fprintf(fileID,'/PREP7\n'); % 进入前处理模块
fprintf(fileID,'D, iNo_N_des, UX\n');
fprintf(fileID,'D, iNo_N_des, UY\n');
fprintf(fileID,'D, iNo_N_des, UZ\n');
fprintf(fileID,'FINISH\n');

fprintf(fileID,'*ENDDO\n'); % 结束 榀数 循环，激活新循环

%%
fclose('all');

%% 自动调用ANSYS
% ANSYS_dir = "C:\Program Files\ANSYS Inc\v202\ANSYS\bin\winx64\ANSYS202.exe";
% ANSYS_Fdir = "E:\项目\2022余杭国际体育中心\计算模型\ANSYS\ANSYS_Files";
% ANSYS_Mdir = "E:\项目\2022余杭国际体育中心\计算模型\ANSYS\Model";
% ANSYS_iFile = "Cable.ansys.txt";
% ANSYS_oFile = "result.out";
% 
% % -b: batch模式; -p: license; -dir: 工作目录; -i: 输入文件; -o: 输出文件
% command = sprintf('"%s" -b -p ane3fl -dir "%s" -i "%s\\%s" -o "%s\\%s"',...
%     ANSYS_dir, ANSYS_Mdir, ANSYS_Fdir, ANSYS_iFile, ANSYS_Fdir, ANSYS_oFile);
% % status = 0 表示成功运行
% status = system(command);
