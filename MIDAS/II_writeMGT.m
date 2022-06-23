%% Transfer APDL to MGT file
% write MGT
%
% Xu Yi, 2022.6.21

%% 读入APDL数据
load('../Data/YH_APDL.mat',...
    'para_data',...
    'node_data',...
    'element_data',...
    'support_data');

%% 读入整体模型MGT参数化数据
load('../Data/YH.mat',...   % 数据文件位置
    'Num_Radial',...        % 榀数
    'Num_n1_n2',...         % n1~n2间的分隔数 (索桁架处)
    'Node_Itvl',...         % 每一榀的节点数
    'iEL_Ring');            % 内环起始单元编号
cable_Ring_num = 7; % 内环索数
cable_ftk = 1770e-3;% 索极限抗拉强度 kN/mm2
cable_f_para = 0.05; % 索设计值系数
cable_f = cable_f_para * cable_ftk; % 索设计控制应力
cable_f_now = element_data(end,4)*para_data(3)/1000;    % 找形后最后一根环索的应力
cable_f_Multi = cable_f / cable_f_now * cable_Ring_num; % 找形后自应力模态下索内力整体增大系数
cable_f_Multi = round(cable_f_Multi, 1);    % 取小数点后一位
% 上索t/下索b/竖索v终止单元号
cable_t_Num_End = ( Num_n1_n2 + 1 ) * Num_Radial;
cable_b_Num_End = ( Num_n1_n2 + 1 ) * Num_Radial *2;
cable_v_Num_End = ( Num_n1_n2 + 1 ) * Num_Radial *2 + Num_n1_n2 * Num_Radial;
% 竖索面积调整系数(相对于找形时的统一截面)
cable_v_para = element_data(cable_v_Num_End,4)*para_data(3)/1000 / cable_f;

%% 写入MGT文件数据
fileID = fopen('YH_cable.mgt','w'); % Open or create new file for writing. Discard existing contents, if any.
% Time
fprintf(fileID,...
    ';---------------------------------------------------------------------------\n'...
    );
fprintf(fileID,';  midas Gen Text(MGT) File.\n');
fprintf(fileID,';  Date : %s\n',datetime('today'));
fprintf(fileID,...
    ';---------------------------------------------------------------------------\n'...
    );
fprintf(fileID,'\n');
% Unit
FORCE = 'KN'; LENGTH = 'MM'; HEAT = 'KJ'; TEMPER = 'C';
fprintf(fileID,'*UNIT    ; Unit System\n');
fprintf(fileID,'; FORCE, LENGTH, HEAT, TEMPER\n');
fprintf(fileID,'   %s, %s, %s, %s\n',FORCE,LENGTH,HEAT,TEMPER);
fprintf(fileID,'\n');
% Material
fprintf(fileID,'*MATERIAL    ; Material\n');
fprintf(fileID,'; iMAT, TYPE, MNAME, SPHEAT, HEATCO, PLAST, TUNIT, bMASS, DAMPRATIO, [DATA1]           ; STEEL, CONC, USER\n; iMAT, TYPE, MNAME, SPHEAT, HEATCO, PLAST, TUNIT, bMASS, DAMPRATIO, [DATA2], [DATA2]  ; SRC\n; [DATA1] : 1, DB, NAME, CODE, USEELAST, ELAST\n; [DATA1] : 2, ELAST, POISN, THERMAL, DEN, MASS\n; [DATA1] : 3, Ex, Ey, Ez, Tx, Ty, Tz, Sxy, Sxz, Syz, Pxy, Pxz, Pyz, DEN, MASS         ; Orthotropic\n; [DATA2] : 1, DB, NAME, CODE, USEELAST, ELAST or 2, ELAST, POISN, THERMAL, DEN, MASS\n');
fprintf(fileID,'   1, USER , Cable             , 0, 0, , C, NO, 0, 2,  %d,   %d,  1.2000e-05, %d,     0\n',...
    para_data(3)/1000, para_data(4), para_data(5)/1e11);
