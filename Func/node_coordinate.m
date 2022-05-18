%% function
% node & coordinate
%
% Xu Yi, 2022.5.17

%%
function node_coordinate(iNO, X_c, Y_c, Z_c)
load('./Data/YH.mat', 'Node_Coordinate');
Node_Coordinate = [Node_Coordinate; iNO, X_c, Y_c, Z_c];
save('./Data/YH.mat','Node_Coordinate','-append');
end