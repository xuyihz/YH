%% Generate Comparison file
% 1. run this .m file
% 2. run I_readAPDL.m
% 3. run II_writeMGT.m
% 4. Update initial stress(Ring=10000kN) in MIDAS
% Xu Yi, 2022.7.6

%%
close all; clear; clc;

%%
addpath '..\Module';

%%
% 其中环向索仅导入了内环
load('../../Data/YH.mat',...   % 数据文件位置
    'Node_Coordinate',...   % [节点编号, X坐标, Y坐标, Z坐标]
    'Node_Support',...      % [节点编号, X约束, Y约束, Z约束]
    'Element_Node',...      % [单元编号, 节点编号1, 节点编号2]
    'Element_Property',...  % [单元编号, 索直径编号, 索弹性模量编号]
    'Num_Radial',...        % 榀数
    'Num_n1_n2',...         % n1~n2间的分隔数 (索桁架处)
    'Node_Itvl',...         % 每一榀的节点数
    'iEL_Ring');            % 内环起始单元编号
load('../../Data/YH_ANSYS.mat',... % 数据文件位置
    'EPEL_T',...            % 单榀上索自应力模态(应变)
    'EPEL_B');              % 更新的(与上索一致)单榀下索自应力模态(应变)
% 参数
AREA = pi*100^2/4;  % 索截面面积 mm^2
EM = 1.9E5;         % 索弹性模量 N/mm^2
MD = 7850;          % 索质量密度 kg/mm^2
LSsteps = 20;       % 加载子步数
co_EPEL_Base = 0.003;  % 以第一个内环节点环索左节点为基准应变 (最大应变约为0.005对应强度设计值)
% Job Name / Job Title
ANSYS_JName = 'Cable';
ANSYS_JTitle = 'The Analysis of Cable';
ANSYS_iFdir_3 = '..\..\..\ANSYS\ANSYS_Files\3.SelfStress.ansys.txt';
% MATLAB数据文件路径
EPEL_FDir = '../../Data/YH_ANSYS.mat'; % 应变(EPEL)数据
% 整体自应力模态
[EPEL_Radial,  EPEL_Ring] = YH_Module_SelfStress(Node_Coordinate,...
    Num_Radial, Num_n1_n2, iEL_Ring, EPEL_T, EPEL_B, co_EPEL_Base, EPEL_FDir);
% 生成APDL文件中Model部分
YH_Module_Model(Node_Coordinate, Node_Support,...
    Element_Node, Element_Property,...
    AREA, EM, MD,...    % 下一行最后的0是SupportSwitch,表示仅支座添加约束
    ANSYS_JName, ANSYS_JTitle, ANSYS_iFdir_3, 0);
YH_Module_Solu_Self(Num_Radial, EPEL_Radial, EPEL_Ring, LSsteps,...
    ANSYS_iFdir_3);