fprintf(fileID,'\n');
% Section
D_temp = sqrt( para_data(2) * 4 / pi() );
D(1) = D_temp;  % 上索
D(2) = D_temp;  % 下索
D(3) = D_temp / 10;  % 竖索
D(4) = D_temp * sqrt(cable_Ring_num);  % 环索
fprintf(fileID,'*SECTION    ; Section\n');
fprintf(fileID,'; iSEC, TYPE, SNAME, [OFFSET], bSD, bWE, SHAPE, [DATA1], [DATA2]                    ; 1st line - DB/USER\n; iSEC, TYPE, SNAME, [OFFSET], bSD, bWE, SHAPE, BLT, D1, ..., D8, iCEL              ; 1st line - VALUE\n;       AREA, ASy, ASz, Ixx, Iyy, Izz                                               ; 2nd line\n;       CyP, CyM, CzP, CzM, QyB, QzB, PERI_OUT, PERI_IN, Cy, Cz                     ; 3rd line\n;       Y1, Y2, Y3, Y4, Z1, Z2, Z3, Z4, Zyy, Zzz                                    ; 4th line\n; iSEC, TYPE, SNAME, [OFFSET], bSD, bWE, SHAPE, ELAST, DEN, POIS, POIC, SF, THERMAL ; 1st line - SRC\n;       D1, D2, [SRC]                                                               ; 2nd line\n; iSEC, TYPE, SNAME, [OFFSET], bSD, bWE, SHAPE, 1, DB, NAME1, NAME2, D1, D2         ; 1st line - COMBINED\n; iSEC, TYPE, SNAME, [OFFSET], bSD, bWE, SHAPE, 2, D11, D12, D13, D14, D15, D21, D22, D23, D24\n; iSEC, TYPE, SNAME, [OFFSET2], bSD, bWE, SHAPE, iyVAR, izVAR, STYPE                ; 1st line - TAPERED\n;       DB, NAME1, NAME2                                                            ; 2nd line(STYPE=DB)\n;       [DIM1], [DIM2]                                                              ; 2nd line(STYPE=USER)\n;       D11, D12, D13, D14, D15, D16, D17, D18                                      ; 2nd line(STYPE=VALUE)\n;       AREA1, ASy1, ASz1, Ixx1, Iyy1, Izz1                                         ; 3rd line(STYPE=VALUE)\n;       CyP1, CyM1, CzP1, CzM1, QyB1, QzB1, PERI_OUT1, PERI_IN1, Cy1, Cz1           ; 4th line(STYPE=VALUE)\n;       Y11, Y12, Y13, Y14, Z11, Z12, Z13, Z14, Zyy1, Zyy2                          ; 5th line(STYPE=VALUE)\n;       D21, D22, D23, D24, D25, D26, D27, D28                                      ; 6th line(STYPE=VALUE)\n;       AREA2, ASy2, ASz2, Ixx2, Iyy2, Izz2                                         ; 7th line(STYPE=VALUE)\n;       CyP2, CyM2, CzP2, CzM2, QyB2, QzB2, PERI_OUT2, PERI_IN2, Cy2, Cz2           ; 8th line(STYPE=VALUE)\n;       Y21, Y22, Y23, Y24, Z21, Z22, Z23, Z24, Zyy2, Zzz2                          ; 9th line(STYPE=VALUE)\n; [DATA1] : 1, DB, NAME or 2, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10\n; [DATA2] : CCSHAPE or iCEL or iN1, iN2\n; [SRC]  : 1, DB, NAME1, NAME2 or 2, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, iN1, iN2\n; [DIM1], [DIM2] : D1, D2, D3, D4, D5, D6, D7, D8\n; [OFFSET] : OFFSET, iCENT, iREF, iHORZ, HUSER, iVERT, VUSER\n; [OFFSET2]: OFFSET, iCENT, iREF, iHORZ, HUSERI, HUSERJ, iVERT, VUSERI, VUSERJ\n');
fprintf(fileID,'1, DBUSER, D'); % 上索
fprintf(fileID,'%d, CC, 0, 0, 0, 0, 0, 0, YES, NO, SR , 2, ', round(D(1)) );
fprintf(fileID,'%d, 0, 0, 0, 0, 0, 0, 0, 0, 0\n', D(1));
fprintf(fileID,'2, DBUSER, D'); % 下索
fprintf(fileID,'%d, CC, 0, 0, 0, 0, 0, 0, YES, NO, SR , 2, ', round(D(2)) );
fprintf(fileID,'%d, 0, 0, 0, 0, 0, 0, 0, 0, 0\n', D(2));
fprintf(fileID,'3, DBUSER, D'); % 竖索
fprintf(fileID,'%d, CC, 0, 0, 0, 0, 0, 0, YES, NO, SR , 2, ', round(D(3)) );
fprintf(fileID,'%d, 0, 0, 0, 0, 0, 0, 0, 0, 0\n', D(3));
fprintf(fileID,'4, DBUSER, D'); % 环索
fprintf(fileID,'%d, CC, 0, 0, 0, 0, 0, 0, YES, NO, SR , 2, ', round(D(4)) );
fprintf(fileID,'%d, 0, 0, 0, 0, 0, 0, 0, 0, 0\n', D(4));
% Model: Nodes
fprintf(fileID,'; Node\n');
fprintf(fileID,'*NODE    ; Nodes\n');
fprintf(fileID,'; iNO, X, Y, Z\n');
for i = 1:length(node_data(:,1))
    fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
        node_data(i, 1), node_data(i, 2), node_data(i, 3), node_data(i, 4));
