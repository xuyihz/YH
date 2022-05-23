%% function
% MGT
%
% Xu Yi, 2022.5.12

%%
function iEL_end = YH_model_Ring(fileID, iNO, iEL,...
    Num_Radial, Node_Itvl, n_iNo_Start, n_Ring_num,...
    Num_n1_n2, Num_n2_n23, Num_n23_n3, FZ, MatFile)
%% ELEMENT
fprintf(fileID,'*ELEMENT    ; Elements\n');
fprintf(fileID,'; iEL, TYPE, iMAT, iPRO, iN1, iN2, ANGLE, iSUB, EXVAL, iOPT(EXVAL2) ; Frame  Element\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, ANGLE, iSUB, EXVAL, EXVAL2, bLMT ; Comp/Tens Truss\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, iN3, iN4, iSUB, iWID , LCAXIS    ; Planar Element\n; iEL, TYPE, iMAT, iPRO, iN1, iN2, iN3, iN4, iN5, iN6, iN7, iN8     ; Solid  Element\n');
ELE_TYPE = 'BEAM'; ELE_iMAT = 1; ELE_ANGLE = 0; ELE_iSUB = 0;  % iMAT = 1材料钢结构Q345

n2_Ring_num = n_Ring_num{1}; n2_l_Ring_num = n_Ring_num{2}; n2_n23_Ring_num = n_Ring_num{3};
n23_Ring_num = n_Ring_num{4}; n23_l_Ring_num = n_Ring_num{5}; n23_n3_Ring_num = n_Ring_num{6};
n3_Ring_num = n_Ring_num{7}; n_sum_Ring_num = n_Ring_num{8};

n1_iNo_Start = n_iNo_Start(1); n2_iNo_Start = n_iNo_Start(2); n2_l_iNo_Start = n_iNo_Start(3);
n23_iNo_Start = n_iNo_Start(4); n23_l_iNo_Start = n_iNo_Start(5); n23_0_iNo_Start = n_iNo_Start(6);
n3_iNo_Start = n_iNo_Start(7); iNO_Ring_Start = n_iNo_Start(8);

iNO_init = - Node_Itvl;
ELE_iPRO_Ring_inner = 3;
ELE_iPRO_Ring_Outer = 12;
ELE_iPRO_Cable_t = 3;
ELE_iPRO_Cable_b = 3;
ELE_iPRO_Truss_Can_t = 6;
ELE_iPRO_Truss_Can_b = 6;
ELE_iPRO_Truss_Can_w = 6;
ELE_iPRO_Truss_End_t = 9;
ELE_iPRO_Truss_End_b = 9;
ELE_iPRO_Truss_End_w = 9;

TENSTR_F4 = 2000;

fprintf(fileID,'; Ring\n');

% ELE_TYPE = 'BEAM';
% ELE_iMAT = 1;
% ELE_iSUB = 0;
ELE_TYPE = 'TENSTR';
ELE_iMAT = 3; % User Define Cable
ELE_iSUB = 3; % TENSTR/Cable
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
    % 梁
    %     fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
    %         iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
    %         iN1, iN2,...    % 单元的两个节点号
    %         ELE_ANGLE, ELE_iSUB);
    % 索
    fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d, %d, 1\n',...
        iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
        iN1, iN2,...    % 单元的两个节点号
        ELE_ANGLE, ELE_iSUB, TENSTR_F4);
    if MatFile == true
        element_node(iEL, iN1, iN2);                    % 拓扑关系 记录到.mat
        element_property(iEL, ELE_iPRO, ELE_iMAT);      % 属性(直径/弹性模量) 记录到.mat
    end
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
            iN1, iN2,...    % 单元的两个节点号
            ELE_ANGLE, ELE_iSUB, TENSTR_F4);
        if MatFile == true
            element_node(iEL, iN1, iN2);                    % 拓扑关系 记录到.mat
            element_property(iEL, ELE_iPRO, ELE_iMAT);      % 属性(直径/弹性模量) 记录到.mat
        end
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
            iN1, iN2,...    % 单元的两个节点号
            ELE_ANGLE, ELE_iSUB, TENSTR_F4);
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
n_Ring_num_temp = [n2_Ring_num; n2_n23_Ring_num];
% 上弦
fprintf(fileID,'; Truss_Can_Top\n');
ELE_iPRO = ELE_iPRO_Truss_Can_t;
for i = 1 : Num_Radial % 榀
    iNO = iNO_init + Node_Itvl*i + (Num_n1_n2 * 2 + 1); % 初始化iNO    % 加上索桁架的节点数
    iNO_Ring = iNO_Ring_Start + n_sum_Ring_num*(i-1);   % 初始化iNO_Ring
    for j = 1 : (Num_n2_n23 + 1)
        iNO = iNO + j; % 逐点定义
        if j == 1
        else
            iNO_Ring = iNO_Ring + n_Ring_num_temp(j-1)*2;   % 上下弦各一环
        end
        for k = 1 : ( n_Ring_num_temp(j) + 1 )
            if k == 1
                iN1 = iNO;
                iN2 = iNO_Ring + k - 1;
            elseif k == ( n_Ring_num_temp(j) + 1 )
                iN1 = iNO_Ring + k - 2;
                if i == Num_Radial
                    iN2 = iNO_init + Node_Itvl + Num_n1_n2 * 2 + 1 + j;
                else
                    iN2 = iNO + Node_Itvl;
                end
            else
                iN1 = iNO_Ring + k - 2;
                iN2 = iNO_Ring + k - 1;
            end
            iEL = iEL+1;
            fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
                iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
                iN1, iN2,...    % 斜交网格单元的两个节点号
                ELE_ANGLE, ELE_iSUB);
        end
        iNO = iNO_init + Node_Itvl*i + (Num_n1_n2 * 2 + 1); % 初始化iNO
    end
