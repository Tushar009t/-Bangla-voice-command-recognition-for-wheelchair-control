%% Loading the data
%Set the current matlab directory to 'Dataset' folder

%name of all the folder
dataFolders = {'bame','dane','pichone','shamne','thamo'};

dataPath = fullfile('E:\','Matlab Projects','GMM Test','Train');


%Loading all the original data file location in workspace
for i=1:length(dataFolders)
    ADS{i} = audioDatastore(fullfile(dataPath,dataFolders{i}),...
    'FileExtensions','.wav','IncludeSubfolders',true,....
     'LabelSource', 'foldernames');
end
 
 
 %% Batch Augmentation
aug = audioDataAugmenter('AugmentationParameterSource' , 'random',...
    "AugmentationMode","sequential", ...
    "NumAugmentations",3, ...
    ...
    "TimeStretchProbability",0.7, ...
    "SpeedupFactorRange", [0.8,1.2], ...
    ...
    "PitchShiftProbability",0.7, ...
    "SemitoneShiftRange", [-2 2],...
    ...
    "VolumeControlProbability",0.7, ...
    "VolumeGainRange",[-1,3], ...
    ...
    "AddNoiseProbability",0.05, ...
    "SNRRange", [0 0.05], ...
    ...
    "TimeShiftProbability",0.95, ...
    "TimeShiftRange", [-0.5,0.5]); %In sec
 
 %Augmentation for each command
 for i=1:length(dataFolders)
     
     %Creating folder for augmented data
     AugdataFolder = strcat(dataFolders{i},'_aug');
     if ~exist(AugdataFolder,'dir')
        mkdir(fullfile(dataPath,AugdataFolder));
     end
     
     ads = ADS{i};
     while hasdata(ads)
        [audioIn,info] = read(ads);

        data = augment(aug,audioIn,info.SampleRate);

        [~,fn] = fileparts(info.FileName);
        for j = 1:size(data,1)
            augmentedAudio = data.Audio{j};

            % If augmentation caused an audio signal to have values outside of -1 and 1, 
            % normalize the audio signal to avoid clipping when writing.
            if max(abs(augmentedAudio),[],'all')>1
                augmentedAudio = augmentedAudio/max(abs(augmentedAudio),[],'all');
            end
            AugFileName = strcat(fn,'_aug_',string(j),'.wav');
            audiowrite(fullfile(dataPath,AugdataFolder,AugFileName),...
                augmentedAudio, info.SampleRate)
        end
     end
 end
