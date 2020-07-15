%GET INPUTS FROM USER
prompts = {'Enter Hose ID (mm)', 'Enter Hose Bend Radius (mm)',...
 'Enter Steps per revolution of motor', 'Enter number of microsteps (1, 2, 4, 8, 16)', 'Enter Gear Ratio'};
dlgtitle = 'Input';
dims = [1,25;1,25; 1,25;1,25;1,25];
inputs = inputdlg(prompts, dlgtitle, dims);
hoseID = str2num(inputs{1});

%CALCULATE OVERALL VOLUME
%A = pi * d^2 * 0.25
crossSectionalArea = (pi*(hoseID^2))*.25; %%mm^2
%C = pi*d. Input is radius, and we only need 1/2 of a circle, so it simplifies to pi*r
lengthOAL = pi*str2num(inputs{2});
%V = A*L
volume = crossSectionalArea*lengthOAL;

%CALCULATE THE VOLUME PER STEP
stepsRev = str2num(inputs{3})*str2num(inputs{4})*str2num(inputs{5});
volPerStep = volume/stepsRev;
stepsPerVol = stepsRev/volume;

%DISPLAY CALCULATED OUTPUT
message = strcat("Volume per Step:", " ", num2str(volPerStep), "\n",...
                  "Steps per uL:", " ", num2str(stepsPerVol));
msgbox(message);
