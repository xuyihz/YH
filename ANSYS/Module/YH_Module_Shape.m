%% Shape
% 根据【内环节点】左右环索 确定环索合力在索桁架平面的方向
% 根据上索方向 及 上下索索桁架自应力模态下的初应变 求得下索新方向
% 更新模型 导回计算模块进行迭代
% Xu Yi, 2022.5.30

%%
function Node_Co_nCb = YH_Module_Shape(EPEL_T, EPEL_B,...
    Node_Co_Rl, Node_Co_Rr, Node_Co_C, Node_Co_Ct, Node_Co_Cb)
%% 【内环节点】
% Node_Co_Rl  % 环索左节点坐标
% Node_Co_Rr  % 环索右节点坐标
% Node_Co_C   % 内环节点坐标
% Node_Co_Ct  % 上索节点坐标
% Node_Co_Cb  % 下索节点坐标

%%
V_C_Rl = Node_Co_Rl - Node_Co_C;    % C->Rl向量
V_C_Rr = Node_Co_Rr - Node_Co_C;    % C->Rr向量
V_C_Ct = Node_Co_Ct - Node_Co_C;    % C->Ct向量
V_C_Cb = Node_Co_Cb - Node_Co_C;    % C->Cb向量

N_RlxRr = cross(V_C_Rl, V_C_Rr);    % V_C_RlxV_C_Rr 法向量
N_CtxCb = cross(V_C_Ct, V_C_Cb);    % V_C_CtxV_C_Cb 法向量
N_C = cross(N_CtxCb, N_RlxRr);      % 环索合力方向的反方向，即上下索更新后的合力方向

L_Ct_NC = dot(V_C_Ct, N_C) / norm(N_C); % C->Ct向量在N_C上的投影长度
L_CtxNC = sqrt( norm(V_C_Ct)^2 - L_Ct_NC^2 );   % Ct点至N_C的垂直距离
L_Cb_NC = sqrt( (norm(V_C_Ct) / EPEL_T * EPEL_B)^2 - L_CtxNC^2 );   % C->新Cb向量按应变(EPEL)比例调整后在N_C上的投影长度

V_N_C = N_C / norm(N_C) * (L_Ct_NC + L_Cb_NC);  % C->Ct向量 + C->新Cb向量 的向量 (与N_C同方向)
V_C_nCb = V_N_C - V_C_Ct;

Node_Co_nCb = V_C_nCb / V_C_nCb(1) * V_C_Cb(1)...    % 保证平面投影长度一致
    + Node_Co_C;   % 新下索节点坐标

end