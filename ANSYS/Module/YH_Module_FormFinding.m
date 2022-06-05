%% Generate APDL file
% Form-Finding
% ANSYS APDL file
% run ANSYS in batch mode (Maybe)
% Xu Yi, 2022.5.29

%%
function Node_Coordinate = YH_Module_FormFinding(Node_Coordinate, Element_Node,...
    Num_Radial, Num_n1_n2, Node_Itvl,...
    EPEL_T, EPEL_B, f2,...
    AREA, EM, MD,...
    ISTRAN, ERR_TOL, LSsteps,...
    ANSYS_JName, ANSYS_JTitle, FileDir,...
    ANSYS_Mdir, ANSYS_oFdir, EPEL_FDir)
%%
% 其中环向索仅导入了内环
% load('../Data/YH.mat',...   % 数据文件位置
%     'Node_Coordinate',...   % [节点编号, X坐标, Y坐标, Z坐标]
%     'Node_Support',...      % [节点编号, X约束, Y约束, Z约束]
%     'Element_Node',...      % [单元编号, 节点编号1, 节点编号2]
%     'Element_Property',...  % [单元编号, 索直径编号, 索弹性模量编号]
%     'Num_Radial',...        % 榀数
%     'Num_n1_n2',...         % n1~n2间的分隔数 (索桁架处)
%     'Node_Itvl',...         % 每一榀的节点数
%     'iEL_Ring');            % 内环起始单元编号
% load('../Data/YH_ANSYS.mat',... % 数据文件位置
%     'EPEL_T',...            % 单榀上索自应力模态(应变)
%     'EPEL_B');              % 更新的(与上索一致)单榀下索自应力模态(应变)
EPEL_T_FN = '2.3.1EPEL_T_temp'; % 上索应变输出文件名
EPEL_B_FN = '2.3.2EPEL_B_temp'; % 下索应变输出文件名
Fext = 'txt';                   % 文件后缀

