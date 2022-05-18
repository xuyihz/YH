%%
close all; clear; clc;

%%
D1 = 100;
D2 = 100;
D3 = 100;
Element_Diameter = [D1; D2; D3];
Element_Youngs = 185;

load('YH.mat', 'Element_Property');
for i = 1:length(Element_Property)
    if Element_Property(i,2) > length(Element_Diameter)
        Element_Property(i,2) = Element_Diameter( 1 );
    else
        Element_Property(i,2) = Element_Diameter( Element_Property(i,2) );
    end
    Element_Property(i,3) = Element_Youngs;
end
save('YH.mat','Element_Property','-append');