end
% 下弦
fprintf(fileID,'; Truss_Can_Bottom\n');
ELE_iPRO = ELE_iPRO_Truss_Can_b;
for i = 1 : Num_Radial % 榀
    iNO = iNO_init + Node_Itvl*i + (Num_n1_n2 * 2 + 1) + Num_n2_n23 + 1; % 初始化iNO   % 加上索桁架的节点数
    iNO_Ring = iNO_Ring_Start + n_sum_Ring_num*(i-1);   % 初始化iNO_Ring
    for j = 1 : (Num_n2_n23 + 1)
        iNO = iNO + j; % 逐点定义
        if j == 1
        else
            iNO_Ring = iNO_Ring + n_Ring_num_temp(j-1)*2;   % 上下弦各一环
        end
        for k = 1 : ( n_Ring_num_temp(j) + 1 )
            if k == 1
                iN1 = iNO;
                iN2 = iNO_Ring + k - 1 + n_Ring_num_temp(j);
            elseif k == ( n_Ring_num_temp(j) + 1 )
                iN1 = iNO_Ring + k - 2 + n_Ring_num_temp(j);
                if i == Num_Radial
                    iN2 = iNO_init + Node_Itvl + (Num_n1_n2 * 2 + 1) + Num_n2_n23 + 1 + j;
                else
                    iN2 = iNO + Node_Itvl;
                end
            else
                iN1 = iNO_Ring + k - 2 + n_Ring_num_temp(j);
                iN2 = iNO_Ring + k - 1 + n_Ring_num_temp(j);
            end
            iEL = iEL+1;
            fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
                iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
                iN1, iN2,...    % 斜交网格单元的两个节点号
                ELE_ANGLE, ELE_iSUB);
        end
        iNO = iNO_init + Node_Itvl*i + (Num_n1_n2 * 2 + 1) + Num_n2_n23 + 1; % 初始化iNO
    end
