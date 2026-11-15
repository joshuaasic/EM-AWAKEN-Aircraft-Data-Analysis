%% Joshua Sic
clear; 
clc;
close all;
warning('off','all')

%% Importing CSVs
KPPath = "C:\Users\joshu\Documents\MATLAB\Energy Meteorology\Input\King Plains";
KPList = dir(fullfile(KPPath, "*.csv"));
KPTurbines = readtable("Turbine_locations\KPTurbines.csv");

AFPath = "C:\Users\joshu\Documents\MATLAB\Energy Meteorology\Input\Armadillo Flats";
AFList = dir(fullfile(AFPath, "*.csv"));
AFTurbines = readtable("Turbine_locations\AFTurbines.csv");

% Define Output Folder
outputFolder = 'Output';

% Defining Legs
KPLegMin = min(KPTurbines.turbine_longitude) - (0.25/60);
KPLegMax = max(KPTurbines.turbine_longitude) + (0.25/60);

AFLegMin = min(AFTurbines.turbine_latitude) - (0.25/60);
AFLegMax = max(AFTurbines.turbine_latitude) + (0.25/60);

%% Function Call
plotData(1,KPPath,KPList,KPTurbines,KPLegMin,KPLegMax,outputFolder);
plotData(2,AFPath,AFList,AFTurbines,AFLegMin,AFLegMax,outputFolder);

fprintf("All Files Saved\n");
warning('on','all')

%% Function Def
function plotData(farmNum,folderPath,fileList,turbineLocations,legMin,legMax,outputFolder)
    for i = 1:length(fileList)
        % Read CSV file into Table
        fullFilePath = fullfile(folderPath, fileList(i).name);
        fileName = fileList(i).name;
        aircraft_Data = readtable(fullFilePath);

        % Figure Name
        figName = eraseBetween(fileName, strlength(fileName)-3, strlength(fileName));

        % Calculating Wind Magnitude
        aircraft_Data.WindSpeedMag = sqrt(aircraft_Data{:,"V_m_s__northComponent_"}.^2 + aircraft_Data{:,"U_m_s__eastComponent_"}.^2 + aircraft_Data{:,"W_m_s__downComponent_"}.^2);

        % Separating Legs
        if farmNum == 1
            % Leg Lines For Plot
            longMinRange = [legMin,legMin];
            longMaxRange = [legMax,legMax];
            latRange = [min(aircraft_Data.Latitude),max(aircraft_Data.Latitude)];
            % Leg Data Separation
            Lat = aircraft_Data.Latitude(aircraft_Data.Longitude > legMin & aircraft_Data.Longitude < legMax, :);
            Long = aircraft_Data.Longitude(aircraft_Data.Longitude > legMin & aircraft_Data.Longitude < legMax, :);
            WindSpeed = aircraft_Data.WindSpeedMag(aircraft_Data.Longitude > legMin & aircraft_Data.Longitude < legMax, :);
            LegData = table(Lat,Long,WindSpeed);
        elseif farmNum == 2
            % Leg Lines For Plot
            latMinRange = [legMin,legMin];
            latMaxRange = [legMax,legMax];
            longRange = [min(aircraft_Data.Longitude),max(aircraft_Data.Longitude)];
            % Leg Data Separation
            Lat = aircraft_Data.Latitude(aircraft_Data.Latitude > legMin & aircraft_Data.Latitude < legMax, :);
            Long = aircraft_Data.Longitude(aircraft_Data.Latitude > legMin & aircraft_Data.Latitude < legMax, :);
            WindSpeed = aircraft_Data.WindSpeedMag(aircraft_Data.Latitude > legMin & aircraft_Data.Latitude < legMax, :);
            LegData = table(Lat,Long,WindSpeed);
        end

        % Plotting
        fig = figure('Name',figName,'Visible','off');
        % Plotting Aircraft Path & Wind Speed
        subplot(2,1,1)
        geoscatter(aircraft_Data,"Latitude","Longitude",ColorVariable="WindSpeedMag");
        hold on
        % Plotting Turbines
        scatter(turbineLocations,"turbine_latitude","turbine_longitude",Marker="x",LineWidth=1.5,MarkerEdgeColor="k");
        % Plotting Leg Separation Lines
        if farmNum == 1
            geoplot(latRange,longMinRange,Color="R");
            geoplot(latRange,longMaxRange,Color="R");
        elseif farmNum == 2
            geoplot(latMinRange,longRange,Color="R");
            geoplot(latMaxRange,longRange,Color="R");
        end
        cb = colorbar;
        cb.Label.String = "Windspeed (m/s)";
        title("Aircraft Path");
        legend("","Turbines")
        hold off

        subplot(2,1,2)
        geoscatter(LegData,"Lat","Long",ColorVariable="WindSpeed");
        hold on
        % Plotting Turbines
        scatter(turbineLocations,"turbine_latitude","turbine_longitude",Marker="x",LineWidth=1.5,MarkerEdgeColor="k");
        cb = colorbar;
        cb.Label.String = "Windspeed (m/s)";
        title("Aircraft Leg Data");
        legend("","Turbines")
        hold off

        outputFilePath = fullfile(outputFolder, [figName '.png']);
        exportgraphics(fig, outputFilePath, 'Resolution', 300);
        close;
        
        % Keeping Track of Plots
        fprintf("Done With Plot " + i + "/" + length(fileList) + "\n");
        
    end
end