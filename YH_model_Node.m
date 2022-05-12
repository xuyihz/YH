%% function
% MGT
%
% Xu Yi, 2022.5.12

%%
function Node_Itvl = YH_model_Node(fileID, iNO,...
    n1, n2, n3, n23, n23_l, n23_0, n2_l,...
    Num_n1_n2, Num_n2_n23, Num_n23_n3,...
    FZ)
%% NODE
fprintf(fileID,'*NODE    ; Nodes\n');
fprintf(fileID,'; iNO, X, Y, Z\n');

Node_Itvl = (Num_n1_n2 + Num_n2_n23 + Num_n23_n3) * 2 +7;
% Cable
iNO_Radial_init = iNO; % 备份
for i = 1:length(n1) % 榀
    fprintf(fileID,'; %d榀 节点\n', i);
    % n1
    iNO = iNO+1;
    fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
        iNO, n1(i,1), n1(i,2), n1(i,3));
    % n1~n2, 先上后下
    for j = 1 : Num_n1_n2
        [x_temp, y_temp, z_temp] = interp(n1(i,:), n2(i,:), Num_n1_n2, j);

        iNO = iNO+1;
        fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
            iNO, x_temp, y_temp, z_temp);
    end
    for j = 1 : Num_n1_n2
        [x_temp, y_temp, z_temp] = interp(n1(i,:), n2_l(i,:), Num_n1_n2, j);

        iNO = iNO+1;
        fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
            iNO, x_temp, y_temp, z_temp);
    end
    % n2~n23, 先上后下
    iNO = iNO+1;
    fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
        iNO, n2(i,1), n2(i,2), n2(i,3));
    for j = 1 : Num_n2_n23
        [x_temp, y_temp, z_temp] = interp(n2(i,:), n23(i,:), Num_n2_n23, j);

        iNO = iNO+1;
        fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
            iNO, x_temp, y_temp, z_temp);
    end
    iNO = iNO+1;
    fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
        iNO, n2_l(i,1), n2_l(i,2), n2_l(i,3));
    for j = 1 : Num_n2_n23
        [x_temp, y_temp, z_temp] = interp(n2_l(i,:), n23_l(i,:), Num_n2_n23, j);

        iNO = iNO+1;
        fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
            iNO, x_temp, y_temp, z_temp);
    end
    % n23~n3, 先上后下
    iNO = iNO+1;
    fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
        iNO, n23(i,1), n23(i,2), n23(i,3));
    for j = 1 : Num_n23_n3
        [x_temp, y_temp, z_temp] = interp(n23(i,:), n3(i,:), Num_n23_n3, j);

        iNO = iNO+1;
        fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
            iNO, x_temp, y_temp, z_temp);
    end
    iNO = iNO+1;
    fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
        iNO, n3(i,1), n3(i,2), n3(i,3));
    iNO = iNO+1;
    fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
        iNO, n23_l(i,1), n23_l(i,2), n23_l(i,3));
    for j = 1 : Num_n23_n3
        [x_temp, y_temp, z_temp] = interp(n23_l(i,:), n3(i,:), Num_n23_n3, j);

        iNO = iNO+1;
        fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
            iNO, x_temp, y_temp, z_temp);
    end
    % n23_0
    iNO = iNO+1;
    fprintf(fileID,'   %d, %.4f, %.4f, %.4f\n',...
        iNO, n23_0(i,1), n23_0(i,2), n23_0(i,3));
end
fprintf(fileID,'\n');

%% CONSTRAINT
fprintf(fileID,'*CONSTRAINT    ; Supports\n');
fprintf(fileID,'; NODE_LIST, CONST(Dx,Dy,Dz,Rx,Ry,Rz), GROUP\n');

CONSTRAINT = 111111; % 刚接

fprintf(fileID,'; 柱底刚接\n');
iNO = iNO_Radial_init; % 初始化iNO
for i = 1:length(n1) % 榀
    iNO = iNO + Node_Itvl;
    fprintf(fileID,'   %d, %d, \n',...
        iNO, CONSTRAINT);
end
fprintf(fileID,'\n');

%% CONLOAD
fprintf(fileID,'*CONLOAD    ; Nodal Loads');
fprintf(fileID,'; NODE_LIST, FX, FY, FZ, MX, MY, MZ, GROUP');

iNO_end = iNO;
fprintf(fileID,'; 节点力\n');
for iNO = 1:iNO_end
    fprintf(fileID,'   %d, 0, 0, %d, 0, 0, 0, \n',...
        iNO, FZ);
end
fprintf(fileID,'\n');

end