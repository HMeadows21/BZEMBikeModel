function [Result] = Control(BikeConfig,DriveCycle,Tstep)

bypass = 0;

warning('OFF');     %scatter interpolate in the efficiency lookup function makes lots of warning so turn them off to speed up programme

Eout = 0;           %start from 100% SoC
rho = 1.225;            %set air density
CurrentSpeed = 0;   %set start speed
x = 0;              %set start distance
t = 1;              %set time step

if bypass == 0
    DCSpeed = DriveCycle(2,:);  %extract speed from drive cycle
    DCAlt = DriveCycle(3,:);    %extract altitude from drive cycle
    DCDist = DriveCycle(1,:);   %extract distances from drive cycle
else
    DCSpeed = DriveCycle(1,:)';
    DCTorque = DriveCycle(2,:)';
end

%START: Load Maps%
MMapFile = [BikeConfig.Motor,'_eff_map.csv'];
ME = readtable(MMapFile, 'HeaderLines',1);

IMapFile = [BikeConfig.Inverter,'_eff_map.csv'];
I = readtable(IMapFile, 'HeaderLines',1);

CellFile = [BikeConfig.Cell,'_V_map.csv'];
B = readtable(CellFile);

MotorFile = [BikeConfig.Motor,'_P_map.csv'];
ML = readtable(MotorFile);
%END%

if bypass == 0
    while x < (DCDist(end))     %while within the drivecycle length
        State = find(round(x) >= DCDist);    %find which area of the drive cycle the bike is in
        State = State(end);

        MSpeed = (CurrentSpeed/BikeConfig.wheelrad)*BikeConfig.gear;    %find current motor speed
        
        if (CurrentSpeed == 0) 
            Accel = (DCSpeed(State+1)-CurrentSpeed)/Tstep;      %calculate neccisary acceleration to get to speed at next drive cycle point
        elseif (State == length(DCDist))
            Accel = (DCSpeed(State)-CurrentSpeed)/Tstep; 
        else
            T2Goal = (DCDist(State+1)-x)/CurrentSpeed;
            Accel = (DCSpeed(State+1)-CurrentSpeed)/T2Goal;      %calculate neccisary acceleration to get to speed at next drive cycle point
        end

        ATorque = ((Accel*BikeConfig.mass)*BikeConfig.wheelrad)/BikeConfig.gear;    %work torque to get that acceleration

        Drag = CurrentSpeed^2*0.5*rho*BikeConfig.area*BikeConfig.cd;    %work out drag aty current speed

        if State<length(DCAlt)          %check if biek is in last section of drive cycle
            Gravity = sin(atan((DCAlt(State+1)-DCAlt(State))/(DCDist(State+1)-DCDist(State))))*BikeConfig.mass*9.81;    %calculate dradient and gravitational force
        else
            Gravity = sin(atan((DCAlt(State)-DCAlt(State-1))/(DCDist(State)-DCDist(State-1))))*BikeConfig.mass*9.81;    %calculate dradient and gravitational force
        end

        RollRes = BikeConfig.RollRes;       %extract rolling resistance force
        SMTorque = ((Drag + Gravity + RollRes)*BikeConfig.wheelrad)/BikeConfig.gear;    %add the resistances together and convert to torque
        TTorque = SMTorque + ATorque;       %add speed maintaining torque and acceleration torque

        [Torque,MSpeed,Repeat] = Limit_Analysis(ML,MSpeed,ATorque,SMTorque);    %use limit analysis to check if point is achievable
        
        if Torque > -100
            BrakeForce = 0;
        else
            BrakeForce = (abs(TTorque - Torque)*BikeConfig.gear)/BikeConfig.wheelrad;
            if BrakeForce > 300
                BrakeForce = 300;
            end
        end

        if Repeat == 1      %repeat becomes one if the speed is reduced by the limit analysis function
            Speed  = (MSpeed/BikeConfig.gear)*BikeConfig.wheelrad;      %calculate bike speed from motor speed
            Drag = Speed^2*0.5*rho*BikeConfig.area*BikeConfig.cd;       %recalculate drag
            SMTorque = ((Drag + Gravity + RollRes)*BikeConfig.wheelrad)/BikeConfig.gear;    %recalculate speed maintaining torque
            [Torque,MSpeed,Repeat] = Limit_Analysis(ML,MSpeed,ATorque,SMTorque);    %redo limit analysis to get a corrected torque
        end

        OldSpeed = CurrentSpeed;            %set current speed as old speed
        CurrentSpeed = CurrentSpeed + ((((((Torque-SMTorque)*BikeConfig.gear))/BikeConfig.wheelrad)- BrakeForce)/BikeConfig.mass)*Tstep;    %calculate speed at next time step
        x = x + ((CurrentSpeed+OldSpeed)/2)*Tstep;      %calculate distance covered in next time step
        
        [LossM,PinM,LossI,PinI,LossB,Ptotal,Eout,SoC] = Loss_Finder(ME,I,B,BikeConfig.SeriesNo,BikeConfig.ParallelNo,Eout,Torque,MSpeed,Tstep);  %calculate losses
        Result(:,t) = [(t-1)*Tstep;OldSpeed;x;Torque;MSpeed;PinM;PinI;Ptotal;LossM;LossI;LossB;Eout;SoC;BrakeForce;0;0;0;0;0;DCSpeed(State+1)];        %store results
        t = t+1;        %index time step variable

    end
else
    DCSpeed = DCSpeed*(2*pi())/60;
    while t <= length(DCSpeed)
        
        [LossM,PinM,LossI,PinI,LossB,Ptotal,Eout,SoC] = Loss_Finder(ME,I,B,BikeConfig.SeriesNo,BikeConfig.ParallelNo,Eout,DCTorque(t),DCSpeed(t),Tstep);  %calculate losses
        Speed  = (DCSpeed(t)/BikeConfig.gear)*BikeConfig.wheelrad;      %calculate bike speed from motor speed
        Result(:,t) = [(t-1)*Tstep;Speed;x;DCTorque(t);DCSpeed(t);PinM;PinI;Ptotal;LossM;LossI;LossB;Eout;SoC;0;0;0;0;0;0;DCSpeed];        %store results
        t = t+1;        %index time step variable
        if t == 100
            hello = 1;
        end
    end
end

warning('ON');     %scatter interpolate in the efficiency lookup function makes lots of warning so turn them off to speed up programme
end