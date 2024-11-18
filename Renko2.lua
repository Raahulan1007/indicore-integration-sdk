function Init()
    indicator:name("Renko indicator");
    indicator:description("Renko indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator:setTag("replaceSource", "t");

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Step", "Step in pips", "", 100);

end

local first;
local source = nil;
local Step;
local BuffUP=nil;
local BuffDN=nil;
local RenkoBuff;
local RenkoBuffShift;
local i;
local open = nil;
local high = nil;
local low = nil;
local close = nil;


function Prepare()
    source = instance.source.close;
    Step=instance.parameters.Step;
    first = source:first()+2;
    RenkoBuff = instance:addInternalStream(first, 0);
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Step .. ")";
    instance:name(name);
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("Renko", "Renko", open, high, low, close);
end

function CheckBuff(period)
 local ii;
 if RenkoBuffShift>period then
  for ii=first+1,period,1 do
   RenkoBuff[ii-1]=RenkoBuff[ii];
  end
  RenkoBuffShift=RenkoBuffShift-1;
 end
end

function Update(period, mode)
   if (period==source:size()-1) then
    RenkoBuffShift=first;
    RenkoBuff[RenkoBuffShift]=source[first];
    for i=first+1,period,1 do
     if RenkoBuffShift==first then
      while source[i]>RenkoBuff[RenkoBuffShift]+Step*source:pipSize() do
       RenkoBuffShift=RenkoBuffShift+1;
       CheckBuff(period);
       RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]+Step*source:pipSize();
      end
      while source[i]<RenkoBuff[RenkoBuffShift]-Step*source:pipSize() do
       RenkoBuffShift=RenkoBuffShift+1;
       CheckBuff(period);
       RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]-Step*source:pipSize();
      end
     end
     
     if RenkoBuff[RenkoBuffShift]>RenkoBuff[RenkoBuffShift-1] then
      if source[i]>RenkoBuff[RenkoBuffShift]+Step*source:pipSize() then
       while source[i]>RenkoBuff[RenkoBuffShift]+Step*source:pipSize() do
        RenkoBuffShift=RenkoBuffShift+1;
        CheckBuff(period);
        RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]+Step*source:pipSize();
       end
      end
      if source[i]<RenkoBuff[RenkoBuffShift]-2.*Step*source:pipSize() then
       RenkoBuffShift=RenkoBuffShift+1;
       CheckBuff(period);
       RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]-2.*Step*source:pipSize();
       while source[i]<RenkoBuff[RenkoBuffShift]-Step*source:pipSize() do
        RenkoBuffShift=RenkoBuffShift+1;
        CheckBuff(period);
        RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]-Step*source:pipSize();
       end
      end
     end
     
     if RenkoBuff[RenkoBuffShift]<RenkoBuff[RenkoBuffShift-1] then
      if source[i]<RenkoBuff[RenkoBuffShift]-Step*source:pipSize() then
       while source[i]<RenkoBuff[RenkoBuffShift]-Step*source:pipSize() do
        RenkoBuffShift=RenkoBuffShift+1;
        CheckBuff(period);
        RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]-Step*source:pipSize();
       end
      end
      if source[i]>RenkoBuff[RenkoBuffShift]+2.*Step*source:pipSize() then
       RenkoBuffShift=RenkoBuffShift+1;
       CheckBuff(period);
       RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]+2.*Step*source:pipSize();
       while source[i]>RenkoBuff[RenkoBuffShift]+Step*source:pipSize() do
        RenkoBuffShift=RenkoBuffShift+1;
        CheckBuff(period);
        RenkoBuff[RenkoBuffShift]=RenkoBuff[RenkoBuffShift-1]+Step*source:pipSize();
       end
      end
     end
     
    end
    
    for i=first,period,1 do
     local NewPos=i-period+RenkoBuffShift;
     if NewPos<=first then
      open[i]=nil;
      close[i]=nil;
      low[i]=nil;
      high[i]=nil;
     else
      if RenkoBuff[NewPos]>RenkoBuff[NewPos-1] then
       open[i]=RenkoBuff[NewPos]-Step*source:pipSize();
       close[i]=RenkoBuff[NewPos];
       high[i]=close[i];
       low[i]=open[i];
      else
       open[i]=RenkoBuff[NewPos]+Step*source:pipSize();
       close[i]=RenkoBuff[NewPos];
       high[i]=open[i];
       low[i]=close[i];
      end 
     end
    end
    
   end 
end

