%% Transfer APDL to MGT file
% overwrite MGT
%
% Xu Yi, 2022.6.22

%% 读入APDL数据
load('../Data/YH_APDL.mat',...
    'para_data',...
    'node_data',...
    'element_data',...
    'support_data',...
    'TENSTR_F');
TENSTR_F_previous = TENSTR_F;

%% 读取迭代初张力数据
cable_Result = importdata('索单元内力.xls');
% 第1列节点号，第2列初张力值kN
TENSTR_F = [cable_Result.data(1:3:end, 1), cable_Result.data(1:3:end, 9)];

%% 迭代张拉力算法
TENSTR_F_para = 1;
for i = 1:length(TENSTR_F(:,1))
    index_temp = find(TENSTR_F_previous(:,1) == TENSTR_F(i, 1)); % Find indices and values of nonzero elements
    % 算法：预张力差更新为迭代前后差的TENSTR_F_para倍
    TENSTR_F_delta = TENSTR_F(i, 2) - TENSTR_F_previous(index_temp, 2);
    TENSTR_F(i, 2) = TENSTR_F_previous(index_temp, 2) + TENSTR_F_delta * TENSTR_F_para;
end

%% 读入整体模型MGT参数化数据
load('../Data/YH.mat',...   % 数据文件位置
    'Num_Radial',...        % 榀数
    'Num_n1_n2',...         % n1~n2间的分隔数 (索桁架处)
    'Node_Itvl',...         % 每一榀的节点数
    'iEL_Ring');            % 内环起始单元编号
% 上索t/下索b/竖索v终止单元号
cable_t_Num_End = ( Num_n1_n2 + 1 ) * Num_Radial;
cable_b_Num_End = ( Num_n1_n2 + 1 ) * Num_Radial *2;
cable_v_Num_End = ( Num_n1_n2 + 1 ) * Num_Radial *2 + Num_n1_n2 * Num_Radial;

%% 写入MGT文件数据
fileID = fopen('YH_cable.mgt','w'); % Open or create new file for writing. Discard existing contents, if any.
% Model: Elements
fprintf(fileID,'*ELEMENT    ; Elements\n');
fprintf(fileID,'; iEL, TYPE, iMAT, iPRO, iN1, iN2, ANGLE, iSUB, EXVAL, iOPT(EXVAL2) ; Frame  Element\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, ANGLE, iSUB, EXVAL, EXVAL2, bLMT ; Comp/Tens Truss\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, iN3, iN4, iSUB, iWID , LCAXIS    ; Planar Element\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, iN3, iN4, iN5, iN6, iN7, iN8     ; Solid  Element\n');
ELE_TYPE = 'TENSTR';
ELE_iMAT = 1;
ELE_iPRO = [1, 2, 3, 4];    % Section
ELE_ANGLE = 0;
ELE_iSUB = 3;
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
    % 【迭代】初张力   F = E*ε*A
    index_temp = find(TENSTR_F(:,1) == element_data(i, 1)); % Find indices and values of nonzero elements
    fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d, %d, 1\n',...
        element_data(i, 1), ELE_TYPE, ELE_iMAT, ELE_iPRO_temp,...
        element_data(i, 2), element_data(i, 3),...    % 单元的两个节点号
        ELE_ANGLE, ELE_iSUB, TENSTR_F(index_temp, 2));
end
fclose('all');

%% 保存初拉力数据
save('../Data/YH_APDL.mat', 'TENSTR_F', '-append');
