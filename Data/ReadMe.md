运行完 YH.m 后

运行 property.m 把 ELE_iPRO, ELE_iMAT 的编号 转换为具体数值

> 注意保证 property.m 中的数值 与 YH_init.m 中的数值及顺序一致



Node_Coordinate = [节点编号, X坐标, Y坐标, Z坐标]

> 坐标单位为mm



Node_Support = [节点编号, X约束, Y约束, Z约束]

> 约束的值为1时表示约束，为0时表示不约束。其中XYZ均未约束的节点未列入。



Element_Node = [单元编号, 节点编号1, 节点编号2]



Element_Property = [单元编号, 索直径, 索弹性模量]

> 直径单位为mm，弹性模量单位为$\mathrm {kN/mm^2}$

