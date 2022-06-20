### Rhino 提取源数据

1. 从Rhino模型中导出内环、中环、外环的点。

   > 保存在 **..\计算模型\Rhino ** 下，分别为 **n1.txt** (内环)、**n2**(外环上点)、**n3**(最外环)
   >
   > 运行 **..\计算模型\MATLAB\Rhino** 下 **YH_Rhino_Node.m**
   >
   > 保存数据至 **..\计算模型\MATLAB\Data** 下的 **YH_Rhino_Node.mat**
   >

2. 生成源数据

   > 运行 **..\计算模型\MATLAB** 下的 **YH.m**
   >
   > 生成 **..\计算模型\MATLAB\Data** 下的 **YH.mat**

### MATLAB x ANSYS (APDL)

> **..\计算模型\MATLAB\ANSYS**
>
> 运行 **YH_ANSYS.m**

1. 运行Shape_Est.m，判断形态是否合理

   > 如不合理，则需要调整形态

2. 运行YH_ANSYS_Model.m生成APDL的建模文件

   > .\ANSYS\ANSYS_Files\1.Model.ansys.txt
   >
   > 导入Mechanical中即可生成ANSYS模型

3. 运行YH_ANSYS_Solu_Radial.m生成ANSYS的分析文件(计算Radial方向)

   > .\ANSYS\ANSYS_Files\2.SOLU_Radial.ansys.txt
   >
   > 在1的基础上，导入Mechanical中即可运行计算
   >
   > 求得上索、下索的自应力模态
   >
   > 通过APDL的VWRITE命令分别写入
   >
   > .\ANSYS\Model\下：	2.1EPEL_T.txt(上索) / 2.2EPEL_B.txt(下索)

4. 运行Result.m把2.1EPEL_T.txt(上索) / 2.2EPEL_B.txt(下索)转化为.mat文件储存

   > ./MATLAB/Data/YH_ANSYS.mat

5. 运行 YH_Module_FormFinding 迭代计算，确定下索形态

   > 确定自应力模态
   >
   > 已知：上索、下索的应变值 / 保证上索、环索的形态不变
   >
   > 可得：下索的力的方向，得到下索的形态 (按初始抛物线垂度确定新的支座位置)
   >
   > 经过多次迭代收敛，得到单榀的找形结果。
   >
   > 进而得到整体模型的找形结果，及自应力模态。

6. 运行 XXX 生成APDL的建模计算文件，验证找形结果

   

### ANSYS (APDL) to MIDAS (MGT)

1. 生成MGT文件

   > 运行 **..\计算模型\MATLAB\MIDAS** 下的 **APDL2MGT.m**
   >
   > 生成 **YH_cable.mgt** 导入MIDAS GEN进行计算