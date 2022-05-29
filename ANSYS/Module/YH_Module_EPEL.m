%% Load ANSYS output
% ANSYS vwrite file
% 
% Xu Yi, 2022.5.24

%%
function [EPEL_T_N, EPEL_B_N] = YH_Module_EPEL(Num_Radial, Num_n1_n2,...
    ANSYS_Mdir, EPEL_T_FN, EPEL_B_FN, Fext, EPEL_FDir)

%%
% % 其中环向索仅导入了内环
% load('../Data/YH.mat',...      % 数据文件位置
%     'Node_Coordinate',...   % [节点编号, X坐标, Y坐标, Z坐标]
%     'Node_Support',...      % [节点编号, X约束, Y约束, Z约束]
%     'Element_Node',...      % [单元编号, 节点编号1, 节点编号2]
%     'Element_Property',...  % [单元编号, 索直径编号, 索弹性模量编号]
%     'Num_Radial',...        % 榀数
%     'Num_n1_n2',...         % n1~n2间的分隔数 (索桁架处)
%     'Node_Itvl');           % 每一榀的节点数
EPEL_T_FDir = sprintf('%s\\%s.%s', ANSYS_Mdir, EPEL_T_FN, Fext);
EPEL_B_FDir = sprintf('%s\\%s.%s', ANSYS_Mdir, EPEL_B_FN, Fext);
EPEL_T = load(EPEL_T_FDir);   % 单榀上索自应力模态(应变)
EPEL_B = load(EPEL_B_FDir);   % 单榀下索自应力模态(应变)
EPEL_T_N = 'EPEL_T';
EPEL_B_N = 'EPEL_B';

%%
% 判断是否存在自应力模态，即竖索在上下索结果中的比例是否一致
Row3 = Num_Radial * Num_n1_n2;
EPEL_T_3 = zeros(Row3,1);
EPEL_B_3 = zeros(Row3,1);
EPEL_Coe = zeros(Row3,1);
for i = 1 : Num_Radial
    for j = 1 : Num_n1_n2   %上下竖索共3根
        Row = j * 3 + (i-1) * Num_n1_n2 *3;
        Row3 = j + (i-1) * Num_n1_n2;
        EPEL_T_3(Row3, 1) = EPEL_T(Row, 2);
        EPEL_B_3(Row3, 1) = EPEL_B(Row, 2);
        EPEL_Coe(Row3, 1) = EPEL_B_3(Row3, 1) / EPEL_T_3(Row3, 1);
    end
    EPEL_Coe((Row3-Num_n1_n2+1):Row3, 1) =...
        EPEL_Coe((Row3-Num_n1_n2+1):Row3, 1) / EPEL_Coe(Row3, 1);
end

%%
% 使竖索在上下索的结果中，结果一致(相应放大或缩小下索数值)
for i = 1 : Num_Radial
    Cable3_Row = i * Num_n1_n2 * 3; %上下竖索共3根
    Cable3_Base = EPEL_T(Cable3_Row, 2);    % 竖索在上索的结果
    Cable3_Target = EPEL_B(Cable3_Row, 2);  % 竖索在下索的结果
    for j = 1 : 3 * Num_n1_n2   %上下竖索共3根
        Row = Cable3_Row - 3 * Num_n1_n2 + j;
        EPEL_B(Row, 2) = EPEL_B(Row, 2) / Cable3_Target * Cable3_Base;
    end
end

%%
% 保存竖索一致的EPEL_T/EPEL_B至.mat
save(EPEL_FDir, EPEL_T_N);              % 单榀上索自应力模态(应变)
save(EPEL_FDir, EPEL_B_N, '-append');   % 更新的(与上索一致)单榀下索自应力模态(应变)

end