end
% 腹杆
fprintf(fileID,'; Truss_Can_Web\n');
ELE_iPRO = ELE_iPRO_Truss_Can_w;
for i = 1 : Num_Radial % 榀
    iNO = iNO_init + Node_Itvl*i + (Num_n1_n2 * 2 + 1); % 初始化iNO    % 加上索桁架的节点数
    iNO_Ring = iNO_Ring_Start + n_sum_Ring_num*(i-1);   % 初始化iNO_Ring
    for j = 1 : (Num_n2_n23 + 1)
        iNO = iNO + j; % 逐点定义
        if j == 1
        else
            iNO_Ring = iNO_Ring + n_Ring_num_temp(j-1)*2;   % 上下弦各一环
        end
        for k = 1 : n_Ring_num_temp(j)  % 竖杆
            iN1 = iNO_Ring + k - 1;
            iN2 = iNO_Ring + k - 1 + n_Ring_num_temp(j);

            iEL = iEL+1;
            fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
                iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
                iN1, iN2,...    % 斜交网格单元的两个节点号
                ELE_ANGLE, ELE_iSUB);
        end
        for k = 1 : ( n_Ring_num_temp(j) + 1 )    % 斜杆
            if k == 1
                iN1 = iNO;
                iN2 = iNO_Ring + k - 1 + n_Ring_num_temp(j);
            elseif k == ( n_Ring_num_temp(j) + 1 )
                iN1 = iNO_Ring + k - 2;
                if i == Num_Radial
                    iN2 = iNO_init + Node_Itvl + (Num_n1_n2 * 2 + 1) + Num_n2_n23 + 1 + j;
                else
                    iN2 = iNO + Num_n2_n23 + 1 + Node_Itvl;
                end
            else
                iN1 = iNO_Ring + k - 2;
                iN2 = iNO_Ring + k - 1 + n_Ring_num_temp(j);
            end
            iEL = iEL+1;
            fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
                iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
                iN1, iN2,...    % 斜交网格单元的两个节点号
                ELE_ANGLE, ELE_iSUB);
        end
        iNO = iNO_init + Node_Itvl*i + (Num_n1_n2 * 2 + 1); % 初始化iNO
    end
end

% 钢桁架(根部)
ELE_TYPE = 'BEAM';
ELE_iMAT = 1;
ELE_iSUB = 0;
fprintf(fileID,'; Truss_End\n');
n_Ring_num_temp = [n23_Ring_num; n23_n3_Ring_num];
% 上弦
fprintf(fileID,'; Truss_End_Top\n');
ELE_iPRO = ELE_iPRO_Truss_End_t;
for i = 1 : Num_Radial % 榀
    iNO = iNO_init + Node_Itvl*i + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3); % 初始化iNO
    iNO_Ring = iNO_Ring_Start + n_sum_Ring_num*(i-1)...
        + n2_Ring_num + n2_l_Ring_num + sum(n2_n23_Ring_num)*2;   % 初始化iNO_Ring
    for j = 1 : (Num_n23_n3 + 1)
        iNO = iNO + j; % 逐点定义
        if j == 1
        else
            iNO_Ring = iNO_Ring + n_Ring_num_temp(j-1)*2;   % 上下弦各一环
        end
        for k = 1 : ( n_Ring_num_temp(j) + 1 )
            if k == 1
                iN1 = iNO;
                iN2 = iNO_Ring + k - 1;
            elseif k == ( n_Ring_num_temp(j) + 1 )
                iN1 = iNO_Ring + k - 2;
                if i == Num_Radial
                    iN2 = iNO_init + Node_Itvl + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3) + j;
                else
                    iN2 = iNO + Node_Itvl;
                end
            else
                iN1 = iNO_Ring + k - 2;
                iN2 = iNO_Ring + k - 1;
            end
            iEL = iEL+1;
            fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
                iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
                iN1, iN2,...    % 斜交网格单元的两个节点号
                ELE_ANGLE, ELE_iSUB);
        end
        iNO = iNO_init + Node_Itvl*i + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3); % 初始化iNO
    end
end
% 下弦
fprintf(fileID,'; Truss_End_Bottom\n');
ELE_iPRO = ELE_iPRO_Truss_End_b;
for i = 1 : Num_Radial % 榀
    iNO = iNO_init + Node_Itvl*i + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3) + (Num_n23_n3 + 2); % 初始化iNO
    iNO_Ring = iNO_Ring_Start + n_sum_Ring_num*(i-1)...
        + n2_Ring_num + n2_l_Ring_num + sum(n2_n23_Ring_num)*2;   % 初始化iNO_Ring
    for j = 1 : (Num_n23_n3 + 1)
        iNO = iNO + j; % 逐点定义
        if j == 1
        else
            iNO_Ring = iNO_Ring + n_Ring_num_temp(j-1)*2;   % 上下弦各一环
        end
        for k = 1 : ( n_Ring_num_temp(j) + 1 )
            if k == 1
                iN1 = iNO;
                iN2 = iNO_Ring + k - 1 + n_Ring_num_temp(j);
            elseif k == ( n_Ring_num_temp(j) + 1 )
                iN1 = iNO_Ring + k - 2 + n_Ring_num_temp(j);
                if i == Num_Radial
                    iN2 = iNO_init + Node_Itvl + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3) + (Num_n23_n3 + 2) + j;
                else
                    iN2 = iNO + Node_Itvl;
                end
            else
                iN1 = iNO_Ring + k - 2 + n_Ring_num_temp(j);
                iN2 = iNO_Ring + k - 1 + n_Ring_num_temp(j);
            end
            iEL = iEL+1;
            fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
                iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
                iN1, iN2,...    % 斜交网格单元的两个节点号
                ELE_ANGLE, ELE_iSUB);
        end
        iNO = iNO_init + Node_Itvl*i + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3) + (Num_n23_n3 + 2); % 初始化iNO
    end
