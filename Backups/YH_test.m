%% Generate MGT file
% main M file
% 
% Xu Yi, 2022.5.22

%%
close all; clear; clc;

%% 
addpath(genpath('Func'))        % 搜索路径中加入Func文件夹及其下所有文件夹

%% D1内环端点，D12上弦端点，D17下弦端点
D1 = [86589.4302350000,...
    208336.601512000,...
    45270.4671790000];
D12 = [51526.8986960000,...
    210741.961660000,...
    47520.3353290000];
D17 = [51526.8986960000,...
    210741.961660000,...
    44520.3353290000];

%% 模型 单位: mm
% 节点坐标
Node_Coordinate = [];
Node_Coordinate(1, :) = [1, D1];
Num = 5;
f1 = 400;
for i = 1:Num
    n_temp = interp(D1, D12, Num, i);
    n_temp(3) = interp_para(D1, D12, Num, i, f1);
    Node_Coordinate(i+1, :) = [i+1, n_temp];
end
f2 = -300;
for i = 1:Num
    n_temp = interp(D1, D17, Num, i);
    n_temp(3) = interp_para(D1, D17, Num, i, f2);
    Node_Coordinate(i+Num+1, :) = [i+Num+1, n_temp];
end
Node_Coordinate(12, :) = [12, D12];
Node_Coordinate(13, :) = [17, D17];

% 节点约束
Node_Support = [1, 1, 1, 1;...
    12, 1, 1, 1;...
    17, 1, 1, 1];

% 单元节点
Element_Node = [1, 1, 2;...
    2, 2, 3;...
    3, 3, 4;...
    4, 4, 5;...
    5, 5, 6;...
    6, 6, 12;...
    265, 1, 7;...
    266, 7, 8;...
    267, 8, 9;...
    268, 9, 10;...
    269, 10, 11;...
    270, 11, 17;...
    529, 2, 7;...
    530, 3, 8;...
    531, 4, 9;...
    532, 5, 10;...
    533, 6, 11;];

% 单元属性
Element_Property = [1, 1, 3;...
    2, 1, 3;...
    3, 1, 3;...
    4, 1, 3;...
    5, 1, 3;...
    6, 1, 3;...
    265, 2, 3;...
    266, 2, 3;...
    267, 2, 3;...
    268, 2, 3;...
    269, 2, 3;...
    270, 2, 3;...
    529, 3, 3;...
    530, 3, 3;...
    531, 3, 3;...
    532, 3, 3;...
    533, 3, 3;];

%% ANSYS APDL
fileID = fopen('..\ANSYS\ANSYS_Files\Cable.ansys.txt','w');   % Open or create new file for writing. Discard existing contents, if any.

% 初始化
fprintf(fileID,'FINISH\n');
fprintf(fileID,'/CLEAR\n');
fprintf(fileID,'/FILNAME, Cable, 1\n');
fprintf(fileID,'/TITLE, The Analysis of Cable\n');

% 参数
AREA = pi*100^2/4;  % 索截面面积 mm^2
ISTRAN = 1.0E-2;    % 索初应变
EM = 1.9E5;         % 索弹性模量 N/mm^2
MD = 7850;          % 索质量密度 kg/mm^2
ERR_TOL = 1/1000;   % 误差容许值 mm^2
LSsteps = 20;       % 加载子步数
% 把Element_Property的数据导入APDL同名数组
Row_EP = length(Element_Property(:,1));
Col_EP = length(Element_Property(1,:));
fprintf(fileID,'*DIM, Element_Property, ARRAY, %d, %d\n', Row_EP, Col_EP);
for i = 1 : Row_EP
    for j = 1 : Col_EP
        fprintf(fileID,'Element_Property(%d,%d)=%d\n', i, j, Element_Property(i,j));
    end
end

