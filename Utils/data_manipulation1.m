clc;
clear all;
close all;
p = dir('*.wav');
N = numel(p);
cell = {'Filename','speakerID','data','Fs'};
for i = 1:N
    name_temp = p(i).name;
    [y_temp  Fs_temp] = audioread(name_temp);
    spid_temp = name_temp(end-4:end-3);
    cell(i+1,:) = {p(i).name, spid_temp, y_temp, Fs_temp};
end
for i = 2:71
    pronounce(cell,i);
end
%%
[y, Fs] = audioread(p(55).name);
[y2, Fs2] = audioread(p(64).name);
