%%Control model variables%%
BikeConfig.Motor = 'emrax';
BikeConfig.Inverter = 'sevcon';
BikeConfig.Cell = 'VTC6';
BikeConfig.SeriesNo = 150;
BikeConfig.ParallelNo = 14;
BikeConfig.wheelrad = 0.3;
BikeConfig.gear = 2.3;
BikeConfig.mass = 250;
BikeConfig.area = 1;
BikeConfig.cd = 0.4;
BikeConfig.RollRes = 50;

airtemp = 20;

%%Inverter Model Variables%%
StartTempI = 295;
PLi = 3.2;
PDi = 0.01;
Li = 0.488;
Hi = 0.250;
Di = 0.085;

MIc = 2.5;
CpIc = 500; %380;
MIbf = 7;
MIbw = 1;
CpIb = 887;

Rcb = 0.001;
Rba = 0.001;

%%%%%%%%%
Rtc = 0.1;
Rcbb = 1;
Rcf = 9.36;
Lw = 1.5;
La = 1.5;
%%%%%%%%

%%Motor Model Variables%%
StartTempM = 291;

PLm = 0.721;
PDm = 0.01;

Mc = 19;
Mmag = 0.2;
Mcase = 1.1;

Cpcore = 812;
Cpmag = 502.5;
Cpcase = 481;

CoreRm = 0.250/2;
CoreDm = 0.07;
Rm = 0.268/2;
Dm = 0.08;

Rcc = 3;
Rmc = 0.01;

ACderate = 0.7910;
PSplit = 0.95;

%%Battery Model Variables%%
Nt = 7;
Nl = 20;
Nv = 14;