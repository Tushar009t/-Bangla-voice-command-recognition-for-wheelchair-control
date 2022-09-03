function [adsTrain] = LoadTrainDataset(dataFolder,commands)
%% Choose Words to Recognize
% Specify the words that you want your model to recognize as commands.
% Label all words that are not commands as |unknown|. Labeling words that
% are not commands as |unknown| creates a group of words that approximates
% the distribution of all words other than the commands. The network uses
% this group to learn the difference between commands and all other words.
%
% To reduce the class imbalance between the known and unknown words and
% speed up processing, only include a fraction of the unknown words in the
% training set. 
%
% Use <docid:audio_ref#mw_6823f1d7-3610-4d7d-89d0-816746a24ca9 subset> to
% create a datastore that contains only the commands and the subset of
% unknown words. Count the number of examples belonging to each category.

ads = audioDatastore(fullfile(dataFolder, 'train'), ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames');



isCommand = ismember(ads.Labels,commands);
isUnknown = ~isCommand;

includeFraction = 0.2;
mask = rand(numel(ads.Labels),1) < includeFraction;
isUnknown = isUnknown & mask;
ads.Labels(isUnknown) = categorical("unknown");

adsTrain = subset(ads,isCommand|isUnknown);
countEachLabel(adsTrain)

end

