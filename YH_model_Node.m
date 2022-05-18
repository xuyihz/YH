%% function
% MGT
%
% Xu Yi, 2022.5.12

%%
function [Node_Itvl, n_iNo_Start, n_Ring_num] = YH_model_Node(fileID, iNO,...
    n1, n2, n3, n23, n23_l, n23_0, n2_l,...
    Num_Radial, Ring_itvl,...
    Num_n1_n2, Num_n2_n23, Num_n23_n3,...
    FZ, MatFile)
%% NODE
fprintf(fileID,'*NODE    ; Nodes\n');
fprintf(fileID,'; iNO, X, Y, Z\n');

Node_Itvl = (Num_n1_n2 + Num_n2_n23 + Num_n23_n3) * 2 +7;   % 每一榀的节点数
% 榀
iNO_Radial_init = iNO; % 备份
for i = 1:Num_Radial % 榀
    fprintf(fileID,'; %d榀 节点\n', i);
    % n1
    iNO = iNO+1;
    if i == 1
        n1_iNo_Start = iNO; % 记录n1第一榀的编号
    end
    fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
        iNO, n1(i,1), n1(i,2), n1(i,3));
    if MatFile == true
        node_coordinate(iNO, n1(i,1), n1(i,2), n1(i,3));    % 坐标 记录到.mat
    end
    % n1~n2, 先上后下
    for j = 1 : Num_n1_n2
        n_temp = interp(n1(i,:), n2(i,:), Num_n1_n2, j);

        iNO = iNO+1;
        fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
            iNO, n_temp(1), n_temp(2), n_temp(3));
        if MatFile == true
            node_coordinate(iNO, n_temp(1), n_temp(2), n_temp(3));   % 坐标 记录到.mat
        end
    end
    for j = 1 : Num_n1_n2
        n_temp = interp(n1(i,:), n2_l(i,:), Num_n1_n2, j);

        iNO = iNO+1;
        fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
            iNO, n_temp(1), n_temp(2), n_temp(3));
        if MatFile == true
            node_coordinate(iNO, n_temp(1), n_temp(2), n_temp(3));   % 坐标 记录到.mat
        end
    end
    % n2~n23, 先上后下
    iNO = iNO+1;
    if i == 1
        n2_iNo_Start = iNO; % 记录n2第一榀的编号
    end
    fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
        iNO, n2(i,1), n2(i,2), n2(i,3));
    if MatFile == true
        node_coordinate(iNO, n2(i,1), n2(i,2), n2(i,3));    % 坐标 记录到.mat
        node_support(iNO, 1, 1, 1);                         % 约束 记录到.mat
    end
    for j = 1 : Num_n2_n23
        n_temp = interp(n2(i,:), n23(i,:), Num_n2_n23, j);

        iNO = iNO+1;
        fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
            iNO, n_temp(1), n_temp(2), n_temp(3));
    end
    iNO = iNO+1;
    if i == 1
        n2_l_iNo_Start = iNO; % 记录n2_l第一榀的编号
    end
    fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
        iNO, n2_l(i,1), n2_l(i,2), n2_l(i,3));
    if MatFile == true
        node_coordinate(iNO, n2_l(i,1), n2_l(i,2), n2_l(i,3));  % 坐标 记录到.mat
        node_support(iNO, 1, 1, 1);                             % 约束 记录到.mat
    end
    for j = 1 : Num_n2_n23
        n_temp = interp(n2_l(i,:), n23_l(i,:), Num_n2_n23, j);

        iNO = iNO+1;
        fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
            iNO, n_temp(1), n_temp(2), n_temp(3));
    end
    % n23~n3, 先上后下
    iNO = iNO+1;
    if i == 1
        n23_iNo_Start = iNO; % 记录n23第一榀的编号
    end
    fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
        iNO, n23(i,1), n23(i,2), n23(i,3));
    for j = 1 : Num_n23_n3
        n_temp = interp(n23(i,:), n3(i,:), Num_n23_n3, j);

        iNO = iNO+1;
        fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
            iNO, n_temp(1), n_temp(2), n_temp(3));
    end
    iNO = iNO+1;
    if i == 1
        n3_iNo_Start = iNO; % 记录n3第一榀的编号
    end
    fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
        iNO, n3(i,1), n3(i,2), n3(i,3));
    iNO = iNO+1;
    if i == 1
        n23_l_iNo_Start = iNO; % 记录n23_l第一榀的编号
    end
    fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
        iNO, n23_l(i,1), n23_l(i,2), n23_l(i,3));
    for j = 1 : Num_n23_n3
        n_temp = interp(n23_l(i,:), n3(i,:), Num_n23_n3, j);

        iNO = iNO+1;
        fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
            iNO, n_temp(1), n_temp(2), n_temp(3));
    end
    % n23_0
    iNO = iNO+1;
    if i == 1
        n23_0_iNo_Start = iNO; % 记录n23_0第一榀的编号
    end
    fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
        iNO, n23_0(i,1), n23_0(i,2), n23_0(i,3));
