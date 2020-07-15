%THIS FILE CREATES GCODE FOR USE WITH THE OSMM PUMP. IT USES DIALOG BOXES TO 
%GET VALUES FROM THE USER. IF A FILE ALREADY EXISTS, IT WILL QUERY WHETHER THAT
%FILE SHOULD BE APPENDED OR REPLACED

%WRITTEN BY JOSHUA M. MACEACHERN. LICENSED FOR USE UNDER THE CREATIVE COMMONS 0 LICENSE
%https://creativecommons.org/publicdomain/zero/1.0/legalcode

%ESTABLISH WORKING FILENAME
%MAKE SURE THE LOCATION EXISTS. IF NOT, GET FROM USER
%GET FILEPATH IF NOT OTHERWISE DECLARED. 
%THIS ALLOWS THE CODE TO ITERATE AND ADD MORE CODES AFTER RUNNING ONCE
if (exist("path") && isempty(path)) || !exist(path)
    path = uigetdir("Where would you like to save your file?")
    if path == 0 || isempty(path)
      return
    end
    
end
if (exist("file") && isempty(file)) || !exist("file")
   file = inputdlg("What would you like to name your file?")
   if isempty(file)
     return
   end
   
end




%CHECK TO SEE IF THE FILE ALREADY EXISTS
%IF THE FILE EXISTS, QUERY TO SEE IF THIS SHOULD REPLACE OR APPEND TO THE EXISTING FILE
if exist(strcat(path,char(file), ".gcode")) && !exist("gCodeFile", "var") 
  prompt = strcat("The file", " ", char(file), ".gcode already exists.");
  replace = questdlg(prompt,'Continue?', "Replace", 'Append', 'Replace');
  if strcmp(replace, "Replace")
    gCodeFile = fopen(strcat(path,char(file), ".gcode"), 'wt');
    %gCodeFile = []
    clear replace
  elseif strcmp(replace, "Append")
    gCodeFile = fopen(strcat(path,char(file), ".gcode"), 'at');
    clear replace
  else
    return
  end
else
  gCodeFile = fopen(strcat(path,char(file), ".gcode"), 'at');
end




%GET INPUT FLOW FROM USER
prompt = {"Flow Rate A", "Flow Rate B", "Flow Rate C", "Flow Rate D", "Flow Rate E"};
defaults = {"0.0", "0.0", "0.0", "0.0", "0.0"};
rowscols = [1,25;1,25;1,25;1,25;1,25];
title = "Enter pump flow rate in uL/min";
amounts = inputdlg(prompt,title, rowscols, defaults);
volumeA = str2double(amounts(1));
volumeB = str2double(amounts(2));
volumeC = str2double(amounts(3));
volumeD = str2double(amounts(4));
volumeE = str2double(amounts(5));
totalFlow = sqrt(volumeA^2+volumeB^2+volumeC^2+volumeD^2+volumeE^2);

%GET TOTAL COMMAND DURATION FROM USER
%IF TIME IS EMPTY, ITERATE UNTIL THE USER INPUTS A TIME
prompt = {"Days", "Hours", "Minutes", "Seconds", "MilliSeconds"};
title = "Enter command duration";
function [time, timeMatrix] = timeInput(prompt, title, rowscols, defaults)
  timeMatrix = inputdlg(prompt, title, rowscols, defaults);
  time = (str2double(timeMatrix(1))*1440+...      %CONVERT TIME MATRIX INTO DECIMAL MINUTES
        str2double(timeMatrix(2))*60+...
        str2double(timeMatrix(3))+...
        str2double(timeMatrix(4))/60+...
        str2double(timeMatrix(5))/60000);
  if isempty(time) || time == 0 %IF THE USER DOES NOT INPUT ANY PERIOD OF TIME
    waitfor(errordlg("You must give a period of time."))
    timeInput(prompt, title, rowscols, defaults)
  end
  
end
[time, timeMatrix] = timeInput(prompt, title, rowscols, defaults);
        
%OUTPUT IF ANY FLOW RATE IS DECLARED AS 0. MOSTLY A FAILSAFE.
if volumeA == 0
  fprintf("No output for pump A declared, assuming 0 \n")
end

if volumeB == 0
  fprintf("No output for pump B declared, assuming 0 \n")
end

if volumeC == 0
  fprintf("No output for pump C declared, assuming 0 \n")
end

if volumeD == 0
  fprintf("No output for pump D declared, assuming 0 \n")
end

if volumeE == 0
  fprintf("No output for pump E declared, assuming 0 \n")
end
if isnan(volumeA) || isnan(volumeB) || isnan(volumeC) || isnan(volumeD) || isnan(volumeE) || isnan(time) || isnan(totalFlow)
  errordlg("Something went very wrong. Hopefully you never see this error. If you do see this error, god help you.")
  clear all
  return
end
%SANITY CHECK, MAKE SURE ALL ENTERED VALUES ARE CORRECT
if (volumeA ==0) && (volumeB ==0) && (volumeC == 0) && (volumeD ==0) && (volumeE == 0)
  check = questdlg({"That line was empty.", "Do you want to create a pause for that duration?"},...
            "Empty Line", "Yes", "No", "No") 
else
    check = "Absolutely Not";
end
      
%CONVERT FLOW RATE INTO VOLUME      
volumeA = volumeA*time;
volumeB = volumeB*time;
volumeC = volumeC*time;
volumeD = volumeD*time;
volumeE = volumeE*time;

%GENERATE GCODE LINE
if strcmp(check, "Yes")
  gcode = cstrcat("G4 ", "S", num2str(time*60));
else
  gcode = cstrcat("G1 ","X", num2str(volumeA), ' ', ...
                "Y", num2str(volumeB), " ", ...
                "Z", num2str(volumeC), " ", ...
                "I", num2str(volumeD), " ", ...
                "J", num2str(volumeE), " ", ...
                "F", num2str(totalFlow));
end
         
         
prompt = {strcat("Pump A Flow Rate:", " ", num2str(volumeA/time), "uL/min"),...
          strcat("Pump B Flow Rate:", " ", num2str(volumeB/time), "uL/min"),...
          strcat("Pump C Flow Rate:", " ", num2str(volumeC/time), "uL/min"),...
          strcat("Pump D Flow Rate:", " ", num2str(volumeD/time), "uL/min"),...
          strcat("Pump E Flow Rate:", " ", num2str(volumeE/time), "uL/min"),...
          strcat(char(timeMatrix(1)), " days,", " ", char(timeMatrix(2)), " hours, ", " ",...
                 char(timeMatrix(3)), " minutes, ", " ", char(timeMatrix(4)), " seconds, ", char(timeMatrix(5)), " milliseconds")};
check = questdlg(prompt,'Correct?', "Yes", 'No', 'Yes');
if strcmp(check, "No")
  gcode_creator_flowRate
end  

fprintf(gCodeFile, '\n%s\n', gcode);
printf(strcat('Gcode:', " ",gcode, "\n"))
fclose(gCodeFile);
%QUERY IF WOULD LIKE TO ADD MORE

  cont = questdlg("Would you like to add more commands?",...
                "Continue?", "Yes", "No");
if strcmp(cont, "Yes")
  gcode_creator_flowRate
  %fclose(gCodeFile);
elseif strcmp(cont, "No")
  %file = [];
  %fclose(gCodeFile);
  file = [];
  clear all
end

%fclose(gCodeFile);