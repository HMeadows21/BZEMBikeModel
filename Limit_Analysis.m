function [Torque,Speed,Repeat] = Limit_Analysis(M,Speed,ATorque,SMTorque)

Speed = 60*Speed/(2*pi());
testmode = 0;
Repeat = 0;

TTorque = round(ATorque+SMTorque,1);
Speed = round(Speed);

neg = 1;
if TTorque >= 0
    MotorCurve = table2array(M(1:2,2:end));
else
    MotorCurve = table2array(M(4:5,2:end));
    neg = -1;
end

TTorque = abs(TTorque);

MotorCurve = [0:1:max(MotorCurve(1,:));round(interp1(MotorCurve(1,:),MotorCurve(2,:),0:1:max(MotorCurve(1,:)),'spline'),1)];

MaxSpeed = max(MotorCurve(1,:));
MaxSpeedT = MotorCurve(2,find(MaxSpeed == MotorCurve(1,:)));

if Speed >= MaxSpeed
    Repeat = 1;
    Speed = MaxSpeed;
    if MaxSpeedT > SMTorque
        Torque = SMTorque;
    else
        Torque = MaxSpeedT;
    end
else
    Tlim = MotorCurve(2,find(Speed == MotorCurve(1,:)));
    Tdif = Tlim - TTorque;
    if Tdif < 0
        Torque = Tlim;
    else
        Torque = TTorque;
    end
end

Torque = Torque*neg;

if testmode == 1
    figure
    hold on
    plot(MotorCurve(1,:),MotorCurve(2,:))
    plot(Speed,Torque,'or')
    grid minor
    hold off
end

Speed = Speed*(2*pi())/60;
end