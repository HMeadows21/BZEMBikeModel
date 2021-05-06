function [LossB,SoC] = Cell_looukup(C,SeriesNo,ParallelNo,PinI,Eout)

PinI = abs(PinI);

%**extract cell data from map**
CellR = table2array(C(4,1));
CellQ = table2array(C(6,1));
CellCurve = table2array(C(2:3,3:end));
Ilist = table2array(C(9:end,1))';

SoC = round(((SeriesNo*ParallelNo*CellQ-Eout)/(SeriesNo*ParallelNo*CellQ))*100);    %find state of charge based on batery size and energy used

if SoC>100      %stop battery from going over 100% charge
    SoC = 100;
end
if SoC<00       %stop battery from going under 0% charge
    SoC = 00;
end

ICell = 0;      %start from 0A

for x = 1:3     %repeat for 3 loops
    CellCurve = [interp1(CellCurve(1,:),CellCurve(2,:),0:1:100,'spline');0:1:100];      %interpolate current voltage map

    VC = CellCurve(1,find(CellCurve(2,:)==SoC));    %calculate voltage with 0A current
    VB = VC*SeriesNo;                               %work out battery voltage
    IB = PinI/VB;                                   %work out battery current
    ICell = IB/ParallelNo;                          %work out current per cell
    
    [MinVal,ClosestIndex] = min(abs(Ilist-ICell));      %find closest voltage map at closest current
    
    CellCurve = [table2array(C(2,3:end));table2array(C(ClosestIndex+2,3:end))];     %change to new voltage map
end

LossB = ICell*ICell*CellR*SeriesNo*ParallelNo;      %work out loss with P = I^2*R*No of cells

end