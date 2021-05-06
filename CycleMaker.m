function [DriveCycle] = CycleMaker()

input = 0:1:1500;

RSpeed = [100,100,500,700,400];
RDist = [0,100,700,1000,4000];

Speed = interp1(RDist,RSpeed,input,'spline');  %input;
Alt = zeros(1,length(Speed));   %20*sin(input/50);
Dist = input;

DriveCycle = [Speed;Alt;Dist];

end