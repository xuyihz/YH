%% function
% element & node
%
% Xu Yi, 2022.5.17

%%
function element_node(Element_iNO, Node_iNO_1, Node_iNO_2)
load('./Data/YH.mat', 'Element_Node');
Element_Node = [Element_Node; Element_iNO, Node_iNO_1, Node_iNO_2];
save('./Data/YH.mat','Element_Node','-append');
end