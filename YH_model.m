%% function
% MGT model
%
% Xu Yi, 2022.5.12

%%
function YH_model(fileID, MatFile)
%% initials
iNO = 0;    % 节点号初始化
iEL = 0;    % 单元号初始化
% load original node data
% n1为索桁架内环位置，n2为索桁架外环位置，n3为钢桁架根部位置
load('./Data/YH_Rhino_Node.mat', 'n1', 'n2', 'n3');
%
H_n23 = 7000;       % n23~n23_l的高度
H_n2 = 3000;        % n2~n2_l的高度
Ring_itvl = 4000;   % 环桁架腹杆节点间最大间距
Num_n1_n2 = 5;      % n1~n2间的分隔数 (索桁架处)
Num_n2_n23 = 4;     % n2~n23间的分隔数 (钢桁架悬挑部分)
Num_n23_n3 = 3;     % n23~n3间的分隔数 (钢桁架根部)
%
n23 = (n2 + n3) / 2;            % n23节点位置 (立柱顶位置)
n23_l = n23 - [0, 0, H_n23];    % n23_l节点位置 (立柱位置,桁架底)
n23_0 = n23; n23_0(:, 3) = 0;   % n23_0节点位置 (立柱底位置)
n2_l = n2 - [0, 0, H_n2];       % n2_l节点位置 (索桁架外环位置,桁架底)
% 节点力
FZ = -40;   % 节点力,单位kN,向上为正
% 上下索的垂度
f1 = 200;   % 上索跨中垂度(向下) mm
f2 = -200;  % 下索跨中垂度(向上) mm

%% append models
% Node
fprintf(fileID,'; Node\n');
[Node_Itvl, n_iNo_Start, n_Ring_num] = YH_model_Node(fileID, iNO,...
    n1, n2, n3, n23, n23_l, n23_0, n2_l,...
    length(n1), Ring_itvl, f1, f2,...
    Num_n1_n2, Num_n2_n23, Num_n23_n3,...
    FZ, MatFile);

fprintf(fileID,'; Radial\n'); iNO_Radial_init = iNO;
iEL = YH_model_Radial(fileID, iNO, iEL,...
    length(n1), Node_Itvl, n_iNo_Start, n_Ring_num,...
    Num_n1_n2, Num_n2_n23, Num_n23_n3, FZ, MatFile);

fprintf(fileID,'; Ring\n'); iNO_Ring_init = iNO;
iEL = YH_model_Ring(fileID, iNO, iEL,...
    length(n1), Node_Itvl, n_iNo_Start, n_Ring_num,...
    Num_n1_n2, Num_n2_n23, Num_n23_n3, FZ, MatFile);
iNO_Ring_end = iNO;

%%
fprintf(fileID,'\n');

end