%% function
% MGT model
%
% Xu Yi, 2022.5.12

%%
function YH_model(fileID)
%% initials
iNO = 0;    % 节点号初始化
iEL = 0;    % 单元号初始化
% load original node data
load('YH_Node.mat', 'n1', 'n2', 'n3');
%
H_n23 = 7000;
H_n2 = 3000;
Num_n1_n2 = 9;
Num_n2_n23 = 4;
Num_n23_n3 = 3;
%
n23 = (n2 + n3) / 2;
n23_l = n23 - [0, 0, H_n23];
n23_0 = n23; n23_0(:, 3) = 0;

n2_l = n2 - [0, 0, H_n2];
% 节点力
FZ = -40; % 节点力 -40kN

%% append models
% Node
fprintf(fileID,'; Node\n');
Node_Itvl = YH_model_Node(fileID, iNO,...
    n1, n2, n3, n23, n23_l, n23_0, n2_l,...
    Num_n1_n2, Num_n2_n23, Num_n23_n3,...
    FZ);

fprintf(fileID,'; Radial\n'); iNO_Radial_init = iNO;
iEL = YH_model_Radial(fileID, iNO, iEL,...
    length(n1),...
    Num_n1_n2, Num_n2_n23, Num_n23_n3, Node_Itvl, FZ);

fprintf(fileID,'; Ring\n'); iNO_Ring_init = iNO;
iEL = YH_model_Ring(fileID, iNO, iEL,...
    length(n1),...
    Num_n1_n2, Num_n2_n23, Num_n23_n3, Node_Itvl, FZ);
iNO_Ring_end = iNO;

%%
fprintf(fileID,'\n');

end