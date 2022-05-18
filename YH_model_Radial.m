%% function
% MGT
%
% Xu Yi, 2022.5.12

%%
function iEL_end = YH_model_Radial(fileID, iNO, iEL,...
    Num_Radial, Node_Itvl, n_iNo_Start, n_Ring_num,...
    Num_n1_n2, Num_n2_n23, Num_n23_n3, FZ, MatFile)
%% ELEMENT
fprintf(fileID,'*ELEMENT    ; Elements\n');
fprintf(fileID,'; iEL, TYPE, iMAT, iPRO, iN1, iN2, ANGLE, iSUB, EXVAL, iOPT(EXVAL2) ; Frame  Element\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, ANGLE, iSUB, EXVAL, EXVAL2, bLMT ; Comp/Tens Truss\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, iN3, iN4, iSUB, iWID , LCAXIS    ; Planar Element\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, iN3, iN4, iN5, iN6, iN7, iN8     ; Solid  Element\n');

ELE_TYPE = 'BEAM'; ELE_iMAT = 1; ELE_ANGLE = 0; ELE_iSUB = 0;  % iMAT = 1材料钢结构Q345

iNO_init = - Node_Itvl;
ELE_iPRO_Cable_t = 1;
ELE_iPRO_Cable_b = 2;
ELE_iPRO_Cable_m = 3;
ELE_iPRO_Truss_Can_t = 4;
ELE_iPRO_Truss_Can_b = 5;
ELE_iPRO_Truss_Can_w = 6;
ELE_iPRO_Truss_End_t = 7;
ELE_iPRO_Truss_End_b = 8;
ELE_iPRO_Truss_End_w = 9;
ELE_iPRO_Column_S = 10;
ELE_iPRO_Column_L = 11;

TENSTR_F1 = 2000;
TENSTR_F2 = 2000;
TENSTR_F3 = 200;

fprintf(fileID,'; 榀\n');

% 索桁架
ELE_TYPE = 'TENSTR';
ELE_iMAT = 3; % User Define Cable
ELE_iSUB = 3; % TENSTR/Cable
fprintf(fileID,'; Cable\n');
% 上索
fprintf(fileID,'; CableTop\n');
ELE_iPRO = ELE_iPRO_Cable_t;
iNO = iNO_init; % 初始化iNO
for i = 1 : Num_Radial % 榀
    iNO = iNO + Node_Itvl;
    for j = 1 : (Num_n1_n2 + 1)
        iNO = iNO + 1; % 逐点定义
        iN1 = iNO;
        if j == (Num_n1_n2 + 1)
            iN2 = iN1 + 1 + Num_n1_n2;
        else
            iN2 = iN1 + 1;
        end
        iEL = iEL+1;
        % 以下语句为索单元，比梁单元多最后两项
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d, %d, 1\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 单元的两个节点号
            ELE_ANGLE, ELE_iSUB, TENSTR_F1);
        if MatFile == true
            element_node(iEL, iN1, iN2);                    % 拓扑关系 记录到.mat
            element_property(iEL, ELE_iPRO, ELE_iMAT);      % 属性(直径/弹性模量) 记录到.mat
        end
    end
    iNO = iNO - (Num_n1_n2 + 1);
end
% 下索
fprintf(fileID,'; CableBottom\n');
ELE_iPRO = ELE_iPRO_Cable_b;
iNO = iNO_init; % 初始化iNO
for i = 1 : Num_Radial % 榀
    iNO = iNO + Node_Itvl;
    for j = 1 : (Num_n1_n2 + 1)
        iNO = iNO + 1; % 逐点定义
        if j == 1
            iN1 = iNO;
        else
            iN1 = iNO + Num_n1_n2;
        end
        if j == (Num_n1_n2 + 1)
            iN2 = iN1 + Num_n2_n23 + 2;
        else
            iN2 = iNO + Num_n1_n2 + 1;
        end
        iEL = iEL+1;
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d, %d, 1\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 单元的两个节点号
            ELE_ANGLE, ELE_iSUB, TENSTR_F2);
        if MatFile == true
            element_node(iEL, iN1, iN2);                    % 拓扑关系 记录到.mat
            element_property(iEL, ELE_iPRO, ELE_iMAT);      % 属性(直径/弹性模量) 记录到.mat
        end
    end
    iNO = iNO - (Num_n1_n2 + 1);
