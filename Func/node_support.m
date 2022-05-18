%% function
% node & support
%
% Xu Yi, 2022.5.17

%%
function node_support(iNO, X_spt, Y_spt, Z_spt)
load('./Data/YH.mat', 'Node_Support');
Node_Support = [Node_Support; iNO, X_spt, Y_spt, Z_spt];
save('./Data/YH.mat','Node_Support','-append');
end