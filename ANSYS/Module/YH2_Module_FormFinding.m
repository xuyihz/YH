%% Generate APDL file
% Form Finding
% 迭代 更新单元应变(并保证第一个单元应变为初始应变，其余单元应变为计算结果)
% 迭代 更新节点Z坐标(X、Y坐标不变)
% 迭代判断也仅评价Z坐标是否稳定
% 未考虑X、Y实际有一点变形
% ANSYS APDL file
% Xu Yi, 2022.7.10

%%
function oFileName = YH2_Module_FormFinding(...
    Node_Coordinate, Element_Node,...
    AREA, EM, MD,...
    F_cr, F_cl, F_p,...
    ANSYS_Mdir, Fext, ERR_TOL, LSsteps,...
    ANSYS_JName, ANSYS_JTitle, FileDir)

%% 参数
% Node_Coordinate: 单榀上/下索的节点坐标
% Element_Node: 单榀上/下索的单元与节点
% AREA, EM, MD: 索 面积/弹性模量/质量密度
% F_cr, F_cl, F_p: 索 径向索各单元的内力/竖向索在节点处对径向索的作用力/作用在节点处的外力
% ANSYS_Mdir, ANSYS_oFdir: ANSYS模型工作目录/ANSYS输出文件
% ERR_TOL: 误差容许值
% ANSYS_JName, ANSYS_JTitle, FileDir
ISTRAN = F_cr / EM / AREA;

