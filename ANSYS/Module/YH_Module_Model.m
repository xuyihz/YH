%% Generate APDL file
% Build Model
% ANSYS APDL file
% Xu Yi, 2022.5.24

%%
function YH_Module_Model(Node_Coordinate, Node_Support,...
    Element_Node, Element_Property,...
    AREA, EM, MD,...
    ANSYS_JName, ANSYS_JTitle, FileDir, SupportSwitch)

%%
% 其中环向索仅导入了内环
% load('../../Data/YH.mat',...      % 数据文件位置
%     'Node_Coordinate',...   % [节点编号, X坐标, Y坐标, Z坐标]
%     'Node_Support',...      % [节点编号, X约束, Y约束, Z约束]
%     'Element_Node',...      % [单元编号, 节点编号1, 节点编号2]
%     'Element_Property',...  % [单元编号, 索直径编号, 索弹性模量编号]
%     'Num_Radial',...        % 榀数
%     'Num_n1_n2',...         % n1~n2间的分隔数 (索桁架处)
%     'Node_Itvl',...         % 每一榀的节点数
%     'iEL_Ring');            % 内环起始单元编号

%% ANSYS APDL
fileID = fopen(FileDir,'w');   % Open or create new file for writing. Discard existing contents, if any.

% 初始化
fprintf(fileID,'FINISH\n');
fprintf(fileID,'/CLEAR\n');
fprintf(fileID,'/FILNAME, %s\n', ANSYS_JName);
fprintf(fileID,'/TITLE, %s\n', ANSYS_JTitle);

% % 把Element_Property的数据导入APDL同名数组
% Row_EP = length(Element_Property(:,1));
% Col_EP = length(Element_Property(1,:));
% fprintf(fileID,'*DIM, Element_Property, ARRAY, %d, %d\n', Row_EP, Col_EP);
% for i = 1 : Row_EP
%     for j = 1 : Col_EP
%         fprintf(fileID,'Element_Property(%d,%d)=%d\n', i, j, Element_Property(i,j));
%     end
% end

% 前处理
fprintf(fileID,'!进入前处理\n');
fprintf(fileID,'/PREP7\n');
% 单元类型、材料等 LINK180/CABLE280
% ET, ITYPE, Ename, KOP1, KOP2, KOP3, KOP4, KOP5, KOP6, INOPR
% Defines a local element type from the element library.
fprintf(fileID,'ET, 1, LINK180\n');
% R, NSET, R1, R2, R3, R4, R5, R6
% Defines the element real constants.
fprintf(fileID,'R, 1, %f\n', AREA);
% MP, Lab, MAT, C0, C1, C2, C3, C4
% Defines a linear material property as a constant or a function of temperature.
fprintf(fileID,'MP, EX, 1, %f\n', EM);  % EX: Elastic moduli
fprintf(fileID,'MP, PRXY, 1, 0.3\n');   % PRXY: Major Poisson's ratios
fprintf(fileID,'MP, DENS, 1, %f\n', MD);% DENS: Mass density.
% 节点
% *DIM, Par, Type, IMAX, JMAX, KMAX, Var1, Var2, Var3, CSYSID 
% Defines an array parameter and its dimensions.
% % 把Node_Coordinate的数据导入APDL同名数组
% Row_NC = length(Node_Coordinate(:,1));
% Col_NC = length(Node_Coordinate(1,:));
% fprintf(fileID,'*DIM, Node_Coordinate, ARRAY, %d, %d\n', Row_NC, Col_NC);
% for i = 1 : Row_NC
%     for j = 1 : Col_NC
%         fprintf(fileID,'Node_Coordinate(%d,%d)=%d\n', i, j, Node_Coordinate(i,j));
%     end
% end
for i = 1 : length(Node_Coordinate(:,1))
    iNo_N = Node_Coordinate(i,1);
    iX = Node_Coordinate(i,2);
    iY = Node_Coordinate(i,3);
    iZ = Node_Coordinate(i,4);
    % N, NODE, X, Y, Z, THXY, THYZ, THZX
    % Defines a node.
    fprintf(fileID,'N, %d, %f, %f, %f\n', iNo_N, iX, iY, iZ);
end
% 单元
% % 把Element_Node的数据导入APDL同名数组
% Row_EN = length(Element_Node(:,1));
% Col_EN = length(Element_Node(1,:));
% fprintf(fileID,'*DIM, Element_Node, ARRAY, %d, %d\n', Row_EN, Col_EN);
% for i = 1 : Row_EN
%     for j = 1 : Col_EN
%         fprintf(fileID,'Element_Node(%d,%d)=%d\n', i, j, Element_Node(i,j));
%     end
% end
for i = 1 : length(Element_Node(:,1))
    iNo_E = Element_Node(i,1);
    iNo_N1 = Element_Node(i,2);
    iNo_N2 = Element_Node(i,3);
    % EN, IEL, I, J, K, L, M, N, O, P
    % Defines an element by its number and node connectivity.
    fprintf(fileID,'EN, %d, %d, %d\n', iNo_E, iNo_N1, iNo_N2);
end
% 约束
% 逐点去约束法：先把所有节点都约束，逐步去掉恢复各节点约束，迭代求解
% 额外约束
if SupportSwitch == 1
    for i = 1 : length(Node_Coordinate(:,1))
        iNo_N = Node_Coordinate(i,1);
        for j = 1 : length(Node_Support(:,1))
            if iNo_N == Node_Support(j,1)
                continue;
            end
        end
        fprintf(fileID,'D, %d, UX\n', iNo_N);
        fprintf(fileID,'D, %d, UY\n', iNo_N);
        fprintf(fileID,'D, %d, UZ\n', iNo_N);
    end
end
% 支座
% % 把Node_Support的数据导入APDL同名数组
% Row_NS = length(Node_Support(:,1));
% Col_NS = length(Node_Support(1,:));
% fprintf(fileID,'*DIM, Node_Support, ARRAY, %d, %d\n', Row_NS, Col_NS);
% for i = 1 : Row_NS
%     for j = 1 : Col_NS
%         fprintf(fileID,'Node_Support(%d,%d)=%d\n', i, j, Node_Support(i,j));
%     end
% end
for i = 1 : length(Node_Support(:,1))
    iNo_N = Node_Support(i,1);
    UX_bool = Node_Support(i,2);
    UY_bool = Node_Support(i,3);
    UZ_bool = Node_Support(i,4);
    % D, Node, Lab, VALUE, VALUE2, NEND, NINC, Lab2, Lab3, Lab4, Lab5, Lab6
    % Defines degree-of-freedom constraints at nodes.
    if UX_bool == 1
        fprintf(fileID,'D, %d, UX\n', iNo_N);
    end
    if UY_bool == 1
        fprintf(fileID,'D, %d, UY\n', iNo_N);
    end
    if UZ_bool == 1
        fprintf(fileID,'D, %d, UZ\n', iNo_N);
    end
end
% 退出模块
fprintf(fileID,'FINISH\n');

%%
fclose('all');

end