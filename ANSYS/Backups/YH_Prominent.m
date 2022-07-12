%% Update MAT file
%
% 外凸索桁架
%
% Xu Yi, 2022.7.5

%%
close all; clear; clc;

%%
load('../../Data/YH.mat',...   % 数据文件位置
    'Node_Coordinate',...   % [节点编号, X坐标, Y坐标, Z坐标]
    'Node_Support',...      % [节点编号, X约束, Y约束, Z约束]
    'Element_Node',...      % [单元编号, 节点编号1, 节点编号2]
    'Element_Property',...  % [单元编号, 索直径编号, 索弹性模量编号]
    'Num_Radial',...        % 榀数
    'Num_n1_n2',...         % n1~n2间的分隔数 (索桁架处)
    'Node_Itvl',...         % 每一榀的节点数
    'iEL_Ring');            % 内环起始单元编号
f2 = 200;   % 垂度

Node_C_Itvl = Num_n1_n2 * 2 + 3;    % 索桁架处单榀节点数
for i = 1 : Num_Radial
    iNo_temp_start = Node_C_Itvl * (i-1);
    iNo_temp_in = iNo_temp_start+1;
    iNo_temp_out_up = iNo_temp_start+Node_C_Itvl-1;
    iNo_temp_out_down = iNo_temp_start+Node_C_Itvl;
    % 更新上下索节点，把原有内凹改外凸
    for j = 1 : Num_n1_n2   % 上、下
        Node_Coordinate(iNo_temp_in+j,4) = interp_para(Node_Coordinate(iNo_temp_in,2:4),...
            Node_Coordinate(iNo_temp_out_up,2:4),...
            Num_n1_n2, j, -f2);  % 上
        Node_Coordinate(iNo_temp_in+Num_n1_n2+j,4) = interp_para(Node_Coordinate(iNo_temp_in,2:4),...
            Node_Coordinate(iNo_temp_out_down,2:4),...
            Num_n1_n2, j, f2);  % 下
    end
end
save('../../Data/YH.mat','Node_Coordinate','-append');

%%
function z3 = interp_para(x1, x2, Num, n, f)
% z = -4fx(l-x)/l^2 + c/l*x % z1=0的情况,c=z2-z1
z1 = x1(3); z2 = x2(3);
% x/l = n/(Num + 1)
z3 = -4*f*n*((Num + 1)-n)/(Num + 1)^2 +...   % 垂度
    (z2 - z1) / (Num + 1) * n + z1;         % 两端点
end