%% 生成环索MGT文件(有压杆时可能需要)
fileID = fopen('../../MIDAS/YH_cable_Ring.mgt','w'); % Open or create new file for writing. Discard existing contents, if any.
% Model: Sections
fprintf(fileID,'*SECTION    ; Section\n');
fprintf(fileID,'; iSEC, TYPE, SNAME, [OFFSET], bSD, bWE, SHAPE, [DATA1], [DATA2]                    ; 1st line - DB/USER\n; iSEC, TYPE, SNAME, [OFFSET], bSD, bWE, SHAPE, BLT, D1, ..., D8, iCEL              ; 1st line - VALUE\n;       AREA, ASy, ASz, Ixx, Iyy, Izz                                               ; 2nd line\n;       CyP, CyM, CzP, CzM, QyB, QzB, PERI_OUT, PERI_IN, Cy, Cz                     ; 3rd line\n;       Y1, Y2, Y3, Y4, Z1, Z2, Z3, Z4, Zyy, Zzz                                    ; 4th line\n; iSEC, TYPE, SNAME, [OFFSET], bSD, bWE, SHAPE, ELAST, DEN, POIS, POIC, SF, THERMAL ; 1st line - SRC\n;       D1, D2, [SRC]                                                               ; 2nd line\n; iSEC, TYPE, SNAME, [OFFSET], bSD, bWE, SHAPE, 1, DB, NAME1, NAME2, D1, D2         ; 1st line - COMBINED\n; iSEC, TYPE, SNAME, [OFFSET], bSD, bWE, SHAPE, 2, D11, D12, D13, D14, D15, D21, D22, D23, D24\n; iSEC, TYPE, SNAME, [OFFSET2], bSD, bWE, SHAPE, iyVAR, izVAR, STYPE                ; 1st line - TAPERED\n;       DB, NAME1, NAME2                                                            ; 2nd line(STYPE=DB)\n;       [DIM1], [DIM2]                                                              ; 2nd line(STYPE=USER)\n;       D11, D12, D13, D14, D15, D16, D17, D18                                      ; 2nd line(STYPE=VALUE)\n;       AREA1, ASy1, ASz1, Ixx1, Iyy1, Izz1                                         ; 3rd line(STYPE=VALUE)\n;       CyP1, CyM1, CzP1, CzM1, QyB1, QzB1, PERI_OUT1, PERI_IN1, Cy1, Cz1           ; 4th line(STYPE=VALUE)\n;       Y11, Y12, Y13, Y14, Z11, Z12, Z13, Z14, Zyy1, Zyy2                          ; 5th line(STYPE=VALUE)\n;       D21, D22, D23, D24, D25, D26, D27, D28                                      ; 6th line(STYPE=VALUE)\n;       AREA2, ASy2, ASz2, Ixx2, Iyy2, Izz2                                         ; 7th line(STYPE=VALUE)\n;       CyP2, CyM2, CzP2, CzM2, QyB2, QzB2, PERI_OUT2, PERI_IN2, Cy2, Cz2           ; 8th line(STYPE=VALUE)\n;       Y21, Y22, Y23, Y24, Z21, Z22, Z23, Z24, Zyy2, Zzz2                          ; 9th line(STYPE=VALUE)\n; [DATA1] : 1, DB, NAME or 2, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10\n; [DATA2] : CCSHAPE or iCEL or iN1, iN2\n; [SRC]  : 1, DB, NAME1, NAME2 or 2, D1, D2, D3, D4, D5, D6, D7, D8, D9, D10, iN1, iN2\n; [DIM1], [DIM2] : D1, D2, D3, D4, D5, D6, D7, D8\n; [OFFSET] : OFFSET, iCENT, iREF, iHORZ, HUSER, iVERT, VUSER\n; [OFFSET2]: OFFSET, iCENT, iREF, iHORZ, HUSERI, HUSERJ, iVERT, VUSERI, VUSERJ\n');
D5 = 10;
fprintf(fileID,'5, DBUSER, D');
fprintf(fileID,'%d, CC, 0, 0, 0, 0, 0, 0, YES, NO, SR , 2, ', D5);
fprintf(fileID,'%d, 0, 0, 0, 0, 0, 0, 0, 0, 0\n', D5);
% Model: Elements
fprintf(fileID,'*ELEMENT    ; Elements\n');
fprintf(fileID,'; iEL, TYPE, iMAT, iPRO, iN1, iN2, ANGLE, iSUB, EXVAL, iOPT(EXVAL2) ; Frame  Element\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, ANGLE, iSUB, EXVAL, EXVAL2, bLMT ; Comp/Tens Truss\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, iN3, iN4, iSUB, iWID , LCAXIS    ; Planar Element\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, iN3, iN4, iN5, iN6, iN7, iN8     ; Solid  Element\n');
ELE_TYPE = 'TENSTR';
ELE_iMAT = 1;
ELE_iPRO = 5;    % Section 竖索
ELE_ANGLE = 0;
ELE_iSUB = 3;
TENSTR = 0;
iEL = Element_Node(end,1);  % 初始化单元编号
for k = 1 : 2   % 上下环
    iNO = 1;
    for i = 1 : Num_Radial % 榀
        iN1 = iNO + (2-k) + (k-1)*(Num_n1_n2+1);    % k=1,+1; k=2,+Num_n1_n2+1
        for j = 1 : Num_n1_n2
            if i == Num_Radial
                iN2 = iN1 + Node_Itvl - Num_Radial*Node_Itvl;
            else
                iN2 = iN1 + Node_Itvl;
            end
            iEL = iEL+1;
            fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d, %d, 1\n',...
                iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
                iN1, iN2,...    % 单元的两个节点号
                ELE_ANGLE, ELE_iSUB, TENSTR);
            iN1 = iN1 + 1;
        end
        iNO = iNO + Node_Itvl;
    end
end
fclose('all');