end
fprintf(fileID,'\n');
iNO_Radial_end = iNO; % 备份
n_iNo_Start = [n1_iNo_Start; n2_iNo_Start; n2_l_iNo_Start; n23_iNo_Start;...
    n23_l_iNo_Start; n23_0_iNo_Start; n3_iNo_Start; (iNO_Radial_end+1)];     % 记录第一榀关键点的编号

% 环
iNO_Ring_init = iNO_Radial_end;
iNO = iNO_Ring_init;    % 初始化
% 环向间距
n2_dist = dist_2p3D(n2(1,:), n2(2,:));
n2_n23_dist = zeros(Num_n2_n23);
for i = 1 : Num_n2_n23
    n2_n23_1 = interp(n2(1,:), n23(1,:), Num_n2_n23, i);
    n2_n23_2 = interp(n2(2,:), n23(2,:), Num_n2_n23, i);
    n2_n23_dist(i) = dist_2p3D(n2_n23_1, n2_n23_2);
end
n23_dist = dist_2p3D(n23(1,:), n23(2,:));
n23_n3_dist = zeros(Num_n23_n3);
for i = 1 : Num_n23_n3
    n23_n3_1 = interp(n2(1,:), n23(1,:), Num_n23_n3, i);
    n23_n3_2 = interp(n2(2,:), n23(2,:), Num_n23_n3, i);
    n23_n3_dist(i) = dist_2p3D(n23_n3_1, n23_n3_2);
end
n3_dist = dist_2p3D(n3(1,:), n3(2,:));
% 环向分隔数
n2_Ring_num = ceil(n2_dist / Ring_itvl);  % 向上取整，保证分隔后间隔小于Ring_itvl
n2_l_Ring_num = n2_Ring_num;
n2_n23_Ring_num = zeros(Num_n2_n23, 1);
for i = 1 : Num_n2_n23
    n2_n23_Ring_num(i) = ceil(n2_n23_dist(i) / Ring_itvl);
end
n23_Ring_num = ceil(n23_dist / Ring_itvl);
n23_l_Ring_num = n23_Ring_num;
n23_n3_Ring_num = zeros(Num_n23_n3, 1);
for i = 1 : Num_n23_n3
    n23_n3_Ring_num(i) = ceil(n23_n3_dist(i) / Ring_itvl);
end
n3_Ring_num = ceil(n3_dist / Ring_itvl);
n_sum_Ring_num = n2_Ring_num + n2_l_Ring_num + 2*sum(n2_n23_Ring_num) ...
    + n23_Ring_num + n23_l_Ring_num + 2*sum(n23_n3_Ring_num) + n3_Ring_num;
n_Ring_num = {n2_Ring_num, n2_l_Ring_num, n2_n23_Ring_num, n23_Ring_num,...
    n23_l_Ring_num, n23_n3_Ring_num, n3_Ring_num, n_sum_Ring_num};