end
% 系索
fprintf(fileID,'; CableM\n');
ELE_iPRO = ELE_iPRO_Cable_m;
iNO = iNO_init; % 初始化iNO
for i = 1 : Num_Radial % 榀
    iNO = iNO + Node_Itvl;
    for j = 1 : Num_n1_n2
        iNO = iNO + 1; % 逐点定义
        iN1 = iNO + 1;
        iN2 = iN1 + Num_n1_n2;
        iEL = iEL+1;
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d, %d, 1\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 单元的两个节点号
            ELE_ANGLE, ELE_iSUB, TENSTR_F3);
        if MatFile == true
            element_node(iEL, iN1, iN2);                    % 拓扑关系 记录到.mat
            element_property(iEL, ELE_iPRO, ELE_iMAT);      % 属性(直径/弹性模量) 记录到.mat
        end
    end
    iNO = iNO - Num_n1_n2;
end

% 钢桁架(悬挑)
ELE_TYPE = 'BEAM';
ELE_iMAT = 1;
ELE_iSUB = 0;
fprintf(fileID,'; Truss_Can\n');
% 上弦
fprintf(fileID,'; Truss_Can_Top\n');
ELE_iPRO = ELE_iPRO_Truss_Can_t;
iNO = iNO_init; % 初始化iNO
for i = 1 : Num_Radial % 榀
    iNO = iNO + Node_Itvl;
    for j = 1 : (Num_n2_n23 + 1)
        iNO = iNO + 1; % 逐点定义
        iN1 = iNO + (Num_n1_n2 * 2 + 1);
        if j == (Num_n2_n23 + 1)
            iN2 = iN1 + (1 + Num_n2_n23) + 1;
        else
            iN2 = iN1 + 1;
        end
        iEL = iEL+1;
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 斜交网格单元的两个节点号
            ELE_ANGLE, ELE_iSUB);
    end
    iNO = iNO - (Num_n2_n23 + 1);
end
% 下弦
fprintf(fileID,'; Truss_Can_Bottom\n');
ELE_iPRO = ELE_iPRO_Truss_Can_b;
iNO = iNO_init; % 初始化iNO
for i = 1 : Num_Radial % 榀
    iNO = iNO + Node_Itvl;
    for j = 1 : (Num_n2_n23 + 1)
        iNO = iNO + 1; % 逐点定义
        iN1 = iNO + (Num_n1_n2 * 2 + 1) + Num_n2_n23 + 1;
        if j == (Num_n2_n23 + 1)
            iN2 = iN1 + (1 + Num_n2_n23) + 1;
        else
            iN2 = iN1 + 1;
        end
        iEL = iEL+1;
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 斜交网格单元的两个节点号
            ELE_ANGLE, ELE_iSUB);
    end
    iNO = iNO - (Num_n2_n23 + 1);
end
% 腹杆
fprintf(fileID,'; Truss_Can_M\n');
ELE_iPRO = ELE_iPRO_Truss_Can_w;
iNO = iNO_init; % 初始化iNO
for i = 1 : Num_Radial % 榀
    iNO = iNO + Node_Itvl;
    iN1 = iNO + (Num_n1_n2 * 2 + 2);
    iN2 = iN1 + Num_n2_n23 + 1;
    iEL = iEL+1;
    fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
        iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
        iN1, iN2,...    % 斜交网格单元的两个节点号
        ELE_ANGLE, ELE_iSUB);
    for j = 1 : Num_n2_n23
        iNO = iNO + 1; % 逐点定义

        iN1 = iNO + (Num_n1_n2 * 2 + 1) + 1;
        iN2 = iN1 + Num_n2_n23;
        iEL = iEL+1;
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 斜交网格单元的两个节点号
            ELE_ANGLE, ELE_iSUB);

        iN2 = iN2 + 1;
        iEL = iEL+1;
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 斜交网格单元的两个节点号
            ELE_ANGLE, ELE_iSUB);
    end
    iN1 = iNO + (Num_n1_n2 * 2 + 1) + 1 + Num_n2_n23 + 2;
    iN2 = iN2;
    iEL = iEL+1;
    fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
        iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
        iN1, iN2,...    % 斜交网格单元的两个节点号
        ELE_ANGLE, ELE_iSUB);
    iNO = iNO - Num_n2_n23;
end

