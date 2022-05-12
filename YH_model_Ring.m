%% function
% MGT
%
% Xu Yi, 2022.5.12

%%
function iEL_end = YH_model_Ring(fileID, iNO, iEL,...
    Num_Radial,...
    Num_n1_n2, Num_n2_n23, Num_n23_n3, Node_Itvl, FZ)
%% ELEMENT
fprintf(fileID,'*ELEMENT    ; Elements\n');
fprintf(fileID,'; iEL, TYPE, iMAT, iPRO, iN1, iN2, ANGLE, iSUB, EXVAL, iOPT(EXVAL2) ; Frame  Element\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, ANGLE, iSUB, EXVAL, EXVAL2, bLMT ; Comp/Tens Truss\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, iN3, iN4, iSUB, iWID , LCAXIS    ; Planar Element\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, iN3, iN4, iN5, iN6, iN7, iN8     ; Solid  Element\n');

ELE_TYPE = 'BEAM'; ELE_iMAT = 1; ELE_ANGLE = 0; ELE_iSUB = 0;  % iMAT = 1材料钢结构Q345

iNO_init = - Node_Itvl;
ELE_iPRO_Ring_inner = 12;
ELE_iPRO_Ring_Outer = 12;
ELE_iPRO_Cable_t = 3;
ELE_iPRO_Cable_b = 3;
ELE_iPRO_Truss_Can_t = 6;
ELE_iPRO_Truss_Can_b = 6;
ELE_iPRO_Truss_End_t = 9;
ELE_iPRO_Truss_End_b = 9;

TENSTR_F4 = 200;

fprintf(fileID,'; Ring\n');

ELE_TYPE = 'BEAM';
ELE_iMAT = 1;
ELE_iSUB = 0;
% 内环
fprintf(fileID,'; InnerRing\n');
ELE_iPRO = ELE_iPRO_Ring_inner;
iNO = iNO_init; % 初始化iNO
for i = 1 : Num_Radial % 榀
    iNO = iNO + Node_Itvl;
    iNO = iNO + 1; % 逐点定义
    iN1 = iNO;
    if i == Num_Radial
        iN2 = iNO_init + Node_Itvl + 1;
    else
        iN2 = iN1 + Node_Itvl;
    end
    iEL = iEL+1;
    fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
        iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
        iN1, iN2,...    % 斜交网格单元的两个节点号
        ELE_ANGLE, ELE_iSUB);
    iNO = iNO - 1;
end

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
    for j = 1 : Num_n1_n2
        iNO = iNO + 1; % 逐点定义
        iN1 = iNO + 1;
        if i == Num_Radial
            iN2 = iNO_init + Node_Itvl + 1 + j;
        else
            iN2 = iN1 + Node_Itvl;
        end
        iEL = iEL+1;
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d, %d, 1\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 斜交网格单元的两个节点号
            ELE_ANGLE, ELE_iSUB, TENSTR_F4);
    end
    iNO = iNO - Num_n1_n2;
end
% 下索
fprintf(fileID,'; CableBottom\n');
ELE_iPRO = ELE_iPRO_Cable_b;
iNO = iNO_init; % 初始化iNO
for i = 1 : Num_Radial % 榀
    iNO = iNO + Node_Itvl;
    for j = 1 : Num_n1_n2
        iNO = iNO + 1; % 逐点定义
        iN1 = iNO + Num_n1_n2 + 1;
        if i == Num_Radial
            iN2 = iNO_init + Node_Itvl + Num_n1_n2 + 1 + j;
        else
            iN2 = iN1 + Node_Itvl;
        end
        iEL = iEL+1;
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d, %d, 1\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 斜交网格单元的两个节点号
            ELE_ANGLE, ELE_iSUB, TENSTR_F4);
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
        if i == Num_Radial
            iN2 = iNO_init + Node_Itvl + Num_n1_n2 * 2 + 1 + j;
        else
            iN2 = iN1 + Node_Itvl;
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
        if i == Num_Radial
            iN2 = iNO_init + Node_Itvl + (Num_n1_n2 * 2 + 1) + Num_n2_n23 + 1 + j;
        else
            iN2 = iN1 + Node_Itvl;
        end
        iEL = iEL+1;
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 斜交网格单元的两个节点号
            ELE_ANGLE, ELE_iSUB);
    end
    iNO = iNO - (Num_n2_n23 + 1);
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
        if i == Num_Radial
            iN2 = iNO_init + Node_Itvl + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3) + j;
        else
            iN2 = iN1 + Node_Itvl;
        end
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
        iN1 = iNO + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3) + Num_n23_n3 + 2;
        if i == Num_Radial
            iN2 = iNO_init + Node_Itvl + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3) + Num_n23_n3 + 2 + j;
        else
            iN2 = iN1 + Node_Itvl;
        end
        iEL = iEL+1;
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 斜交网格单元的两个节点号
            ELE_ANGLE, ELE_iSUB);
    end
    iNO = iNO - (Num_n23_n3 + 1);
end
% 外环
ELE_TYPE = 'BEAM';
ELE_iMAT = 1;
ELE_iSUB = 0;
fprintf(fileID,'; OuterRing\n');
ELE_iPRO = ELE_iPRO_Ring_Outer;
iNO = iNO_init; % 初始化iNO
for i = 1 : Num_Radial % 榀
    iNO = iNO + Node_Itvl;
    iNO = iNO + 1; % 逐点定义
    iN1 = iNO + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3) + Num_n23_n3 + 1;
    if i == Num_Radial
        iN2 = iNO_init + Node_Itvl + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3) + Num_n23_n3 + 1 + 1;
    else
        iN2 = iN1 + Node_Itvl;
    end
    iEL = iEL+1;
    fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
        iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
        iN1, iN2,...    % 斜交网格单元的两个节点号
        ELE_ANGLE, ELE_iSUB);
    iNO = iNO - 1;
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
