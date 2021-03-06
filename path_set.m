clear all; close all; clc;
% Set paths needed by project

% Get current folder dir
projectRootDir = fileparts(mfilename('fullpath'));

% Specify necessary folders
includePaths = { ...
    projectRootDir; ...
    fullfile(projectRootDir, '01_auxilary'); ...
    fullfile(projectRootDir, '01_auxilary/quaternion_library'); ...
    genpath(fullfile(projectRootDir, '02_models')); ...
    genpath(fullfile(projectRootDir, '03_simulation')); ...
    genpath(fullfile(projectRootDir, '04_identification')); ...
    genpath(fullfile(projectRootDir, '05_data')); ...
    fullfile(projectRootDir, '10_work'); ...
}; 

% Add specified folders to Matlab path
for ii = 1:size(includePaths,1)
    addpath(includePaths{ii});
end

% Add user specific paths to toolboxes
if exist('path_usr', 'file')
    run('path_usr');
    pathCell  = regexp(path, pathsep, 'split');
    for ii = size(usrPaths,1):-1:1
        onPath = any(strcmpi(usrPaths{ii}, pathCell));
        if ~onPath
            addpath(usrPaths{ii});
        else
            usrPaths(ii) = [];
        end
    end 
end

% Set work directory for compiled and temporary data
workFolder = includePaths{end}; 
Simulink.fileGenControl('set', 'CacheFolder', workFolder, 'CodeGenFolder', workFolder);
save(fullfile(workFolder, 'includePaths.mat'), 'includePaths');
save(fullfile(workFolder, 'usrPaths.mat'), 'usrPaths');
clear projectRootDir workFolder ii includePaths pathCell onPath usrPaths



%% Busdefinitions
load('00_config/bus_init.mat');