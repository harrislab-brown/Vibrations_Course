% VibeCheck_plot.m
% This script loads vibration data from CSV files, processes timestamps,
% separates data by channel, and plots X, Y, Z acceleration vs time.

% Clear workspace
clear; clc; close all;

%% 1. Set data folder and load CSV files
dataFolder = 'example_data/';  % folder with CSV files
files = dir(fullfile(dataFolder, '*.csv'));

% Store data in a structure
dataStruct = struct();
for k = 1:length(files)
    filePath = fullfile(files(k).folder, files(k).name);
    [~, name, ~] = fileparts(filePath);
    
    % Replace invalid characters for struct field names
    safeName = matlab.lang.makeValidName(name);
    
    % Load into structure with safe name
    dataStruct.(safeName) = readtable(filePath); 
end

disp('DataTables loaded:');
disp(fieldnames(dataStruct));

%% 2. Select one dataset (edit filename as needed)
% Example: pick the first file loaded
fileNames = fieldnames(dataStruct);
df = dataStruct.(fileNames{1});

%% 3. Process timestamps
% Convert timestamp to seconds relative to first timestamp
global_min_timestamp = min(df.Timestamp);
df.Time_seconds = (df.Timestamp - global_min_timestamp) / 1e6;

%% 4. Group by channel
channels = unique(df.Channel);
channelData = struct();

for i = 1:length(channels)
    ch = channels(i);
    % Extract rows for this channel
    channelData.(sprintf('Channel%d', ch)) = df(df.Channel == ch, :);
end

disp('Channels found:');
disp(channels');

%% 5. Plot acceleration vs time for all channels
figure; hold on; grid on;

colors = lines(3); % distinct colors for X, Y, Z

for i = 1:length(channels)
    chName = sprintf('Channel%d', channels(i));
    plt_df = sortrows(channelData.(chName), 'Time_seconds');
    
    % Plot X, Y, Z
    plot(plt_df.Time_seconds, plt_df.X, '-o', ...
        'DisplayName', sprintf('Channel %d - X', channels(i)), ...
        'Color', colors(1,:));
    plot(plt_df.Time_seconds, plt_df.Y, '-o', ...
        'DisplayName', sprintf('Channel %d - Y', channels(i)), ...
        'Color', colors(2,:));
    plot(plt_df.Time_seconds, plt_df.Z, '-o', ...
        'DisplayName', sprintf('Channel %d - Z', channels(i)), ...
        'Color', colors(3,:));
end

xlabel('Time (s)');
ylabel('Acceleration (g)');
title('Acceleration vs Time');
legend show;
