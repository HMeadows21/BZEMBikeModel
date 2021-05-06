function waterout = Radfcn(airtemp,airspeed,waterin,pipelength,pipeno,pipespacing,finpitch,PipeDepth,PipeWidth)

dmw = 0.1;
u = ((dmw/1000)/(PipeDepth*PipeWidth))/pipeno;

L = pipelength;
Hdw = (4*PipeDepth*PipeWidth)/(2*PipeDepth+2*PipeWidth);

AirflowArea = pipelength*pipespacing*(pipeno-1);
Fins = round(pipelength/finpitch);
AirPerim = (2*pipelength*pipeno)+(2*Fins*pipespacing*(pipeno-1));
Hda = (4*AirflowArea)/AirPerim;

AveWtemp = waterin;
filmT1 = (waterin + airtemp)/2;
filmT2 = (waterin + airtemp)/2;

for x = 1
    [Rew,Prw,Grw,kw,Cpw] = Variablefinder('water',filmT1,AveWtemp,u,Hdw);
    [Rea,Pra,Gra,ka,Cpa] = Variablefinder('air',filmT2,airtemp,airspeed,Hda);
    
    if Rew <= 2300
        Nuw = 3.66;     %value for laminar flow in a pipe with constant surface temp
    else
       Nuw = 0.023*(Rew^(4/5))*(Prw^0.3);   %equation for turbulent flow in a cooling pipe
    end
    
    if Rea <= 2300
        Nua = 3.66;     %value for laminar flow in a pipe with constant surface temp
    else
       Nua = 0.023*(Rea^(4/5))*(Pra^0.3);   %equation for turbulent flow in a 
    end
    
%     if Rea <= (5*10^5)
%         Nua = 0.664*(Rea^(1/2))*(Pra^(1/3));
%     else
%         Nua = ((0.037*(Rea^(4/5)))-871)*(Pra^(1/3));
%     end
    
    h1 = Nuw*kw/Hdw;
    h2 = Nua*ka/Hda;

    R1 = 1/((2*PipeDepth+2*PipeWidth)*L*h1);
    R2 = 0.01;
    R3 = 1/(AirPerim*PipeDepth*h2);
    Rt = R1 + R2 + R3;
    
    waterout = airtemp - (airtemp-waterin)*exp(-1/(dmw*Cpw*Rt/pipeno));

    AveWtemp = (waterin + waterout)/2;
    AvedQ = dmw*Cpw*(waterin - waterout);
    
    dT1 = AvedQ*R1;
    %dT2 = AvedQ*R2;
    dT3 = AvedQ*R3;
    
    filmT1 = AveWtemp - (dT1/2);
    filmT2 = airtemp + (dT3/2);   
end

end
