%% Generate APDL file
% Ring Form Finding
% 
% ANSYS APDL file
% Xu Yi, 2022.7.19

%%
function oFileName = YH2_Module_FormFinding_Ring(...
    Node_Coordinate_Ring, Element_Node_Ring, Num_Radial,...
    AREA, INERTIA_M, EM, MD,...
    F_Ring, F_p,...
    ANSYS_Mdir, Fext, ERR_TOL, LSsteps,...
    ANSYS_JName, ANSYS_JTitle, ANSYS_iFdir_1)

%% 参数
% Node_Coordinate_Ring: 内环/中环(合力假想环)的节点坐标
% Element_Node_Ring: 内环/中环(合力假想环)的单元节点关系
% AREA, EM, MD: 索 面积/弹性模量/质量密度
% F_Ring, F_p: 索 环索各单元的内力/作用在径向单元上的外力
% ANSYS_Mdir, ANSYS_oFdir: ANSYS模型工作目录/ANSYS输出文件
% ERR_TOL: 误差容许值
% ANSYS_JName, ANSYS_JTitle, ANSYS_iFdir_1
% 径向单元
AREA_Radial = AREA*2;
EM_Radial = EM*100;
% 环索
AREA_Ring = AREA*7;
ISTRAN_Ring = F_Ring / EM / AREA_Ring;    % 内环初应变

%% ANSYS APDL
fileID = fopen(ANSYS_iFdir_1,'w');   % Open or create new file for writing. Discard existing contents, if any.
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
fprintf(fileID,'\n!进入前处理\n');
fprintf(fileID,'/PREP7\n');
% 单元类型、材料等 LINK180/CABLE280
fprintf(fileID,'\n!ELEMENT TYPE DEFINITIONS\n');
% BEAM188 / LINK180
% ET, ITYPE, Ename, KOP1, KOP2, KOP3, KOP4, KOP5, KOP6, INOPR
% Defines a local element type from the element library.
fprintf(fileID,'ET, 1, BEAM188\n');
fprintf(fileID,'ET, 2, LINK180\n');
fprintf(fileID,'\n!MATERIAL PROPERTIES\n');
% MPTEMP, SLOC, T1, T2, T3, T4, T5, T6
% Defines a temperature table for material properties.
% If all arguments are blank, the temperature table is erased.
fprintf(fileID,'MPTEMP, , , , , , , ,\n');
fprintf(fileID,'MPTEMP, 1, 0\n');
% MPDATA, Lab, MAT, SLOC, C1, C2, C3, C4, C5, C6
% Defines property data to be associated with the temperature table.
fprintf(fileID,'!MAT=1\n');
fprintf(fileID,'MPDATA, EX, 1, , %f\n', EM_Radial); % EX: Elastic moduli
fprintf(fileID,'MPDATA, PRXY, 1, , 0.3\n'); % PRXY: Major Poisson's ratios
fprintf(fileID,'MPDATA, DENS, 1, , %f\n', MD);  % DENS: Mass density.
fprintf(fileID,'!MAT=2\n');
fprintf(fileID,'MPDATA, EX, 2, , %f\n', EM);    % EX: Elastic moduli
fprintf(fileID,'MPDATA, PRXY, 2, , 0\n'); % PRXY: Major Poisson's ratios
fprintf(fileID,'MPDATA, DENS, 2, , %f\n', MD);  % DENS: Mass density.
fprintf(fileID,'\n!SECTION PROPERTIES\n');
% SECTYPE, SECID, Type, Subtype, Name, REFINEKEY
% Associates section type information with a section ID number.
fprintf(fileID,'!SECNUM=1\n');
fprintf(fileID,'SECTYPE, 1, BEAM, CSOLID, BEAM_1\n');
fprintf(fileID,'SECDATA, %f\n', sqrt(AREA_Radial/pi)); % R, N, T
fprintf(fileID,'SECCONTROL, , , , %f\n', MD*AREA_Radial);   % TXZ, -, TXY, ADDMAS
fprintf(fileID,'!SECNUM=2\n');
fprintf(fileID,'SECTYPE, 2, LINK, , CABLE_1\n');
fprintf(fileID,'SECDATA, %f\n', AREA_Ring);
fprintf(fileID,'SECCONTROL, %f\n', MD*AREA_Ring);