%% 建索桁架单榀模型
for i = 1 : Num_Radial
    Node_C_Itvl = Num_n1_n2 * 2 + 3;    % 索桁架处单榀节点数
    Node_Co_Part ...
        = Node_Coordinate( ( (i-1)*Node_C_Itvl+1 ) : i*Node_C_Itvl, : );  % 目标榀的节点
    Element_Node_Part ...
        = [Element_Node( (1+(Num_n1_n2+1)*(i-1)):((Num_n1_n2+1)*i), : );...
        Element_Node( (1+(Num_n1_n2+1)*(i-1+Num_Radial)):((Num_n1_n2+1)*(i+Num_Radial)), : );...
        Element_Node( (1+Num_n1_n2*(i-1)+(Num_n1_n2+1)*Num_Radial*2):(Num_n1_n2*i+(Num_n1_n2+1)*Num_Radial*2), : )];

    %% 更新下索节点
    EPEL_T_P = EPEL_T(Num_n1_n2*3*i-1, 2);  % 内环节点边第一上索单元应变
    EPEL_B_P = EPEL_B(Num_n1_n2*3*i-1, 2);  % 内环节点边第一下索节点应变
    if i ~= 1   % 环索左节点坐标
        N_temp = Node_C_Itvl * (i-2) + 1;
    else
        N_temp = Node_C_Itvl * (Num_Radial-1) + 1;
    end
    Node_Co_Rl = Node_Coordinate(N_temp, 2:4);
    if i ~= Num_Radial  % 环索右节点坐标
        N_temp = Node_C_Itvl * i + 1;
    else
        N_temp = 1;
    end
    Node_Co_Rr = Node_Coordinate(N_temp, 2:4);
    Node_Co_C = Node_Co_Part(1, 2:4);               % 内环节点坐标
    Node_Co_Ct = Node_Co_Part(2, 2:4);              % 上索节点坐标
    Node_Co_Cb = Node_Co_Part(2+Num_n1_n2, 2:4);    % 下索节点坐标
    Node_Co_nCb = YH_Module_Shape(EPEL_T_P, EPEL_B_P,...
        Node_Co_Rl, Node_Co_Rr, Node_Co_C, Node_Co_Ct, Node_Co_Cb); % 内环节点边第一下索节点新坐标

    % 此处增加while循环 当Node_Co_Cb和Node_Co_nCb重合时跳出循环
    while norm(Node_Co_Cb - Node_Co_nCb) > ERR_TOL

        Node_Co_Cb_Start = Node_Co_para(Node_Co_C, Node_Co_nCb, Num_n1_n2, f2);

        % 更新下索节点
        for j = 1 : Num_n1_n2
            n_temp = interp(Node_Co_C, Node_Co_Cb_Start, Num_n1_n2, j);
            n_temp(3) = interp_para(Node_Co_C, Node_Co_Cb_Start, Num_n1_n2, j, f2);
            Node_Co_Part(Num_n1_n2+1+j, 2:4) = n_temp;
        end
        Node_Co_Part(end, 2:4) = Node_Co_Cb_Start;

        %% ANSYS APDL
        fileID = fopen(FileDir,'w');   % Open or create new file for writing. Discard existing contents, if any.

        %% ANSYS APDL 建模
        % 初始化
        fprintf(fileID,'FINISH\n');
        fprintf(fileID,'/CLEAR\n');
        fprintf(fileID,'/FILNAME, %s\n', ANSYS_JName);
        fprintf(fileID,'/TITLE, %s\n', ANSYS_JTitle);

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
        Row_NC = length(Node_Co_Part(:,1));
        for j = 1 : Row_NC
            iNo_N = Node_Co_Part(j,1);
            iX = Node_Co_Part(j,2);
            iY = Node_Co_Part(j,3);
            iZ = Node_Co_Part(j,4);
            % N, NODE, X, Y, Z, THXY, THYZ, THZX
            % Defines a node.
            fprintf(fileID,'N, %d, %f, %f, %f\n', iNo_N, iX, iY, iZ);
        end
        % 单元
        Row_EN = length(Element_Node_Part(:,1));
        for j = 1 : Row_EN
            iNo_E = Element_Node_Part(j,1);
            iNo_N1 = Element_Node_Part(j,2);
            iNo_N2 = Element_Node_Part(j,3);
            % EN, IEL, I, J, K, L, M, N, O, P
            % Defines an element by its number and node connectivity.
            fprintf(fileID,'EN, %d, %d, %d\n', iNo_E, iNo_N1, iNo_N2);
        end
        % 约束
        % 逐点去约束法：先把所有节点都约束，逐步去掉恢复各节点约束，迭代求解
        fprintf(fileID,'NSEL, ALL\n');  % 全选节点
        fprintf(fileID,'D, ALL, UX\n');
        fprintf(fileID,'D, ALL, UY\n');
        fprintf(fileID,'D, ALL, UZ\n');
        % 退出模块
        fprintf(fileID,'FINISH\n');

        %% ANSYS APDL 求解
        % 覆盖之前的文件
        fprintf(fileID,'/POST1\n'); % 进入后处理模块
        fprintf(fileID,'*CFOPEN, 1.USUM, txt\n');  % *CFOPEN, Fname, Ext, --, Loc / Loc:[blank] The existing file will be overwritten.
        fprintf(fileID,'*CFCLOS\n');
        fprintf(fileID,'*CFOPEN, %s, %s\n', EPEL_T_FN, Fext);  % *CFOPEN, Fname, Ext, --, Loc
        fprintf(fileID,'*CFCLOS\n');
        fprintf(fileID,'*CFOPEN, %s, %s\n', EPEL_B_FN, Fext);  % *CFOPEN, Fname, Ext, --, Loc
        fprintf(fileID,'*CFCLOS\n');
        fprintf(fileID,'FINISH\n');

        %
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

        %%% 循环 %%% 上下索 J : 2
        fprintf(fileID,'*DO, J, 1, %d, 1\n', 2);

        % 当前榀 第一个三杆单元的 节点 和 3个单元 的编号
        fprintf(fileID,'iNo_N_des = %d+1+%d*(%d-1)\n', Num_n1_n2, Node_Itvl, i);
        fprintf(fileID,'iNo_E_des1 = %d*(%d+1)\n', i, Num_n1_n2);
        fprintf(fileID,'iNo_E_des2 = iNo_E_des1-1\n');
        fprintf(fileID,'iNo_E_des3 = %d*%d+(%d+1)*2*%d\n', i, Num_n1_n2, Num_n1_n2, Num_Radial);

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

        %
        fclose('all');

        %% 自动调用ANSYS
        status = YH_Module_RunANSYS(ANSYS_JName, ANSYS_Mdir, FileDir, ANSYS_oFdir);
        if status ~= 0
            fprintf('ANSYS not good. 第%d榀', i);
        end

        %% 判断是否存在自应力模态，并保存ANSYS输出的EPEL结果至.mat
        EPEL_T_FDir = sprintf('%s\\%s.%s', ANSYS_Mdir, EPEL_T_FN, Fext);
        EPEL_B_FDir = sprintf('%s\\%s.%s', ANSYS_Mdir, EPEL_B_FN, Fext);
        EPEL_T_temp = load(EPEL_T_FDir);   % 单榀上索自应力模态(应变)
        EPEL_B_temp = load(EPEL_B_FDir);   % 单榀下索自应力模态(应变)
        EPEL_T_temp = EPEL_T_temp( (end-Num_n1_n2*3+1):end, : );
        EPEL_B_temp = EPEL_B_temp( (end-Num_n1_n2*3+1):end, : );
        EPEL_T_N = sprintf('EPEL_T_temp');
        EPEL_B_N = sprintf('EPEL_B_temp');

        % 判断是否存在自应力模态，即竖索在上下索结果中的比例是否一致
        Row3 = Num_n1_n2;
        EPEL_T_3 = zeros(Row3,1);
        EPEL_B_3 = zeros(Row3,1);
        EPEL_Coe = zeros(Row3,1);
        for j = 1 : Num_n1_n2   %上下竖索共3根
            Row = j * 3;
            Row3 = j;
            EPEL_T_3(Row3, 1) = EPEL_T_temp(Row, 2);
            EPEL_B_3(Row3, 1) = EPEL_B_temp(Row, 2);
            EPEL_Coe(Row3, 1) = EPEL_B_3(Row3, 1) / EPEL_T_3(Row3, 1);
        end

        % 使竖索在上下索的结果中，结果一致(相应放大或缩小下索数值)
        Cable3_Row = Num_n1_n2 * 3; %上下竖索共3根
        Cable3_Base = EPEL_T_temp(Cable3_Row, 2);    % 竖索在上索的结果
        Cable3_Target = EPEL_B_temp(Cable3_Row, 2);  % 竖索在下索的结果
        for j = 1 : 3 * Num_n1_n2   %上下竖索共3根
            Row = j;
            EPEL_B_temp(Row, 2) = EPEL_B_temp(Row, 2) / Cable3_Target * Cable3_Base;
        end

        % 保存竖索一致的EPEL_T/EPEL_B至.mat
        save(EPEL_FDir, EPEL_T_N);              % 单榀上索自应力模态(应变)
        save(EPEL_FDir, EPEL_B_N, '-append');   % 更新的(与上索一致)单榀下索自应力模态(应变)

        %
        EPEL_T_P = EPEL_T_temp(Num_n1_n2*3-1, 2);  % 内环节点边第一上索单元应变
        EPEL_B_P = EPEL_B_temp(Num_n1_n2*3-1, 2);  % 内环节点边第一下索节点应变
        Node_Co_Cb = Node_Co_Part(2+Num_n1_n2, 2:4);    % 下索节点坐标
        Node_Co_nCb = YH_Module_Shape(EPEL_T_P, EPEL_B_P,...
            Node_Co_Rl, Node_Co_Rr, Node_Co_C, Node_Co_Ct, Node_Co_Cb); % 内环节点边第一下索节点新坐标

    end
    
    Node_Coordinate( ( (i-1)*Node_C_Itvl+1 ) : i*Node_C_Itvl, : ) = Node_Co_Part;