% 榀
for i = 1 : Num_Radial% 榀
    for j = 1 : 1   % n2
        for k = 1 : n2_Ring_num
            n_temp_start = n2(i,:);
            if i == Num_Radial
                n_temp_end = n2(1,:);
            else
                n_temp_end = n2(i+1,:);
            end
            n_temp = interp(n_temp_start, n_temp_end, n2_Ring_num, k);
            iNO = iNO+1;
            fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
                iNO, n_temp(1), n_temp(2), n_temp(3));
        end
    end
    for j = 1 : 1   % n2_l
        for k = 1 : n2_l_Ring_num
            n_temp_start = n2_l(i,:);
            if i == Num_Radial
                n_temp_end = n2_l(1,:);
            else
                n_temp_end = n2_l(i+1,:);
            end
            n_temp = interp(n_temp_start, n_temp_end, n2_l_Ring_num, k);
            iNO = iNO+1;
            fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
                iNO, n_temp(1), n_temp(2), n_temp(3));
        end
    end
    for j = 1 : Num_n2_n23   % n2~n23
        for ji = 1 : 2  % 上下两层
            if ji == 1
                n2_temp1 = n2(i,:);
                n23_temp1 = n23(i,:);
                if i == Num_Radial
                    n2_temp2 = n2(1,:);
                    n23_temp2 = n23(1,:);
                else
                    n2_temp2 = n2(i+1,:);
                    n23_temp2 = n23(i+1,:);
                end
            elseif ji == 2
                n2_temp1 = n2_l(i,:);
                n23_temp1 = n23_l(i,:);
                if i == Num_Radial
                    n2_temp2 = n2_l(1,:);
                    n23_temp2 = n23_l(1,:);
                else
                    n2_temp2 = n2_l(i+1,:);
                    n23_temp2 = n23_l(i+1,:);
                end
            end
            n_temp1 = interp(n2_temp1, n23_temp1, Num_n2_n23, j);
            n_temp2 = interp(n2_temp2, n23_temp2, Num_n2_n23, j);
            for k = 1 : n2_n23_Ring_num(j)
                n_temp = interp(n_temp1, n_temp2, n2_n23_Ring_num(j), k);
                iNO = iNO+1;
                fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
                    iNO, n_temp(1), n_temp(2), n_temp(3));
            end
        end
    end
    for j = 1 : 1   % n23
        for k = 1 : n23_Ring_num
            n_temp_start = n23(i,:);
            if i == Num_Radial
                n_temp_end = n23(1,:);
            else
                n_temp_end = n23(i+1,:);
            end
            n_temp = interp(n_temp_start, n_temp_end, n23_Ring_num, k);
            iNO = iNO+1;
            fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
                iNO, n_temp(1), n_temp(2), n_temp(3));
        end
    end
    for j = 1 : 1   % n23_l
        for k = 1 : n23_l_Ring_num
            n_temp_start = n23_l(i,:);
            if i == Num_Radial
                n_temp_end = n23_l(1,:);
            else
                n_temp_end = n23_l(i+1,:);
            end
            n_temp = interp(n_temp_start, n_temp_end, n23_l_Ring_num, k);
            iNO = iNO+1;
            fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
                iNO, n_temp(1), n_temp(2), n_temp(3));
        end
    end
    for j = 1 : Num_n23_n3   % n23~n3
        for ji = 1 : 2  % 上下两层
            if ji == 1
                n23_temp1 = n23(i,:);
                n3_temp1 = n3(i,:);
                if i == Num_Radial
                    n23_temp2 = n23(1,:);
                    n3_temp2 = n3(1,:);
                else
                    n23_temp2 = n23(i+1,:);
                    n3_temp2 = n3(i+1,:);
                end
            elseif ji == 2
                n23_temp1 = n23_l(i,:);
                n3_temp1 = n3(i,:);
                if i == Num_Radial
                    n23_temp2 = n23_l(1,:);
                    n3_temp2 = n3(1,:);
                else
                    n23_temp2 = n23_l(i+1,:);
                    n3_temp2 = n3(i+1,:);
                end
            end
            n_temp1 = interp(n23_temp1, n3_temp1, Num_n23_n3, j);
            n_temp2 = interp(n23_temp2, n3_temp2, Num_n23_n3, j);
            for k = 1 : n23_n3_Ring_num(j)
                n_temp = interp(n_temp1, n_temp2, n23_n3_Ring_num(j), k);
                iNO = iNO+1;
                fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
                    iNO, n_temp(1), n_temp(2), n_temp(3));
            end
        end
    end
    for j = 1 : 1   % n3
        for k = 1 : n3_Ring_num
            n_temp_start = n3(i,:);
            if i == Num_Radial
                n_temp_end = n3(1,:);
            else
                n_temp_end = n3(i+1,:);
            end
            n_temp = interp(n_temp_start, n_temp_end, n3_Ring_num, k);
            iNO = iNO+1;
            fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
                iNO, n_temp(1), n_temp(2), n_temp(3));
        end
    end
end
fprintf(fileID,'\n');
iNO_Ring_end = iNO; % 备份
iNO_end = iNO;  % 最后一个节点的编号

%% CONSTRAINT
fprintf(fileID,'*CONSTRAINT    ; Supports\n');
fprintf(fileID,'; NODE_LIST, CONST(Dx,Dy,Dz,Rx,Ry,Rz), GROUP\n');

CONSTRAINT = 111111; % 刚接

fprintf(fileID,'; 柱底刚接\n');
iNO = iNO_Radial_init; % 初始化iNO
for i = 1:Num_Radial % 榀
    iNO = iNO + Node_Itvl;
    fprintf(fileID,'   %d, %d, \n',...
        iNO, CONSTRAINT);
end
fprintf(fileID,'\n');

%% CONLOAD
fprintf(fileID,'*CONLOAD    ; Nodal Loads');
fprintf(fileID,'; NODE_LIST, FX, FY, FZ, MX, MY, MZ, GROUP');

fprintf(fileID,'; 节点力\n');
for iNO = 1:iNO_end
    fprintf(fileID,'   %d, 0, 0, %d, 0, 0, 0, \n',...
        iNO, FZ);
end
fprintf(fileID,'\n');

end