end
% Model: Elements
fprintf(fileID,'*ELEMENT    ; Elements\n');
fprintf(fileID,'; iEL, TYPE, iMAT, iPRO, iN1, iN2, ANGLE, iSUB, EXVAL, iOPT(EXVAL2) ; Frame  Element\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, ANGLE, iSUB, EXVAL, EXVAL2, bLMT ; Comp/Tens Truss\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, iN3, iN4, iSUB, iWID , LCAXIS    ; Planar Element\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, iN3, iN4, iN5, iN6, iN7, iN8     ; Solid  Element\n');
ELE_TYPE = 'TENSTR';
ELE_iMAT = 1;
ELE_iPRO = [1, 2, 3, 4];    % Section
ELE_ANGLE = 0;
ELE_iSUB = 3;
% 初始化：第一列是单元号，第二列是初拉力(待覆盖)
TENSTR_F = [element_data(:,1), element_data(:,1)];
for i = 1:length(element_data(:,1))
    if element_data(i, 1) <= cable_t_Num_End
        ELE_iPRO_temp = ELE_iPRO(1);    % 上索
    elseif element_data(i, 1) <= cable_b_Num_End
        ELE_iPRO_temp = ELE_iPRO(2);    % 下索
    elseif element_data(i, 1) <= cable_v_Num_End
        ELE_iPRO_temp = ELE_iPRO(3);    % 竖索
    else
        ELE_iPRO_temp = ELE_iPRO(4);    % 环索
    end
    % 初张力   F = E*ε*A
    TENSTR_F(i, 2) = cable_f_Multi * para_data(3) * element_data(i, 4) * para_data(2) / 1000; % mm->m /1000
    fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d, %d, 1\n',...
        element_data(i, 1), ELE_TYPE, ELE_iMAT, ELE_iPRO_temp,...
        element_data(i, 2), element_data(i, 3),...    % 单元的两个节点号
        ELE_ANGLE, ELE_iSUB, TENSTR_F(i, 2));
end
% Model: Supports
fprintf(fileID,'*CONSTRAINT    ; Supports\n');
fprintf(fileID,'; NODE_LIST, CONST(Dx,Dy,Dz,Rx,Ry,Rz), GROUP\n');
for i = 1:length(support_data(:,1))
    switch support_data(i, 2)
        case 1
            CONSTRAINT = '100000';
        case 2
            CONSTRAINT = '010000';
        case 3
            CONSTRAINT = '001000';
    end
    fprintf(fileID,'   %d, %s, \n',...
        support_data(i, 1), CONSTRAINT);
end
% File End
fprintf(fileID,'*ENDDATA');
fclose('all');

%% 保存初拉力数据
save('../Data/YH_APDL.mat', 'TENSTR_F', '-append');
