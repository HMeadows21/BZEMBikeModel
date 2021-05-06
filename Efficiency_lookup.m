function [Eff] = Efficiency_lookup(T,Torque,Speed)

Testmode = 0;

Torque = abs(Torque);

SpeedData = (table2array(T(1,2:end)))';
TorqueData = (table2array(T(2,2:end)))';

EffData = (table2array(T(3,2:end)))';

InterpEff = scatteredInterpolant(SpeedData,TorqueData,EffData,'linear');

Eff = InterpEff(Speed,Torque);

if Testmode == 1
    TAxis = flip(0:5:max(TorqueData)+5);
    SAxis = 0:50:max(SpeedData)+50;

    [Y,X]=ndgrid(TAxis,SAxis);
    
    InterpData = (InterpEff(X,Y))+0.05;

    figure
    hold on
    contour(SAxis,TAxis,InterpData,[86,90,93,94,95])
    plot(Speed,Torque,'ro')
    ylim([0,600])
    xlim([0,4500])
    hold off
    %surf(SAxis,TAxis,InterpData)
end

end
