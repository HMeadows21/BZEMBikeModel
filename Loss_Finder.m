function [LossM,PinM,LossI,PinI,LossB,Ptotal,Eout,SoC] = Loss_Finder(ME,I,B,SeriesNo,ParallelNo,Eout,Torque,Speed,Tstep)

neg = 1;
if Torque<0
    neg = -1;
end

Pout = Torque*Speed;

Speed = Speed*60/(2*pi());

EffM = Efficiency_lookup(ME,Torque,Speed)/100;
if neg == 1
    PinM = Pout/EffM;
else
    PinM = Pout*EffM;
end
LossM = abs(PinM-Pout);

EffI = Efficiency_lookup(I,Torque,Speed)/100;
if neg == 1
    PinI = PinM/EffI;
else
    PinI = PinM*EffI;
end
LossI = abs(PinI-PinM);

if EffM == 0
    PinM = 0;
    LossM = 0;
end
if EffI == 0
    PinI = 0;
    LossI=0;
end

[LossB,SoC] = Cell_looukup(B,SeriesNo,ParallelNo,PinI,Eout);

Ptotal = PinI + LossB;
Eout = Eout+Ptotal*Tstep;

end