%% ANSYS APDL
fileID = fopen(FileDir,'w');   % Open or create new file for writing. Discard existing contents, if any.
% 覆盖之前的文件
FN_NODE = "0.NODE";
FN_ELEM = "0.ELEM";
oFileName = [FN_NODE; FN_ELEM]; % 计算结果输出文件的文件名
FN_USUM = "1.USUM";
FN_UZ = "1.UZ";
FN_EPEL = "2.EPEL";
FileDir_temp = strcat(ANSYS_Mdir, '\', FN_NODE, '.', Fext);
fileID_temp = fopen(FileDir_temp,'w');   % Open or create new file for writing. Discard existing contents, if any.
fclose(fileID_temp);
FileDir_temp = strcat(ANSYS_Mdir, '\', FN_ELEM, '.', Fext);
fileID_temp = fopen(FileDir_temp,'w');   % Open or create new file for writing. Discard existing contents, if any.
fclose(fileID_temp);
FileDir_temp = strcat(ANSYS_Mdir, '\', FN_USUM, '.', Fext);
fileID_temp = fopen(FileDir_temp,'w');   % Open or create new file for writing. Discard existing contents, if any.
fclose(fileID_temp);
FileDir_temp = strcat(ANSYS_Mdir, '\', FN_UZ, '.', Fext);
fileID_temp = fopen(FileDir_temp,'w');   % Open or create new file for writing. Discard existing contents, if any.
fclose(fileID_temp);
FileDir_temp = strcat(ANSYS_Mdir, '\', FN_EPEL, '.', Fext);
fileID_temp = fopen(FileDir_temp,'w');   % Open or create new file for writing. Discard existing contents, if any.
fclose(fileID_temp);

% 【初始化】
fprintf(fileID,'FINISH\n');
fprintf(fileID,'/CLEAR\n');
fprintf(fileID,'/FILNAME, %s\n', ANSYS_JName);
fprintf(fileID,'/TITLE, %s\n', ANSYS_JTitle);

% 【前处理】
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

% 【建模】
% 节点
% 定义数组
% *DIM, Par, Type, IMAX, JMAX, KMAX, Var1, Var2, Var3, CSYSID
fprintf(fileID,'*DIM, iZ_ARR, ARRAY, %d\n', length(Node_Coordinate(:,1))-2);    % 定义中间节点Z坐标数组
for i = 2 : length(Node_Coordinate(:,1))-1
    iZ = Node_Coordinate(i,4);
    fprintf(fileID,'iZ_ARR(%d) = %f\n', i-1, iZ);
end
for i = 1 : length(Node_Coordinate(:,1))
    iN_N = Node_Coordinate(i,1);
    iX = Node_Coordinate(i,2);
    iY = Node_Coordinate(i,3);
    iZ = Node_Coordinate(i,4);
    % N, NODE, X, Y, Z, THXY, THYZ, THZX
    % Defines a node.
    fprintf(fileID,'N, %d, %f, %f, %f\n', iN_N, iX, iY, iZ);
end
% 单元
for i = 1 : length(Element_Node(:,1))
    iE_N = Element_Node(i,1);
    iNo_N1 = Element_Node(i,2);
    iNo_N2 = Element_Node(i,3);
    % EN, IEL, I, J, K, L, M, N, O, P
    % Defines an element by its number and node connectivity.
    fprintf(fileID,'EN, %d, %d, %d\n', iE_N, iNo_N1, iNo_N2);
end
% 支座
iN_N = Node_Coordinate(1,1);   % 约束第一点
fprintf(fileID,'D, %d, UX\n', iN_N);
fprintf(fileID,'D, %d, UY\n', iN_N);
fprintf(fileID,'D, %d, UZ\n', iN_N);
iN_N = Node_Coordinate(end,1); % 约束最后一点
fprintf(fileID,'D, %d, UX\n', iN_N);
fprintf(fileID,'D, %d, UY\n', iN_N);
fprintf(fileID,'D, %d, UZ\n', iN_N);
% 去掉两端(即支座)节点数据
Node_Coordinate_M = Node_Coordinate(2:end-1,:);

% 【荷载】
% 初应变
% INISTATE, Action, Val1, Val2, Val3, Val4, Val5, Val6, Val7, Val8, Val9
% Defines initial-state data and parameters.
fprintf(fileID,'INISTATE, SET, DTYP, EPEL\n');  % Strain data
% ESEL, Type, Item, Comp, VMIN, VMAX, VINC, KABS
% Selects a subset of elements.
fprintf(fileID,'ESEL, ALL\n');  % 选中所有单元
% INISTATE, DEFINE, ID, EINT, KLAYER, PARMINT, Cxx, Cyy, Czz, Cxy, Cyz, Cxz
for i = 1 : length(Element_Node(:,1))
    iE_N = Element_Node(i,1);
    fprintf(fileID,'INISTATE, DEFINE, %d, , , , %f\n', iE_N, ISTRAN(i));
end
% 自重
% ACEL, ACEL_X, ACEL_Y, ACEL_Z
% Specifies the linear acceleration of the global Cartesian reference frame for the analysis.
fprintf(fileID,'ACEL, , , 9.8\n');  % 定义重力加速度(自重)
% 荷载
% F, NODE, Lab, VALUE, VALUE2, NEND, NINC
% Specifies force loads at nodes.
for i = 1 : length(Node_Coordinate_M(:,1))
    iN_N = Node_Coordinate_M(i,1);
    F_clp = F_cl(i)+F_p(i); % 竖索反力+外荷载
    fprintf(fileID,'F, %d, FZ, %f\n', iN_N, F_clp);
end
% 退出模块
fprintf(fileID,'FINISH\n');

% 【求解】
fprintf(fileID,'/SOLU\n');              % 进入求解模块
fprintf(fileID,'ANTYPE, STATIC\n');     % Perform a static analysis.
fprintf(fileID,'NLGEOM, ON\n');         % Includes large-deflection effects in a static or full transient analysis.
fprintf(fileID,'NSUBST, %d\n', LSsteps);% Specifies the number of substeps to be taken this load step.
fprintf(fileID,'OUTRES, ALL, LAST\n');  % 输出结果
fprintf(fileID,'SOLVE\n');  % 求解
fprintf(fileID,'FINISH\n'); % 退出模块

% 定义单元表
% ETABLE, Lab(名称), Item(提取项), Comp, Option
% Fills a table of element values for further processing.
fprintf(fileID,'/POST1\n'); % 进入后处理模块
fprintf(fileID,'ETABLE, EPELT, LEPEL, 1\n');    % 定义单元表: 应变 (需要计算后才有应变可以提取)
fprintf(fileID,'FINISH\n'); % 退出模块
% 定义数组
% *DIM, Par, Type, IMAX, JMAX, KMAX, Var1, Var2, Var3, CSYSID
fprintf(fileID,'*DIM, UZ_ARR, ARRAY, %d\n', length(Node_Coordinate_M(:,1)));    % 定义节点Z方向位移数组
fprintf(fileID,'*DIM, EPEL_ARR, ARRAY, %d\n', length(Element_Node(:,1)));     % 定义单元应变数组

% 【循环始】
fprintf(fileID,'Flag = 9\n');
% Loops repeatedly through the next *ENDDO command.
% 1 表示永远循环。 除非语句中有跳出循环命令(如IF里的EXIT)
fprintf(fileID,'*DOWHILE, Flag\n');
%%% 最多循环9次。 % 注释掉下面这行，相当于Flag = 9 ＞ 0，会永远循环除非IF里的EXIT结束
% fprintf(fileID,'Flag = Flag - 1\n');

% 【后处理】
fprintf(fileID,'/POST1\n'); % 进入后处理模块
% 初始化
fprintf(fileID,'UZ_ALL = 0\n');
fprintf(fileID,'ETABLE, REFL\n');   % 重填单元表
for i = 1 : length(Element_Node(:,1))
    iE_N = Element_Node(i,1);
    fprintf(fileID,'*GET, EPEL_ARR(%d), ELEM, %d, ETAB, EPELT\n', i, iE_N);    % 提取单元应变
end
% USUM
% Opens a "command" file.
fprintf(fileID,'*CFOPEN, %s, %s, , APPEND\n', FN_USUM, Fext);  % *CFOPEN, Fname, Ext, --, Loc
for i = 1 : length(Node_Coordinate_M(:,1))
    iN_N = Node_Coordinate_M(i,1);
    fprintf(fileID,'NODEID = %d\n', iN_N);    % 提取节点总位移
    % *GET, Par, Entity, ENTNUM, Item1, IT1NUM, Item2, IT2NUM
    fprintf(fileID,'*GET, USUM, NODE, %d, U, SUM\n', iN_N);    % 提取节点总位移

    % Writes data to a file in a formatted sequence.
    fprintf(fileID,'*VWRITE, NODEID, USUM\n');  % *VWRITE, Par1, Par2,...
    % (3F8.4)表示3个参数都是用(F8.4)格式输出，或者用(F8.4,F8.4,F8.4)单个表示.
    fprintf(fileID,'%%I, %%G\n');         % Fortran格式描述符(此行在命令行输入会报错，只能直接读取文件执行)
end
% Writes data to a file in a formatted sequence.
fprintf(fileID,'*VWRITE\n');  % *VWRITE, Par1, Par2,...
fprintf(fileID,'\n');   % 每组迭代的数据之间空一行
% Closes the "command" file.
fprintf(fileID,'*CFCLOS\n');
% UZ
% Opens a "command" file.
fprintf(fileID,'*CFOPEN, %s, %s, , APPEND\n', FN_UZ, Fext);  % *CFOPEN, Fname, Ext, --, Loc
for i = 1 : length(Node_Coordinate_M(:,1))
    iN_N = Node_Coordinate_M(i,1);
    fprintf(fileID,'NODEID = %d\n', iN_N);    % 提取节点Z位移
    % *GET, Par, Entity, ENTNUM, Item1, IT1NUM, Item2, IT2NUM
    fprintf(fileID,'*GET, UZ, NODE, %d, U, Z\n', iN_N);    % 提取节点总位移
    fprintf(fileID,'UZ_ALL = UZ_ALL + UZ\n');

    % Writes data to a file in a formatted sequence.
    fprintf(fileID,'*VWRITE, NODEID, UZ\n');  % *VWRITE, Par1, Par2,...
    % (3F8.4)表示3个参数都是用(F8.4)格式输出，或者用(F8.4,F8.4,F8.4)单个表示.
    fprintf(fileID,'%%I, %%G\n');         % Fortran格式描述符(此行在命令行输入会报错，只能直接读取文件执行)
end
% Writes data to a file in a formatted sequence.
fprintf(fileID,'*VWRITE\n');  % *VWRITE, Par1, Par2,...
fprintf(fileID,'\n');   % 每组迭代的数据之间空一行
% Closes the "command" file.
fprintf(fileID,'*CFCLOS\n');
% EPEL
% Opens a "command" file.
fprintf(fileID,'*CFOPEN, %s, %s, , APPEND\n', FN_EPEL, Fext);  % *CFOPEN, Fname, Ext, --, Loc
for i = 1 : length(Element_Node(:,1))
    iE_N = Element_Node(i,1);
    fprintf(fileID,'ELEID = %d\n', iE_N);    % 提取节点总位移
    fprintf(fileID,'EPEL_TEMP = EPEL_ARR(%d)\n', i);
    % Writes data to a file in a formatted sequence.
    fprintf(fileID,'*VWRITE, ELEID, EPEL_TEMP\n');  % *VWRITE, Par1, Par2,...
    % (3F8.4)表示3个参数都是用(F8.4)格式输出，或者用(F8.4,F8.4,F8.4)单个表示.
    %  “C” format descriptors
    % The normal descriptors are %I for integer data, %G for double precision data, %C for alphanumeric character data, and %/ for a line break
    fprintf(fileID,'%%I, %%G\n');         % Fortran格式描述符(此行在命令行输入会报错，只能直接读取文件执行)
end
% Writes data to a file in a formatted sequence.
fprintf(fileID,'*VWRITE\n');  % *VWRITE, Par1, Par2,...
fprintf(fileID,'\n');   % 每组迭代的数据之间空一行
% Closes the "command" file.
fprintf(fileID,'*CFCLOS\n');
% 更新Z坐标数据
for i = 1 : length(Node_Coordinate_M(:,1))
    iN_N = Node_Coordinate_M(i,1);
    fprintf(fileID,'*GET, UZ_ARR(%d), NODE, %d, U, Z\n', i, iN_N);    % 提取节点Z位移
    % 更新Z坐标数据
    fprintf(fileID,'iZ_ARR(%d) = iZ_ARR(%d) + UZ_ARR(%d)\n', i, i, i);
end
% 退出模块
fprintf(fileID,'FINISH\n');

% 【循环判断】
% 控制节点坐标与原节点相同
fprintf(fileID,'*IF, abs(UZ_ALL), LT, %f, EXIT\n', ERR_TOL);   % 如果误差小于容许值，则跳出循环

% 【更新】
% 节点坐标
fprintf(fileID,'!更新 节点坐标/单元应变\n');
fprintf(fileID,'/PREP7\n');
for i = 1 : length(Node_Coordinate_M(:,1))
    iN_N = Node_Coordinate_M(i,1);
    iX = Node_Coordinate_M(i,2);
    iY = Node_Coordinate_M(i,3);
    % N, NODE, X, Y, Z, THXY, THYZ, THZX
    % Defines a node.
    fprintf(fileID,'N, %d, %f, %f, iZ_ARR(%d)\n', iN_N, iX, iY, i);
end
% 单元应变
fprintf(fileID,'INISTATE, SET, DTYP, EPEL\n');  % Strain data
for i = 1 : length(Element_Node(:,1))
    iE_N = Element_Node(i,1);
    if i == 1
        fprintf(fileID,'INISTATE, DEFINE, %d, , , , %f\n', iE_N, ISTRAN(i));
    else
        fprintf(fileID,'INISTATE, DEFINE, %d, , , , EPEL_ARR(%d)\n', iE_N, i);
    end
end
% 退出模块
fprintf(fileID,'FINISH\n');

% 【求解】
fprintf(fileID,'/SOLU\n');              % 进入求解模块
fprintf(fileID,'ANTYPE, STATIC\n');     % Perform a static analysis.
fprintf(fileID,'NLGEOM, ON\n');         % Includes large-deflection effects in a static or full transient analysis.
fprintf(fileID,'NSUBST, %d\n', LSsteps);% Specifies the number of substeps to be taken this load step.
fprintf(fileID,'OUTRES, ALL, LAST\n');  % 输出结果
fprintf(fileID,'SOLVE\n');  % 求解
fprintf(fileID,'FINISH\n'); % 退出模块

% 【循环终】
fprintf(fileID,'*ENDDO\n'); % 结束循环，激活新循环

% 【输出】
% 节点编号/坐标
% Opens a "command" file.
fprintf(fileID,'*CFOPEN, %s, %s, , APPEND\n', FN_NODE, Fext);  % *CFOPEN, Fname, Ext, --, Loc
for i = 1 : length(Node_Coordinate(:,1))
    iN_N = Node_Coordinate(i,1);
    iX = Node_Coordinate(i,2);
    iY = Node_Coordinate(i,3);
    if i == 1 || i == length(Node_Coordinate(:,1))  % 支座处Z坐标
        fprintf(fileID,'iZ_TEMP = %f\n', Node_Coordinate(i,4));
    else    % 中间更新的Z坐标
        fprintf(fileID,'iZ_TEMP = iZ_ARR(%d)\n', i-1);
    end
    fprintf(fileID,'*VWRITE, %d, %f, %f, iZ_TEMP\n', iN_N, iX, iY);  % *VWRITE, Par1, Par2,...
    %  “C” format descriptors
    % The normal descriptors are %I for integer data, %G for double precision data, %C for alphanumeric character data, and %/ for a line break
    fprintf(fileID,'%%I, %%G, %%G, %%G\n');
end
% Closes the "command" file.
fprintf(fileID,'*CFCLOS\n');
% 单元编号/应变
% Opens a "command" file.
fprintf(fileID,'*CFOPEN, %s, %s, , APPEND\n', FN_ELEM, Fext);  % *CFOPEN, Fname, Ext, --, Loc
for i = 1 : length(Element_Node(:,1))
    iE_N = Element_Node(i,1);
    fprintf(fileID,'EPEL_TEMP = EPEL_ARR(%d)\n', i);
    fprintf(fileID,'*VWRITE, %d, EPEL_TEMP\n', iE_N);  % *VWRITE, Par1, Par2,...
    %  “C” format descriptors
    % The normal descriptors are %I for integer data, %G for double precision data, %C for alphanumeric character data, and %/ for a line break
    fprintf(fileID,'%%I, %%G\n');
end
% Closes the "command" file.
fprintf(fileID,'*CFCLOS\n');

%%
fclose('all');
end
