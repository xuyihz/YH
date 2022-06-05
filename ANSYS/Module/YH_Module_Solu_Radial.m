%% Generate APDL file
% Build /SOLU
% ANSYS APDL file
% run ANSYS in batch mode (Maybe)
% Xu Yi, 2022.5.24

%%
function [EPEL_T_FN, EPEL_B_FN, Fext] = YH_Module_Solu_Radial(Num_Radial, Num_n1_n2, Node_Itvl,...
    ISTRAN, ERR_TOL, LSsteps,...
    FileDir)

%%
% % 其中环向索仅导入了内环
% load('../Data/YH.mat',...   % 数据文件位置
%     'Node_Coordinate',...   % [节点编号, X坐标, Y坐标, Z坐标]
%     'Node_Support',...      % [节点编号, X约束, Y约束, Z约束]
%     'Element_Node',...      % [单元编号, 节点编号1, 节点编号2]
%     'Element_Property',...  % [单元编号, 索直径编号, 索弹性模量编号]
%     'Num_Radial',...        % 榀数
%     'Num_n1_n2',...         % n1~n2间的分隔数 (索桁架处)
%     'Node_Itvl',...         % 每一榀的节点数
%     'iEL_Ring');            % 内环起始单元编号
EPEL_T_FN = '2.1EPEL_T';    % 上索应变输出文件名
EPEL_B_FN = '2.2EPEL_B';    % 下索应变输出文件名
Fext = 'txt';               % 文件后缀

%% ANSYS APDL
fileID = fopen(FileDir,'a');   % Open or create new file for writing. Append data to the end of the file.

%% 覆盖之前的文件
fprintf(fileID,'/POST1\n'); % 进入后处理模块
fprintf(fileID,'*CFOPEN, 1.USUM, txt\n');  % *CFOPEN, Fname, Ext, --, Loc / Loc:[blank] The existing file will be overwritten.
fprintf(fileID,'*CFCLOS\n');
fprintf(fileID,'*CFOPEN, %s, %s\n', EPEL_T_FN, Fext);  % *CFOPEN, Fname, Ext, --, Loc
fprintf(fileID,'*CFCLOS\n');
fprintf(fileID,'*CFOPEN, %s, %s\n', EPEL_B_FN, Fext);  % *CFOPEN, Fname, Ext, --, Loc
fprintf(fileID,'*CFCLOS\n');
fprintf(fileID,'FINISH\n');

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

%%% 循环 %%% 上下索 J : 2
fprintf(fileID,'*DO, J, 1, %d, 1\n', 2);

% 当前榀 第一个三杆单元的 节点 和 3个单元 的编号
fprintf(fileID,'iNo_N_des = %d+1+%d*(I-1)\n', Num_n1_n2, Node_Itvl);
fprintf(fileID,'iNo_E_des1 = I*(%d+1)\n', Num_n1_n2);
fprintf(fileID,'iNo_E_des2 = iNo_E_des1-1\n');
fprintf(fileID,'iNo_E_des3 = I*%d+(%d+1)*2*%d\n', Num_n1_n2, Num_n1_n2, Num_Radial);

% *IF, VAL1, Oper1, VAL2, Base1, VAL3, Oper2, VAL4, Base2 
% Conditionally causes commands to be read.
fprintf(fileID,'*IF, J, EQ, 1, THEN\n');    % if j == 1
% j == 1 为上索，第一个三杆单元的节点及3个单元不变
fprintf(fileID,'*ELSE\n');    % else
% else 为下索
fprintf(fileID,'iNo_N_des = iNo_N_des+%d\n', Num_n1_n2);
fprintf(fileID,'iNo_E_des1 = iNo_E_des1+(%d+1)*%d\n', Num_n1_n2, Num_Radial);
fprintf(fileID,'iNo_E_des2 = iNo_E_des1-1\n');
fprintf(fileID,'iNo_E_des3 = iNo_E_des3\n');
fprintf(fileID,'*ENDIF\n');    % end

% 保证每榀(上/下索)开始时，第一个三杆单元的单元1的应变为ISTRAN
fprintf(fileID,'EPEL1 = %f\n', ISTRAN); % 定义起始节点单元1的固定应变值

% 保证保证每榀(上/下索)开始时，第一个三杆单元的节点单元编号-1后为起始编号
fprintf(fileID,'iNo_N_des = iNo_N_des+1\n');
fprintf(fileID,'iNo_E_des1 = iNo_E_des1+1\n');
fprintf(fileID,'iNo_E_des2 = iNo_E_des2+1\n');
fprintf(fileID,'iNo_E_des3 = iNo_E_des3+1\n');