% 【建模】
% 节点
fprintf(fileID,'\n!NODE DEFINITIONS\n');
for i = 1 : length(Node_Coordinate_Ring(:,1))
    iN_N = Node_Coordinate_Ring(i,1);
    iX = Node_Coordinate_Ring(i,2);
    iY = Node_Coordinate_Ring(i,3);
%     iZ = Node_Coordinate_Ring(i,4);
    iZ = 0;
    % N, NODE, X, Y, Z, THXY, THYZ, THZX
    % Defines a node.
    fprintf(fileID,'N, %d, %f, %f, %f\n', iN_N, iX, iY, iZ);
end
% 单元
fprintf(fileID,'\n!ELEMENT DEFINITIONS\n');
% 径向单元 BEAM188
fprintf(fileID,'TYPE, 1\n');    % 单元类型
fprintf(fileID,'MAT, 1\n');     % 材料类型
fprintf(fileID,'SECNUM, 1\n');  % 截面
for i = 1 : Num_Radial
    iE_N = Element_Node_Ring(i,1);
    iNo_N1 = Element_Node_Ring(i,2);
    iNo_N2 = Element_Node_Ring(i,3);
    % EN, IEL, I, J, K, L, M, N, O, P
    % Defines an element by its number and node connectivity.
    fprintf(fileID,'EN, %d, %d, %d\n', iE_N, iNo_N1, iNo_N2);
end
% 环向单元 LINK180
fprintf(fileID,'TYPE, 2\n');    % 单元类型
fprintf(fileID,'MAT, 2\n');     % 材料类型
fprintf(fileID,'SECNUM, 2\n');  % 截面
for i = 1 : Num_Radial
    iE_N = Element_Node_Ring(i+Num_Radial,1);
    iNo_N1 = Element_Node_Ring(i+Num_Radial,2);
    iNo_N2 = Element_Node_Ring(i+Num_Radial,3);
    % EN, IEL, I, J, K, L, M, N, O, P
    % Defines an element by its number and node connectivity.
    fprintf(fileID,'EN, %d, %d, %d\n', iE_N, iNo_N1, iNo_N2);
end
% 支座
fprintf(fileID,'\n!BOUNDARY CONDITIONS\n');
for i = 1 : Num_Radial
    iN_N = Node_Coordinate_Ring(i+Num_Radial,1);
%     fprintf(fileID,'D, %d, UX\n', iN_N);
%     fprintf(fileID,'D, %d, UY\n', iN_N);
%     fprintf(fileID,'D, %d, UZ\n', iN_N);
    fprintf(fileID,'D, %d, ALL\n', iN_N);
end
% 【荷载】
% 环向索 初应变
fprintf(fileID,'\n!初应变\n');
% INISTATE, Action, Val1, Val2, Val3, Val4, Val5, Val6, Val7, Val8, Val9
% Defines initial-state data and parameters.
fprintf(fileID,'INISTATE, SET, DTYP, EPEL\n');  % Data type: Strain data
% INISTATE, DEFINE, ID, EINT, KLAYER, PARMINT, Cxx, Cyy, Czz, Cxy, Cyz, Cxz
for i = 1 : Num_Radial
    iE_N = Element_Node_Ring(i+Num_Radial,1);
    fprintf(fileID,'INISTATE, DEFINE, %d, , , , %f\n', iE_N, ISTRAN_Ring);
end
% 自重
fprintf(fileID,'\n!自重\n');
% ACEL, ACEL_X, ACEL_Y, ACEL_Z
% Specifies the linear acceleration of the global Cartesian reference frame for the analysis.
fprintf(fileID,'ACEL, , , 9.8\n');  % 定义重力加速度(自重)
% 荷载
fprintf(fileID,'\n!荷载\n');
% SFBEAM, Elem, LKEY, Lab, VALI, VALJ, VAL2I, VAL2J, IOFFST, JOFFST, LENRAT
% Specifies surface loads on beam and pipe elements.
for i = 1 : Num_Radial
    iE_N = Element_Node_Ring(i,1);
    % 径向单元上 线荷载 LKEY=1为-Z方向
    fprintf(fileID,'SFBEAM, %d, 1, PRES, %f, %f\n', iE_N, -F_p(1), -F_p(2));
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

%%
fclose('all');
end