end
end

function Node_Co_Cb_Start = Node_Co_para(Node_Co_C, Node_Co_nCb, Num_n1_n2, f2)
V_C_nCb = Node_Co_nCb - Node_Co_C;                          % C->nCb向量
V_f = [0, 0, - 4 * f2 * Num_n1_n2 / (Num_n1_n2 + 1)^2];     % nCb处垂度向量(抛物线)
Node_Co_Cb_Start = Node_Co_C + (V_C_nCb-V_f) * (Num_n1_n2+1);   % 下索支座端点
end

function x3 = interp(x1, x2, Num, n)
x = (x2(1) - x1(1)) / (Num + 1) * n + x1(1);
y = (x2(2) - x1(2)) / (Num + 1) * n + x1(2);
z = (x2(3) - x1(3)) / (Num + 1) * n + x1(3);
x3 = [x,y,z];
end

function z3 = interp_para(x1, x2, Num, n, f)
% z = -4fx(l-x)/l^2 + c/l*x % z1=0的情况,c=z2-z1
z1 = x1(3); z2 = x2(3);
% x/l = n/(Num + 1)
z3 = -4*f*n*((Num + 1)-n)/(Num + 1)^2 +...   % 垂度
    (z2 - z1) / (Num + 1) * n + z1;         % 两端点
end
