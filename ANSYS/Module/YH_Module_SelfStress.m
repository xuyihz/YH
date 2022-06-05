%% Get Self Stress Modes
% 
% 
% Xu Yi, 2022.5.31

%%
function [EPEL_Radial,  EPEL_Ring] = YH_Module_SelfStress(Node_Coordinate,...
    Num_Radial, Num_n1_n2, iEL_Ring, EPEL_T, EPEL_B, co_EPEL_Base, EPEL_FDir)
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
% co_EPEL_Base = 1;  % 以第一个内环节点环索左节点为基准
EPEL_Ring_raw = zeros(Num_Radial*2,2);    % 环索在单榀下的应变结果

%% 根据索桁架内环节点受力平衡，得到环索(单榀下)的应变
for i = 1 : Num_Radial
    Node_C_Itvl = Num_n1_n2 * 2 + 3;    % 索桁架处单榀节点数
    Node_Co_Part ...
        = Node_Coordinate( ( (i-1)*Node_C_Itvl+1 ) : i*Node_C_Itvl, : );  % 目标榀的节点

    %% 
    % 【内环节点坐标】
    if i ~= 1
        N_temp = Node_C_Itvl * (i-2) + 1;
    else
        N_temp = Node_C_Itvl * (Num_Radial-1) + 1;
    end
    Node_Co_Rl = Node_Coordinate(N_temp, 2:4);      % 环索左节点坐标
    if i ~= Num_Radial
        N_temp = Node_C_Itvl * i + 1;
    else
        N_temp = 1;
    end
    Node_Co_Rr = Node_Coordinate(N_temp, 2:4);      % 环索右节点坐标
    Node_Co_C = Node_Co_Part(1, 2:4);               % 内环节点坐标
    Node_Co_Ct = Node_Co_Part(2, 2:4);              % 上索节点坐标
    Node_Co_Cb = Node_Co_Part(2+Num_n1_n2, 2:4);    % 下索节点坐标
    % 【内环节点向量】
    V_C_Rl = Node_Co_Rl - Node_Co_C;    % C->Rl向量
    V_C_Rr = Node_Co_Rr - Node_Co_C;    % C->Rr向量
    V_C_Ct = Node_Co_Ct - Node_Co_C;    % C->Ct向量
    V_C_Cb = Node_Co_Cb - Node_Co_C;    % C->Cb向量
    % 【内环节点应变】
    EPEL_T_P = EPEL_T(Num_n1_n2*3*i-1, 2);  % 内环节点边第一上索单元应变
    EPEL_B_P = EPEL_B(Num_n1_n2*3*i-1, 2);  % 内环节点边第一下索节点应变
    V_C_Ct_EPEL = V_C_Ct / norm(V_C_Ct) * EPEL_T_P; % 内环节点边第一上索单元应变向量
    V_C_Cb_EPEL = V_C_Cb / norm(V_C_Cb) * EPEL_B_P; % 内环节点边第一下索节点应变向量
    V_Ctb_EPEL = V_C_Ct_EPEL + V_C_Cb_EPEL; % 上下索的合力
    % 节点处力的平衡
    % V_C_Rl(1)*co_EPEL_Rl + V_C_Rr(1)*co_EPEL_Rr = -V_Ctb_EPEL(1)
    % V_C_Rl(2)*co_EPEL_Rl + V_C_Rr(2)*co_EPEL_Rr = -V_Ctb_EPEL(2)
    % 根据以上方程组可以求得co_EPEL_Rl、co_EPEL_Rr，
    % V_C_Rl*co_EPEL_Rl = V_Rl_EPEL
    % V_C_Rr*co_EPEL_Rr = V_Rr_EPEL
    % 最后判断 V_Ctb_EPEL + V_Rl_EPEL + V_Rr_EPEL = 0 (可能会有截断误差等)
    co_EPEL_Rl = ( -V_C_Rr(2)*V_Ctb_EPEL(1) + V_C_Rr(1)*V_Ctb_EPEL(2) )...
        / ( V_C_Rr(2)*V_C_Rl(1) - V_C_Rr(1)*V_C_Rl(2) );
    co_EPEL_Rr = ( -V_C_Rl(2)*V_Ctb_EPEL(1) + V_C_Rl(1)*V_Ctb_EPEL(2) )...
        / ( V_C_Rl(2)*V_C_Rr(1) - V_C_Rl(1)*V_C_Rr(2) );
    V_Rl_EPEL = V_C_Rl * co_EPEL_Rl; % 内环节点环索左节点应变向量
    V_Rr_EPEL = V_C_Rr * co_EPEL_Rr; % 内环节点环索右节点应变向量
    V_sum = V_Ctb_EPEL + V_Rl_EPEL + V_Rr_EPEL; % 合力向量
    fprintf('第%d榀，合力模量%f\n', i, norm(V_sum));

    
    EPEL_Ring_raw(i*2-1, 1) = iEL_Ring+i-2; % 环索左单元编号
    EPEL_Ring_raw(i*2, 1) = iEL_Ring+i-1;   % 环索右单元编号
    if i == 1
        EPEL_Ring_raw(i*2-1, 1) = iEL_Ring+Num_Radial-1;    % 环索左单元编号
    end
    EPEL_Ring_raw(i*2-1, 2) = norm(V_Rl_EPEL);
    EPEL_Ring_raw(i*2, 2) = norm(V_Rr_EPEL);