% 钢桁架(根部)
ELE_TYPE = 'BEAM';
ELE_iMAT = 1;
ELE_iSUB = 0;
fprintf(fileID,'; Truss_End\n');
% 上弦
fprintf(fileID,'; Truss_End_Top\n');
ELE_iPRO = ELE_iPRO_Truss_End_t;
iNO = iNO_init; % 初始化iNO
for i = 1 : Num_Radial % 榀
    iNO = iNO + Node_Itvl;
    for j = 1 : (Num_n23_n3 + 1)
        iNO = iNO + 1; % 逐点定义
        iN1 = iNO + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3);
        iN2 = iN1 + 1;
        iEL = iEL+1;
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 斜交网格单元的两个节点号
            ELE_ANGLE, ELE_iSUB);
    end
    iNO = iNO - (Num_n23_n3 + 1);
end
% 下弦
fprintf(fileID,'; Truss_End_Bottom\n');
ELE_iPRO = ELE_iPRO_Truss_End_b;
iNO = iNO_init; % 初始化iNO
for i = 1 : Num_Radial % 榀
    iNO = iNO + Node_Itvl;
    for j = 1 : (Num_n23_n3 + 1)
        iNO = iNO + 1; % 逐点定义
        iN1 = iNO + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3) + Num_n23_n3 + 1;
        if j == (Num_n23_n3 + 1)
            iN2 = iN1 - Num_n23_n3;
        else
            iN2 = iN1 + 1;
        end
        iEL = iEL+1;
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 斜交网格单元的两个节点号
            ELE_ANGLE, ELE_iSUB);
    end
    iNO = iNO - (Num_n23_n3 + 1);
end
% 腹杆
fprintf(fileID,'; Truss_End_M\n');
ELE_iPRO = ELE_iPRO_Truss_End_w;
iNO = iNO_init; % 初始化iNO
for i = 1 : Num_Radial % 榀
    iNO = iNO + Node_Itvl;
    for j = 1 : Num_n23_n3
        iNO = iNO + 1; % 逐点定义
        iN1 = iNO + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3) + 1;
        iN2 = iN1 + Num_n23_n3 + 1;
        iEL = iEL+1;
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 斜交网格单元的两个节点号
            ELE_ANGLE, ELE_iSUB);

        iN2 = iN2 + 1;
        iEL = iEL+1;
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 斜交网格单元的两个节点号
            ELE_ANGLE, ELE_iSUB);
    end
    iNO = iNO - Num_n23_n3;
end

% 钢柱
ELE_TYPE = 'BEAM';
ELE_iMAT = 1;
ELE_iSUB = 0;
fprintf(fileID,'; Column\n');
% 直柱
ELE_iPRO = ELE_iPRO_Column_S;
iNO = iNO_init; % 初始化iNO
for i = 1 : Num_Radial % 榀
    iNO = iNO + Node_Itvl;

    iN1 = iNO + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 4);
    iN2 = iN1 + Num_n23_n3 + 2;
    iEL = iEL+1;
    fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
        iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
        iN1, iN2,...    % 斜交网格单元的两个节点号
        ELE_ANGLE, ELE_iSUB);

    iEL = iEL+1;
    iN1 = iN2;
    iN2 = iN2 + Num_n23_n3 + 1;
    fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
        iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
        iN1, iN2,...    % 斜交网格单元的两个节点号
        ELE_ANGLE, ELE_iSUB);
end
% 斜柱
ELE_iPRO = ELE_iPRO_Column_L;
iNO = iNO_init; % 初始化iNO
for i = 1 : Num_Radial % 榀
    iNO = iNO + Node_Itvl;

    iN1 = iNO + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + Num_n23_n3 * 1 + 5);
    iN2 = iN1 + Num_n23_n3 + 2;
    iEL = iEL+1;
    fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
        iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
        iN1, iN2,...    % 斜交网格单元的两个节点号
        ELE_ANGLE, ELE_iSUB);
end

iEL_end = iEL;
fprintf(fileID,'\n');

%% CONLOAD
% fprintf(fileID,'*CONLOAD    ; Nodal Loads');
% fprintf(fileID,'; NODE_LIST, FX, FY, FZ, MX, MY, MZ, GROUP');
%
% fprintf(fileID,'; 下层网格外 杆件节点力\n');
% for iNO = iNO_Lower_init+1:iNO_Lower_end
%     fprintf(fileID,'   %d, 0, 0, %d, 0, 0, 0, \n',...
%         iNO, FZ);
% end
% fprintf(fileID,'\n');

end
