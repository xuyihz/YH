%% Transfer APDL to MGT file
%
%
% Xu Yi, 2022.6.19

%%
close all; clear; clc;

%% 读取APDL文件数据
fileID = fopen('..\..\ANSYS\ANSYS_Files\3.SelfStress.ansys.txt','r');   % Open file for reading.

% 初始化
tline = '1';
para_data = zeros(5,1); % 参数数据
node_data = []; % 节点数据
element_data = [];  % 单元数据
support_data = [];  % 约束数据
element_init_data = []; % 初应力数据
% 读取文件数据
while tline ~= -1   % If the file is empty and contains only the end-of-file marker, then fgetl returns tline as a numeric value -1.
    C = strsplit(tline, ',');   % 在指定分隔符处拆分字符串或字符向量
    switch string(C{1}) % 判断每行的第一个字符串
        case 'ET'
            if double(string(C{3}(end-2:end))) == 180   % 最后三位为180
                para_data(1) = 1;   % 1定义为索
            end
        case 'R'
            para_data(2) = double(string(C{3}));    % 面积 mm^2
        case 'MP'
            switch string(C{2})
                case ' EX'
                    para_data(3) = double(string(C{4}));    % 弹性模量 N/mm^2
                case ' PRXY'
                    para_data(4) = double(string(C{4}));    % 泊松比
                case ' DENS'
                    para_data(5) = double(string(C{4}));    % 密度 kg/m^3
            end
        case 'N'
            node_data_temp = node_data;
            node_temp(1) = double(string(C{2}));    % 节点号
            node_temp(2) = double(string(C{3}));    % 节点坐标X
            node_temp(3) = double(string(C{4}));    % 节点坐标Y
            node_temp(4) = double(string(C{5}));    % 节点坐标Z
            node_data = [node_data_temp; node_temp];
        case 'EN'
            element_data_temp = element_data;
            element_temp(1) = double(string(C{2})); % 单元号
            element_temp(2) = double(string(C{3})); % 单元节点号1
            element_temp(3) = double(string(C{4})); % 单元节点号2
            element_data = [element_data_temp; element_temp];
        case 'D'
            switch string(C{3})
                case ' UX'
                    support_data_temp = support_data;
                    support_temp(1) = double(string(C{2})); % 约束单元号
                    support_temp(2) = 1;    % X向约束。对应MGT为100000
                    support_data = [support_data_temp; support_temp];
                case ' UY'
                    support_data_temp = support_data;
                    support_temp(1) = double(string(C{2})); % 约束单元号
                    support_temp(2) = 2;    % Y向约束。对应MGT为010000
                    support_data = [support_data_temp; support_temp];
                case ' UZ'
                    support_data_temp = support_data;
                    support_temp(1) = double(string(C{2})); % 约束单元号
                    support_temp(2) = 3;    % Z向约束。对应MGT为001000
                    support_data = [support_data_temp; support_temp];
            end
        case 'INISTATE'
            switch string(C{2})
                case ' DEFINE'
                    element_init_data_temp = element_init_data;
                    element_init_temp(1) = double(string(C{3})); % 初应力单元号
                    element_init_temp(2) = double(string(C{7})); % 初应力值
                    element_init_data = [element_init_data_temp; element_init_temp];
            end
    end
    tline = fgetl(fileID);  % 读取文件中的行，并删除换行符
end
fclose('all');
% 合并数据 element_data & element_init_data
element_data_temp = element_data;
element_data = [element_data_temp, zeros(length(element_data(:, 1)), 1)];
for i = 1:length(element_data(:, 1))
    for j = 1:length(element_init_data(:, 1))
        if element_data(i, 1) == element_init_data(j, 1)
            element_data(i, 4) = element_init_data(j, 2);
            break
        end
    end
