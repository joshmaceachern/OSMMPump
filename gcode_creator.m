%ESTABLISH WORKING FILENAME
%MAKE SURE THE LOCATION EXISTS. IF NOT, GET FROM USER

if exist("loc")
  if isempty(loc)
   loc = inputdlg("What would you like to name your file?");
   end
else
    loc = inputdlg("What would you like to name your file?");
end

%CHECK TO SEE IF THE FILE ALREADY EXISTS
%IF THE FILE EXISTS, QUERY TO SEE IF THIS SHOULD REPLACE OR APPEND TO THE EXISTING FILE
if exist(strcat(char(loc), ".gcode"))
  prompt = strcat("The file", " ", char(loc), ".gcode already exists.");
  replace = questdlg(prompt,'Continue?', "Replace", 'Append', 'Replace');
  if strcmp(replace, "Replace")
    gCodeFile = fopen(strcat(char(loc), ".gcode"), 'w');
    %gCodeFile = []
  elseif strcmp(replace, "Append")
    gCodeFile = fopen(strcat(char(loc), ".gcode"), 'a');
  else
    return
  end
else
  gCodeFile = fopen(strcat(char(loc), ".gcode"), 'a');
end

%GET INPUT VOLUME FROM USER
prompt = {"Motor A", "Motor B", "Motor C", "Motor D", "Motor E"};
defaults = {"0.0", "0.0", "0.0", "0.0", "0.0"};
rowscols = [1,25;1,25;1,25;1,25;1,25];
title = "Enter pump volume in mL";
amounts = inputdlg(prompt,title, rowscols, defaults);
volumeA = char(amounts(1));
volumeB = char(amounts(2));
volumeC = char(amounts(3));
volumeD = char(amounts(4));
volumeE = char(amounts(5));


                
%%GET INPUT FLOW RATE FROM USER
prompt = {'Enter Volumetric Flow Rate in uL/min'};
defaults = {[]};
rowscols = [1, 20];
title = "Flow Rate";
flowRate = inputdlg(prompt, title, rowscols, defaults);;
flowRate = char(flowRate);

%CREATE GCODE LINE
gcode = cstrcat("X", volumeA, ' ', ...
                "Y", volumeB, " ", ...
                "Z", volumeC, " ", ...
                "I", volumeD, " ", ...
                "J", volumeE, " ", ...
                "F", flowRate)
%%OUTPUT IF NO VOLUME SPECIFIED                
if str2num(volumeA) == 0
  fprintf("No output for pump A declared, assuming 0 \n")
  loc1 = strfind(gcode,"X");
  loc2 = strfind(gcode,"Y");
  gcode(loc1:loc2-1) = [];
end

if str2num(volumeB) == 0
  fprintf("No output for pump B declared, assuming 0 \n")
  loc1 = strfind(gcode, "Y");
  loc2 = strfind(gcode, "Z");
  gcode(loc1:loc2-1) = [];
end

if str2num(volumeC) == 0
  fprintf("No output for pump C declared, assuming 0 \n")
  loc1 = strfind(gcode, "Z");
  loc2 = strfind(gcode, "I");
  gcode(loc1:loc2-1) = [];
end

if str2num(volumeD) == 0
  fprintf("No output for pump D declared, assuming 0 \n")
  loc1 = strfind(gcode, "I");
  loc2 = strfind(gcode, "J");
  gcode(loc1:loc2-1) = [];
  end
if str2num(volumeE) == 0
  fprintf("No output for pump E declared, assuming 0 \n")
  loc1 = strfind(gcode, "J");
  loc2 = strfind(gcode, "F");
  gcode(loc1:loc2-1) = [];
end
if isempty(flowRate)
  fprintf("No flow rate declared. Keeping previous/default\n")
  loc1 = strfind(gcode, "F");
  gcode(loc1:end) = [];
end
%WARNING IF GCODE LINE IS EMPTY            
if isempty(gcode)
  cont = questdlg("That line was empty. Are you sure you want to continue?",...
                  "Continue?", "Yes", "No");
     if strcmp(cont,"Yes")
       fprintf(gCodeFile, '%s\n', gcode);
     end
     
else
   fprintf(gCodeFile, '%s\n\r', gcode);
   cont = "Yes";
end
 

%QUERY IF WOULD LIKE TO ADD MORE

  cont = questdlg("Would you like to add more commands?",...
                "Continue?", "Yes", "No");
if strcmp(cont, "Yes")
  gcode_creator
end
 if !strcmp(cont, "Yes");
  loc = [];
end
fclose(gCodeFile);