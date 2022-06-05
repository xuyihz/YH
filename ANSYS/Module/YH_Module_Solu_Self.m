%% Generate APDL file
% Build /SOLU Self-stress Mode
% ANSYS APDL file
% run ANSYS in batch mode
% Xu Yi, 2022.6.1

%%
function YH_Module_Solu_Self(Num_Radial, EPEL_Radial, EPEL_Ring, LSsteps,...
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

%% ANSYS APDL
fileID = fopen(FileDir,'a');   % Open or create new file for writing. Append data to the end of the file.

%%
fprintf(fileID,'/PREP7\n'); % 进入前处理模块
% 初应变
% INISTATE, Action, Val1, Val2, Val3, Val4, Val5, Val6, Val7, Val8, Val9 
% Defines initial-state data and parameters.
fprintf(fileID,'INISTATE, SET, DTYP, EPEL\n');  % Strain data
% INISTATE, DEFINE, ID, EINT, KLAYER, PARMINT, Cxx, Cyy, Czz, Cxy, Cyz, Cxz
for i = 1 : Num_Radial
    for j = 1 : length(EPEL_Radial(1, :, 1))
    fprintf(fileID,'INISTATE, DEFINE, %d, , , , %E\n',...
        EPEL_Radial(i, j, 1), EPEL_Radial(i, j, 2));
    end
end
for i = 1 : length(EPEL_Ring(:,1))
    fprintf(fileID,'INISTATE, DEFINE, %d, , , , %E\n',...
        EPEL_Ring(i, 1), EPEL_Ring(i, 2));
end
fprintf(fileID,'FINISH\n'); % 退出模块

% 进入求解模块
fprintf(fileID,'/SOLU\n');
fprintf(fileID,'ANTYPE, 0\n');          % Perform a static analysis.
fprintf(fileID,'NLGEOM, ON\n');         % Includes large-deflection effects in a static or full transient analysis.
fprintf(fileID,'SSTIF, ON\n');          % 应力刚度
fprintf(fileID,'NSUBST, %d\n', LSsteps);% Specifies the number of substeps to be taken this load step.
fprintf(fileID,'OUTRES, ALL, LAST\n');  % 输出结果
fprintf(fileID,'SOLVE\n');  % 求解
fprintf(fileID,'FINISH\n'); % 退出模块

%%
fclose('all');
