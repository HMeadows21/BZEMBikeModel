function [TTDATA] = DataExtractor(Data)

Time = Data(4:end,1);
MotorRPM = Data(4:end,504);
MotorTorque = Data(4:end,505); 
BatteryCurrent = Data(4:end,506);
InverterCapVoltage = Data(4:end,515);
TTDATA = table2array([Time,MotorRPM,MotorTorque,BatteryCurrent,InverterCapVoltage]);
TTDATA(:,1) = TTDATA(:,1) - (table2array(Data(4,1)));


end