% 前处理
fprintf(fileID,'!进入前处理\n');
fprintf(fileID,'/PREP7\n');
% 单元类型、材料等 LINK180/CABLE280
% ET, ITYPE, Ename, KOP1, KOP2, KOP3, KOP4, KOP5, KOP6, INOPR
% Defines a local element type from the element library.
fprintf(fileID,'ET, 1, LINK180\n');
% R, NSET, R1, R2, R3, R4, R5, R6
% Defines the element real constants.
fprintf(fileID,'R, 1, %f\n', AREA);
% MP, Lab, MAT, C0, C1, C2, C3, C4
% Defines a linear material property as a constant or a function of temperature.
fprintf(fileID,'MP, EX, 1, %f\n', EM);  % EX: Elastic moduli
fprintf(fileID,'MP, PRXY, 1, 0.3\n');   % PRXY: Major Poisson's ratios
fprintf(fileID,'MP, DENS, 1, %f\n', MD);% DENS: Mass density.
% 节点
% *DIM, Par, Type, IMAX, JMAX, KMAX, Var1, Var2, Var3, CSYSID 
% Defines an array parameter and its dimensions.
% 把Node_Coordinate的数据导入APDL同名数组
Row_NC = length(Node_Coordinate(:,1));
Col_NC = length(Node_Coordinate(1,:));
fprintf(fileID,'*DIM, Node_Coordinate, ARRAY, %d, %d\n', Row_NC, Col_NC);
for i = 1 : Row_NC
    for j = 1 : Col_NC
        fprintf(fileID,'Node_Coordinate(%d,%d)=%d\n', i, j, Node_Coordinate(i,j));
    end
end
for i = 1 : length(Node_Coordinate(:,1))
    iNo_N = Node_Coordinate(i,1);
    iX = Node_Coordinate(i,2);
    iY = Node_Coordinate(i,3);
    iZ = Node_Coordinate(i,4);
    % N, NODE, X, Y, Z, THXY, THYZ, THZX
    % Defines a node.
    fprintf(fileID,'N, %d, %f, %f, %f\n', iNo_N, iX, iY, iZ);
end
% 单元
% 把Element_Node的数据导入APDL同名数组
Row_EN = length(Element_Node(:,1));
Col_EN = length(Element_Node(1,:));
fprintf(fileID,'*DIM, Element_Node, ARRAY, %d, %d\n', Row_EN, Col_EN);
for i = 1 : Row_EN
    for j = 1 : Col_EN
        fprintf(fileID,'Element_Node(%d,%d)=%d\n', i, j, Element_Node(i,j));
    end
end
for i = 1 : Row_EN
    iNo_E = Element_Node(i,1);
    iNo_N1 = Element_Node(i,2);
    iNo_N2 = Element_Node(i,3);
    % EN, IEL, I, J, K, L, M, N, O, P
    % Defines an element by its number and node connectivity.
    fprintf(fileID,'EN, %d, %d, %d\n', iNo_E, iNo_N1, iNo_N2);
end
% 约束
% 逐点去约束法：先把所有节点都约束，逐步去掉恢复各节点约束，迭代求解
% 额外约束
for i = 1 : length(Node_Coordinate(:,1))
    iNo_N = Node_Coordinate(i,1);
    for j = 1 : length(Element_Node(:,1))
        if iNo_N == Element_Node(j,1)
            continue;
        end
    end
    fprintf(fileID,'D, %d, UX\n', iNo_N);
    fprintf(fileID,'D, %d, UY\n', iNo_N);
    fprintf(fileID,'D, %d, UZ\n', iNo_N);
end
% 支座
% 把Node_Support的数据导入APDL同名数组
Row_NS = length(Node_Support(:,1));
Col_NS = length(Node_Support(1,:));
fprintf(fileID,'*DIM, Node_Support, ARRAY, %d, %d\n', Row_NS, Col_NS);
for i = 1 : Row_NS
    for j = 1 : Col_NS
        fprintf(fileID,'Node_Support(%d,%d)=%d\n', i, j, Node_Support(i,j));
    end
end
for i = 1 : length(Node_Support(:,1))
    iNo_N = Node_Support(i,1);
    UX_bool = Node_Support(i,2);
    UY_bool = Node_Support(i,3);
    UZ_bool = Node_Support(i,4);
    % D, Node, Lab, VALUE, VALUE2, NEND, NINC, Lab2, Lab3, Lab4, Lab5, Lab6
    % Defines degree-of-freedom constraints at nodes.
    if UX_bool == 1
        fprintf(fileID,'D, %d, UX\n', iNo_N);
    end
    if UY_bool == 1
        fprintf(fileID,'D, %d, UY\n', iNo_N);
    end
    if UZ_bool == 1
        fprintf(fileID,'D, %d, UZ\n', iNo_N);
    end
