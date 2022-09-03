function [adsValidation] = LoadValidationDataset(dataFolder,commands)
% Create an <docid:audio_ref#mw_6315b106-9a7b-4a11-a7c6-322c073e343a
% audioDatastore> that points to the validation data set. Follow the same
% steps used to create the training datastore.
ads = audioDatastore(fullfile(dataFolder, 'validation'), ...
    'IncludeSubfolders',true, ...
    'FileExtensions','.wav', ...
    'LabelSource','foldernames');

isCommand = ismember(ads.Labels,commands);
isUnknown = ~isCommand;

includeFraction = 0.2;
mask = rand(numel(ads.Labels),1) < includeFraction;
isUnknown = isUnknown & mask;
ads.Labels(isUnknown) = categorical("unknown");

adsValidation = subset(ads,isCommand|isUnknown);
countEachLabel(adsValidation)
end