%%% 循环 %%% 间隔数 K : Num_n1_n2
fprintf(fileID,'*DO, K, 1, %d, 1\n', Num_n1_n2);

fprintf(fileID,'iNo_N_des = iNo_N_des-1\n');
fprintf(fileID,'iNo_E_des1 = iNo_E_des1-1\n');
fprintf(fileID,'iNo_E_des2 = iNo_E_des2-1\n');
fprintf(fileID,'iNo_E_des3 = iNo_E_des3-1\n');

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
fprintf(fileID,'*GET, EPEL2, ELEM, iNo_E_des2, ETAB, EPELT\n');    % 提取单元2应变(弦索2)
fprintf(fileID,'*GET, EPEL3, ELEM, iNo_E_des3, ETAB, EPELT\n');    % 提取单元3应变(竖索)

fprintf(fileID,'FINISH\n'); % 退出模块
%
fprintf(fileID,'/PREP7\n'); % 进入前处理模块
% 更新初始应变
fprintf(fileID,'INISTATE, SET, DTYP, EPEL\n');  % Strain data
% INISTATE, DEFINE, ID, EINT, KLAYER, PARMINT, Cxx, Cyy, Czz, Cxy, Cyz, Cxz
fprintf(fileID,'INISTATE, DEFINE, iNo_E_des1, , , , EPEL1\n');
fprintf(fileID,'INISTATE, DEFINE, iNo_E_des2, , , , EPEL2\n');
fprintf(fileID,'INISTATE, DEFINE, iNo_E_des3, , , , EPEL3\n');

fprintf(fileID,'FINISH\n'); % 退出模块
% 控制节点坐标与原节点相同
fprintf(fileID,'*IF, USUM, LT, %f, EXIT\n', ERR_TOL);   % 如果误差小于容许值，则跳出循环
fprintf(fileID,'*ENDDO\n'); % 结束循环，激活新循环

%%% 读写文件
fprintf(fileID,'*IF, J, EQ, 1, THEN\n');    % if j == 1
% j == 1 为上索
fprintf(fileID,'*CFOPEN, %s, %s, , APPEND\n', EPEL_T_FN, Fext);  % *CFOPEN, Fname, Ext, --, Loc
fprintf(fileID,'*ELSE\n');    % else
% else 为下索
fprintf(fileID,'*CFOPEN, %s, %s, , APPEND\n', EPEL_B_FN, Fext);  % *CFOPEN, Fname, Ext, --, Loc
fprintf(fileID,'*ENDIF\n');    % end
fprintf(fileID,'*VWRITE, iNo_E_des1, EPEL1\n'); % *VWRITE, Par1, Par2,...
fprintf(fileID,'(F4.0,E16.4)\n');                % Fortran格式描述符(此行在命令行输入会报错，只能直接读取文件执行)
fprintf(fileID,'*VWRITE, iNo_E_des2, EPEL2\n'); % *VWRITE, Par1, Par2,...
fprintf(fileID,'(F4.0,E16.4)\n');                % Fortran格式描述符(此行在命令行输入会报错，只能直接读取文件执行)
fprintf(fileID,'*VWRITE, iNo_E_des3, EPEL3\n'); % *VWRITE, Par1, Par2,...
fprintf(fileID,'(F4.0,E16.4)\n');                % Fortran格式描述符(此行在命令行输入会报错，只能直接读取文件执行)
fprintf(fileID,'*CFCLOS\n');

% 加回约束
fprintf(fileID,'/PREP7\n'); % 进入前处理模块
fprintf(fileID,'D, iNo_N_des, UX\n');
fprintf(fileID,'D, iNo_N_des, UY\n');
fprintf(fileID,'D, iNo_N_des, UZ\n');
fprintf(fileID,'FINISH\n');

% 提取单元2应变(弦索2)(即下一个计算节点的单元1)，固定并迭代求得其余2个单元 在节点位置不变时 的平衡应变
fprintf(fileID,'/POST1\n'); % 进入后处理模块
fprintf(fileID,'ETABLE, REFL\n');   % 重填单元表
fprintf(fileID,'*GET, EPEL1, ELEM, iNo_E_des2, ETAB, EPELT\n');    % 提取单元2应变(弦索2)(即下一个计算节点的单元1)
fprintf(fileID,'FINISH\n');

fprintf(fileID,'*ENDDO\n'); % 结束 间隔数 循环，激活新循环

fprintf(fileID,'*ENDDO\n'); % 结束 上下索 循环，激活新循环

fprintf(fileID,'*ENDDO\n'); % 结束 榀数 循环，激活新循环

%%
fclose('all');