end

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
D = sqrt( para_data(2) * 4 / pi() );
fprintf(fileID,'*SECTION    ; Section\n');
fprintf(fileID,'; iSEC, TYPE, SNAME, [OFFSET], bSD, bWE, SHAPE, [DATA1], [DATA2]                    ; 1st line - DB/USER\n; iSEC, TYPE, SNAME, [OFFSET], bSD, bWE, SHAPE, BLT, D1, ..., D8, iCEL              ; 1st line - VALUE\n;       AREA, ASy, ASz, Ixx, Iyy, Izz                                               ; 2nd line\n;       CyP, CyM, CzP, CzM, QyB, QzB, PERI_OUT, PERI_IN, Cy, Cz                     ; 3rd line\n;       Y1, Y2, Y3, Y4, Z1, Z2, Z3, Z4, Zyy, Zzz                                    ; 4th line\n; iSEC, TYPE, SNAME, [OFFSET], bSD, bWE, SHAPE, ELAST, DEN, POIS, POIC, SF, THERMAL ; 1st line - SRC\n;       D1, D2, [SRC]                                                               ; 2nd line\n; iSEC, TYPE, SNAME, [OFFSET], bSD, bWE, SHAPE, 1, DB, NAME1, NAME2, D1, D2         ; 1st line - COMBINED\n; iSEC, TYPE, SNAME, [OFFSET], bSD, bWE, SHAPE, 2, D11, D12, D13, D14, D15, D21, D22, D23, D24\n; iSEC, TYPE, SNAME, [OFFSET2], bSD, bWE, SHAPE, iyVAR, izVAR, STYPE                ; 1st line - TAPERED\n;       DB, NAME1, NAME2                                                            ; 2nd line(STYPE=DB)\n;       [DIM1], [DIM2]                                                              ; 2nd line(STYPE=USER)\n;       D11, D12, D13, D14, D15, D16, D17, D18                                      ; 2nd line(STYPE=VALUE)\n;       AREA1, ASy1, ASz1, Ixx1, Iyy1, Izz1                                         ; 3rd line(STYPE=VALUE)\n;       CyP1, CyM1, CzP1, CzM1, QyB1, QzB1, PERI_OUT1, PERI_IN1, Cy1, Cz1           ; 4th line(STYPE=VALUE)\n;       Y11, Y12, Y13, Y14, Z11, Z12, Z13, Z14, Zyy1, Zyy2                          ; 5th line(STYPE=VALUE)\n;       D21, D22, D23, D24, D25, D26, D27, D28                                      ; 6th line(STYPE=VALUE)\n;       AREA2, ASy2, ASz2, Ixx2, Iyy2, Izz2                                         ; 7th line(STYPE=VALUE)\n;       CyP2, CyM2, CzP2, CzM2, QyB2, QzB2, PERI_OUT2, PERI_IN2, Cy2, Cz2           ; 8th line(STYPE=VALUE)\n;       Y21, Y22, Y23, Y24, Z21, Z22, Z23, Z24, Zyy2, Zzz2                          ; 9th line(STYPE=VALUE)\n; [DATA1] : 1, DB, NAME or 2, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10\n; [DATA2] : CCSHAPE or iCEL or iN1, iN2\n; [SRC]  : 1, DB, NAME1, NAME2 or 2, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, iN1, iN2\n; [DIM1], [DIM2] : D1, D2, D3, D4, D5, D6, D7, D8\n; [OFFSET] : OFFSET, iCENT, iREF, iHORZ, HUSER, iVERT, VUSER\n; [OFFSET2]: OFFSET, iCENT, iREF, iHORZ, HUSERI, HUSERJ, iVERT, VUSERI, VUSERJ\n');
fprintf(fileID,'1, DBUSER, D');
fprintf(fileID,'%d, CC, 0, 0, 0, 0, 0, 0, YES, NO, SR , 2, ', D);
fprintf(fileID,'%d, 0, 0, 0, 0, 0, 0, 0, 0, 0\n', D);
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
ELE_iPRO = 1;
ELE_ANGLE = 0;
ELE_iSUB = 3;
for i = 1:length(element_data(:,1))
    % 初张力   F = E*ε*A
    TENSTR_F = para_data(3) * element_data(i, 4) * para_data(2) / 1000; % mm->m /1000
    fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d, %d, 1\n',...
        element_data(i, 1), ELE_TYPE, ELE_iMAT, ELE_iPRO,...
        element_data(i, 2), element_data(i, 3),...    % 单元的两个节点号
        ELE_ANGLE, ELE_iSUB, TENSTR_F);
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