end

%% 以第一个内环节点环索左节点为基准，校准整体各个单元的应变
% 重新定义EPEL_Radial，按[榀，上中下, 单元编号&对应应变]
Element_C_Itvl = Num_n1_n2*3+2;
EPEL_Radial = zeros(Num_Radial, Element_C_Itvl, 2); % 【一致】索桁架的应变
for i = 1 : Num_Radial
    for j = 1 : Num_n1_n2
        EPEL_T_iEl = (j-1)*3+1 + Num_n1_n2*3*(i-1);
        EPEL_Radial(i, j, :) = EPEL_T( EPEL_T_iEl, : );    % 上索
        EPEL_M_iEl = j*3 + Num_n1_n2*3*(i-1);
        EPEL_Radial(i, Num_n1_n2+1+j, :) = EPEL_T( EPEL_M_iEl, : );    % 中索
        EPEL_B_iEl = EPEL_T_iEl;
        EPEL_Radial(i, Num_n1_n2*2+1+j, :) = EPEL_B( EPEL_B_iEl, : );    % 下索
        if j == Num_n1_n2
            EPEL_T_iEl = (j-1)*3+1 + Num_n1_n2*3*(i-1) + 1;
            EPEL_Radial(i, j+1, :) = EPEL_T( EPEL_T_iEl, : );    % 上索+1
            EPEL_B_iEl = EPEL_T_iEl;
            EPEL_Radial(i, Num_n1_n2*2+1+j+1, :) = EPEL_B( EPEL_B_iEl, : );    % 下索+1
        end
    end
end
% 校准
for i = 1 : Num_Radial
    EPEL_Ring_raw_Base = EPEL_Ring_raw(i*2-1, 2);   % 每一榀以内环节点环索左节点为基准
    EPEL_Ring_raw( (i*2-1):(i*2), 2 ) = EPEL_Ring_raw( (i*2-1):(i*2), 2 )...
        / EPEL_Ring_raw_Base * co_EPEL_Base;
    EPEL_Radial(i, :, 2) = EPEL_Radial(i, :, 2)...
        / EPEL_Ring_raw_Base * co_EPEL_Base;

    co_EPEL_Base = EPEL_Ring_raw(i*2, 2);   % 更新系数
end
EPEL_Ring = zeros(Num_Radial,2);    % 【一致】环桁架的应变
for i = 1 : Num_Radial
    EPEL_Ring(i, :) = EPEL_Ring_raw(i*2-1, :);
end

%%
% 保存一致的EPEL_Radial/EPEL_Ring至.mat
save(EPEL_FDir, 'EPEL_Radial', '-append');  % 索桁架的应变
save(EPEL_FDir, 'EPEL_Ring', '-append');    % 环桁架的应变

end
