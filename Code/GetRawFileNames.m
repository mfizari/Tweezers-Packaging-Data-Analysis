function [piezofiles, psdfiles] = GetRawFileNames(cfold, datafolder_raw)
% 
% Given a directory that contains the raw .txt files for piezo values and 
% vpsd(vx) values, this function gets the piezo filenames and the vx file
% names that match each other and outputs them as 2 different cells:
% "piezofiles" and "psdfiles"
% It also outputs the cell "filenames", which is just the timestamps string
% 
% Raw text files have the format HH-MM-SS_LABEL_.txt, where LABEL corresponds
% to either piezo or x: piezo angle or psd values


%Load all filenames from dfold_raw (includes piezo,psd, and time txt files)
cd(datafolder_raw); files=dir('*txt'); filenames = {files.name};

%Get all piezo and psd filenames - build iteratively since there could me
%mismatching values
piezofiles = filenames(cellfun(@(x) contains(x, 'piezo'),...
             filenames, 'UniformOutput', true));
psdfiles = filenames(cellfun(@(x) contains(x, '_x_'),...
             filenames, 'UniformOutput', true));

%Pair down files so to only matching ones
% there could be files where x doesn't exist for piezo or via versa
[~, int1, int2] = intersect(cellfun(@(x) x(1:8),piezofiles,...
    'UniformOutput',false), cellfun(@(x) x(1:8),psdfiles,...
    'UniformOutput',false));
piezofiles = piezofiles(int1); psdfiles = psdfiles(int2);
% filenames = cellfun(@(x) x(1:8), piezofiles, 'UniformOutput', false); 

cd(cfold)

end