end
% 腹杆
fprintf(fileID,'; Truss_End_Web\n');
ELE_iPRO = ELE_iPRO_Truss_End_w;
for i = 1 : Num_Radial % 榀
    iNO = iNO_init + Node_Itvl*i + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3); % 初始化iNO
    iNO_Ring = iNO_Ring_Start + n_sum_Ring_num*(i-1)...
        + n2_Ring_num + n2_l_Ring_num + sum(n2_n23_Ring_num)*2;   % 初始化iNO_Ring
    for j = 1 : (Num_n23_n3 + 1)
        iNO = iNO + j; % 逐点定义
        if j == 1
        else
            iNO_Ring = iNO_Ring + n_Ring_num_temp(j-1)*2;   % 上下弦各一环
        end
        for k = 1 : n_Ring_num_temp(j)  % 竖杆
            iN1 = iNO_Ring + k - 1;
            iN2 = iNO_Ring + k - 1 + n_Ring_num_temp(j);

            iEL = iEL+1;
            fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
                iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
                iN1, iN2,...    % 斜交网格单元的两个节点号
                ELE_ANGLE, ELE_iSUB);
        end
        for k = 1 : ( n_Ring_num_temp(j) + 1 )    % 斜杆
            if k == 1
                iN1 = iNO;
                iN2 = iNO_Ring + k - 1 + n_Ring_num_temp(j);
            elseif k == ( n_Ring_num_temp(j) + 1 )
                iN1 = iNO_Ring + k - 2;
                if i == Num_Radial
                    iN2 = iNO_init + Node_Itvl + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3) + Num_n23_n3 + 2 + j;
                else
                    iN2 = iNO + Num_n23_n3 + 2 + Node_Itvl;
                end
            else
                iN1 = iNO_Ring + k - 2;
                iN2 = iNO_Ring + k - 1 + n_Ring_num_temp(j);
            end
            iEL = iEL+1;
            fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
                iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
                iN1, iN2,...    % 斜交网格单元的两个节点号
                ELE_ANGLE, ELE_iSUB);
        end
        iNO = iNO_init + Node_Itvl*i + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3); % 初始化iNO
    end
end
% 外环
ELE_TYPE = 'BEAM';
ELE_iMAT = 1;
ELE_iSUB = 0;
fprintf(fileID,'; OuterRing\n');
n_Ring_num_temp = n3_Ring_num;
ELE_iPRO = ELE_iPRO_Ring_Outer;
for i = 1 : Num_Radial % 榀
    iNO = iNO_init + Node_Itvl*i + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3) + (Num_n23_n3 + 1); % 初始化iNO
    iNO_Ring = iNO_Ring_Start + n_sum_Ring_num*(i-1)...
        + n2_Ring_num + n2_l_Ring_num + 2*sum(n2_n23_Ring_num)...
        + n23_Ring_num + n23_l_Ring_num + 2*sum(n23_n3_Ring_num);   % 初始化iNO_Ring

    iNO = iNO + 1; % 逐点定义
    for k = 1 : ( n_Ring_num_temp(1) + 1 )
        if k == 1
            iN1 = iNO;
            iN2 = iNO_Ring + k - 1;
        elseif k == ( n_Ring_num_temp(1) + 1 )
            iN1 = iNO_Ring + k - 2;
            if i == Num_Radial
                iN2 = iNO_init + Node_Itvl + (Num_n1_n2 * 2 + Num_n2_n23 * 2 + 3) + (Num_n23_n3 + 1) + 1;
            else
                iN2 = iNO + Node_Itvl;
            end
        else
            iN1 = iNO_Ring + k - 2;
            iN2 = iNO_Ring + k - 1;
        end
        iEL = iEL+1;
        fprintf(fileID,'   %d, %s, %d, %d, %d, %d, %d, %d\n',...
            iEL, ELE_TYPE, ELE_iMAT, ELE_iPRO,...
            iN1, iN2,...    % 斜交网格单元的两个节点号
            ELE_ANGLE, ELE_iSUB);
    end
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