end
% 初应变
% INISTATE, Action, Val1, Val2, Val3, Val4, Val5, Val6, Val7, Val8, Val9 
% Defines initial-state data and parameters.
fprintf(fileID,'INISTATE, SET, DTYP, EPEL\n');  % Strain data
% ESEL, Type, Item, Comp, VMIN, VMAX, VINC, KABS
% Selects a subset of elements.
fprintf(fileID,'ESEL, ALL\n');  % 选中所有单元
% INISTATE, DEFINE, ID, EINT, KLAYER, PARMINT, Cxx, Cyy, Czz, Cxy, Cyz, Cxz
fprintf(fileID,'INISTATE, DEFINE, , , , , %f\n', ISTRAN);
fprintf(fileID,'EPEL1 = %f\n', ISTRAN); % 定义起始节点单元1的固定应变值
% 退出模块
fprintf(fileID,'FINISH\n');

% 求解 (迭代)
fprintf(fileID,'!逐点去约束法(迭代)\n');

%%% 循环 %%%
% *DO, Par(循环变量名，如I), IVAL(起始值), FVAL(终止值), INC(步长)
% Defines the beginning of a do-loop.
iNo_N_des_Start = 6;
iNo_N_des_End = 2;
iNo_E_des1_Start = 6;
iNo_E_des2_Start = 5;
iNo_E_des3_Start = 533;
fprintf(fileID,'*DO, I, 1, %d, 1\n', iNo_N_des_Start-iNo_N_des_End+1);

fprintf(fileID,'iNo_N_des = %d-I\n', iNo_N_des_Start+1);
fprintf(fileID,'iNo_E_des1 = %d-I+1\n', iNo_E_des1_Start);
fprintf(fileID,'iNo_E_des2 = %d-I+1\n', iNo_E_des2_Start);
fprintf(fileID,'iNo_E_des3 = %d-I+1\n', iNo_E_des3_Start);

fprintf(fileID,'/PREP7\n'); % 进入前处理模块
% 删除某点约束
% DDELE, NODE, Lab, NEND, NINC, Rkey
% Deletes degree-of-freedom constraints.
fprintf(fileID,'DDELE, iNo_N_des, ALL\n');  % 删除目标节点假想约束
fprintf(fileID,'FINISH\n');

%%% 循环 %%%
fprintf(fileID,'Flag = 9\n');
% Loops repeatedly through the next *ENDDO command.
% 1 表示永远循环。 除非语句中有跳出循环命令(如IF里的EXIT)
fprintf(fileID,'*DOWHILE, Flag\n');
%%% 最多循环9次。 % 注释掉下面这行，相当于Flag = 9 ＞ 0，会永远循环除非IF里的EXIT结束
fprintf(fileID,'Flag = Flag - 1\n');
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
fprintf(fileID,'*CFOPEN, USUM, txt, , APPEND\n');  % *CFOPEN, Fname, Ext, --, Loc
% Writes data to a file in a formatted sequence.
fprintf(fileID,'*VWRITE, USUM\n');  % *VWRITE, Par1, Par2,...
% (3f8.4)表示3个参数都是用(f8.4)格式输出，或者用('f8.4','f8.4','f8.4')单个表示.
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
fprintf(fileID,'*CFOPEN, EPEL, txt, , APPEND\n');  % *CFOPEN, Fname, Ext, --, Loc
fprintf(fileID,'*VWRITE, iNo_E_des1, EPEL1\n'); % *VWRITE, Par1, Par2,...
fprintf(fileID,'(F4.0,E16.4)\n');                % Fortran格式描述符(此行在命令行输入会报错，只能直接读取文件执行)
fprintf(fileID,'*VWRITE, iNo_E_des2, EPEL2\n'); % *VWRITE, Par1, Par2,...
fprintf(fileID,'(F4.0,E16.4)\n');                % Fortran格式描述符(此行在命令行输入会报错，只能直接读取文件执行)
fprintf(fileID,'*VWRITE, iNo_E_des3, EPEL3\n'); % *VWRITE, Par1, Par2,...
fprintf(fileID,'(F4.0,E16.4)\n');                % Fortran格式描述符(此行在命令行输入会报错，只能直接读取文件执行)
fprintf(fileID,'*CFCLOS\n');

% 提取单元2应变(弦索2)(即下一个计算节点的单元1)，固定并迭代求得其余2个单元 在节点位置不变时 的平衡应变
fprintf(fileID,'/POST1\n'); % 进入后处理模块
fprintf(fileID,'ETABLE, REFL\n');   % 重填单元表
fprintf(fileID,'*GET, EPEL1, ELEM, iNo_E_des2, ETAB, EPELT\n');    % 提取单元2应变(弦索2)(即下一个计算节点的单元1)
fprintf(fileID,'FINISH\n');

fprintf(fileID,'*ENDDO\n'); % 结束循环，激活新循环

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
