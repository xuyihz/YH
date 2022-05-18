%% function
% initial conditions
%
% Xu Yi, 2022.5.17

%%
function init_Con()
Node_Coordinate = [];   % 节点编号 / 节点XYZ坐标
Node_Support = [];      % 节点编号 / 节点约束
Element_Node = [];      % 单元编号 / 节点编号
Element_Property = [];  % 单元编号 / 单元属性(索直径、弹性模量)
save('./Data/YH.mat','Node_Coordinate');
save('./Data/YH.mat','Node_Support','-append');
save('./Data/YH.mat','Element_Node','-append');
save('./Data/YH.mat','Element_Property','-append');
end