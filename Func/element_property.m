%% function
% element & property
%
% Xu Yi, 2022.5.17

%%
function element_property(Element_iNO, diameter, Youngs)
load('./Data/YH.mat', 'Element_Property');
Element_Property = [Element_Property; Element_iNO, diameter, Youngs];
save('./Data/YH.mat','Element_Property','-append');
end