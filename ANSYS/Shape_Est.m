%% Shape Estimation
% 判断内环节点处
% 上索是否在内环两直线形成的平面之上
% Xu Yi, 2022.5.26

%%
close all; clear; clc;

%% 
addpath(genpath('Func'))        % 搜索路径中加入Func文件夹及其下所有文件夹

%%
% 其中环向索仅导入了内环
load('../Data/YH.mat',...      % 数据文件位置
    'Node_Coordinate',...   % [节点编号, X坐标, Y坐标, Z坐标]
    'Node_Support',...      % [节点编号, X约束, Y约束, Z约束]
    'Element_Node',...      % [单元编号, 节点编号1, 节点编号2]
    'Element_Property',...  % [单元编号, 索直径编号, 索弹性模量编号]
    'Num_Radial',...        % 榀数
    'Num_n1_n2',...         % n1~n2间的分隔数 (索桁架处)
    'Node_Itvl',...         % 每一榀的节点数
    'iEL_Ring');            % 内环起始单元编号

%%
for i = 1 : Num_Radial

    % 节点编号
    iNo_N = Node_Itvl * (i-1) + 1;  % 目标节点编号
    if i ~= 1
        iNo_N_l = iNo_N - Node_Itvl;% 目标节点相邻节点1(左)编号
    else
        iNo_N_l = Node_Itvl * (Num_Radial-1) + 1;
    end
    if i ~= Num_Radial
        iNo_N_r = iNo_N + Node_Itvl;% 目标节点相邻节点2(右)编号
    else
        iNo_N_r = 1;
    end
    iNo_N_C1 = iNo_N + 1;           % 上索节点编号

    % 节点坐标
    for j = 1 : length(Node_Coordinate(:,1))
        switch Node_Coordinate(j,1)
            case iNo_N
                P_o = Node_Coordinate(j,2:4);  % 内环目标节点坐标
            case iNo_N_l
                P_R1 = Node_Coordinate(j,2:4); % 内环目标节点相邻节点1坐标
            case iNo_N_r
                P_R2 = Node_Coordinate(j,2:4); % 内环目标节点相邻节点2坐标
            case iNo_N_C1
                P_C1 = Node_Coordinate(j,2:4); % 上索节点坐标
            otherwise
                continue
        end
    end

    % 内环3节点形成平面的法向量
    V_R1_o = P_o - P_R1;    % 向量P_R1->P_o
    V_R2_o = P_o - P_R2;    % 向量P_R1->P_o
    x_R1 = V_R1_o(1); y_R1 = V_R1_o(2); z_R1 = V_R1_o(3);
    x_R2 = V_R2_o(1); y_R2 = V_R2_o(2); z_R2 = V_R2_o(3);
    V_nor = [1,...
        -( x_R1 - x_R2 * z_R1 / z_R2 )/( y_R1 - y_R2 * z_R1 / z_R2 ),...
        -( x_R1 - x_R2 * y_R1 / y_R2 )/( z_R1 - z_R2 * y_R1 / y_R2 )];     % 法向量

    % P = P_C1 + d*(P_C1->P_C2) 式1
    % P为所求交点; P_C1为上索节点坐标; P_C1->P_C2为上索节点至下索节点向量
    % d*(P_C1->P_C2)为P_C1点至P点距离
    % (P-P_o)·V_nor=0           式2
    % 把式1代入式2求得d，代入d至式1可得交点P
    % x_C1 = P_C1(1); y_C1 = P_C1(2); z_C1 = P_C1(3);
    % x_VC = V_C1_C2(1); y_VC = V_C1_C2(2); z_VC = V_C1_C2(3);
    % x_o = P_o(1); y_o = P_o(2); z_o = P_o(3);
    % x_Vn = V_nor(1); y_Vn = V_nor(2); z_Vn = V_nor(3);
    V_C1_C2 = [0,0,1];  % 由于上下索投影重合，故此处直接定义(P_C1-P_C2)为[0,0,1]
    dist = - dot( (P_C1 - P_o) , V_nor )...
        / dot( V_C1_C2 , V_nor );   % dist*V_C1_C2为P_C1至交点P的向量
    P_x = P_C1 + dist * V_C1_C2;

    % 判断P_C1的z坐标是否大于P_x的z坐标 (即P_C1在内环3节点形成平面之上)
    if P_C1(3) > P_x(3)
        fprintf('节点%d不满足。\n', iNo_N);
    end

end
