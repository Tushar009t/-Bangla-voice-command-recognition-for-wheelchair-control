clc
clear all
close all
load handel.mat

%% loading Data
cell_bame = dataloader_bame();
length_bame = size(cell_bame);
length_bame = length_bame(1);

cell_dane = dataloader_dane();
length_dane = size(cell_dane);
length_dane = length_dane(1);

cell_pichone = dataloader_pichone();
length_pichone = size(cell_pichone);
length_pichone = length_pichone(1);

cell_shamne = dataloader_shamne();
length_shamne = size(cell_shamne);
length_shamne = length_shamne(1);

cell_thamo = dataloader_thamo();
length_thamo = size(cell_thamo);
length_thamo = length_thamo(1);



%% cropping all audio file in same dimention

%% bame
for i = 2:length_bame
    cell_sized_bame{i,1} = audio_length_crop(cell_bame{i,1}, cell_bame{i,2}, 2);  
    cell_sized_bame{i,2} = cell_bame{i,2};
    audiowrite(sprintf('bame%d.wav', i-1), cell_sized_bame{i,1}, cell_sized_bame{i,2});
end

%% dane 
for i = 2:length_dane
    cell_sized_dane{i,1} = audio_length_crop(cell_dane{i,1}, cell_dane{i,2}, 2);  
    cell_sized_dane{i,2} = cell_dane{i,2};
    audiowrite(sprintf('dane%d.wav', i-1), cell_sized_dane{i,1}, cell_sized_dane{i,2});
end

%% pichone
for i = 2:length_pichone
    cell_sized_pichone{i,1} = audio_length_crop(cell_pichone{i,1}, cell_pichone{i,2}, 2);  
    cell_sized_pichone{i,2} = cell_pichone{i,2};
    audiowrite(sprintf('pichone%d.wav', i-1), cell_sized_pichone{i,1}, cell_sized_pichone{i,2});
end

%% shamne
for i = 2:length_shamne
    cell_sized_shamne{i,1} = audio_length_crop(cell_shamne{i,1}, cell_shamne{i,2}, 2);  
    cell_sized_shamne{i,2} = cell_shamne{i,2};
    audiowrite(sprintf('shamne%d.wav', i-1), cell_sized_shamne{i,1}, cell_sized_shamne{i,2});
end

%% thamo 
for i = 2:length_thamo
    cell_sized_thamo{i,1} = audio_length_crop(cell_thamo{i,1}, cell_thamo{i,2}, 2);  
    cell_sized_thamo{i,2} = cell_thamo{i,2};
    audiowrite(sprintf('thamo%d.wav', i-1), cell_sized_thamo{i,1}, cell_sized_thamo{i,2});
end

