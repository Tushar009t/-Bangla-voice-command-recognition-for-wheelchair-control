%% Loading the data
%Set the current matlab directory to 'Dataset' folder


%name of all the folder
dataFolders = {'bame','dane','pichone','shamne','thamo'};


%Loading all the original data file location in workspace
for i=1:length(dataFolders)
    ADS{i} = audioDatastore(sprintf('Dataset_female/train/%s',dataFolders{i}),...
    'FileExtensions','.wav','IncludeSubfolders',true,....
     'LabelSource', 'foldernames');
end
 

TimeLength = 2; %in sec
 
 %% Batch Augmentation
aug = audioDataAugmenter('AugmentationParameterSource' , 'random',...
    "AugmentationMode","sequential", ...
    "NumAugmentations",3, ...
    ...
    "TimeStretchProbability",1.0, ...
    "SpeedupFactorRange", [0.7,1.2], ...
    ...
    "PitchShiftProbability",1.0, ...
    "SemitoneShiftRange", [-1 1],...
    ...
    "VolumeControlProbability",1.0, ...
    "VolumeGainRange",[1.5,3.5], ...
    ...
    "AddNoiseProbability",0.05, ...
    "SNRRange", [0 0.01], ...
    ...
    "TimeShiftProbability",1.0, ...
    "TimeShiftRange", [-0.20,0.20]); %In sec
 
 
 %Augmentation for each command
 for i=1:length(dataFolders)
     
     %Creating folder for augmented data
     dataFolder = strcat(dataFolders{i},'');
     if ~exist(dataFolder,'dir')
        mkdir(sprintf('../Dataset_aug/%s',dataFolder));
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
            augmentedAudio = audio_length_crop(...
                augmentedAudio,info.SampleRate, TimeLength); 
            audiowrite(sprintf('../Dataset_aug/%s/%s_aug%d.wav',...
                dataFolders{i},fn,j),...
                augmentedAudio, info.SampleRate)
        end
     end
 end


