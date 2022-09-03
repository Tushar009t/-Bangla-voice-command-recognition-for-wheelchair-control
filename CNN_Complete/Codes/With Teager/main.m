clc
clear all
close all
%% reduceDataset state declaration
% To train the network with the entire dataset and achieve the highest
% possible accuracy, set |reduceDataset| to |false|. To run this example
% quickly, set |reduceDataset| to |true|.


reduceDataset = false;

%% Load Speech Commands Data Set
dataFolder = fullfile('E:\project 312\Dataset_Final_V3.1');
commands = categorical(["bame","dane","pichone","shamne","thamo","unknown"]);




%% Create Training Datastore
adsTrain = LoadTrainDataset(dataFolder, commands);





%% Create Validation Datastore
adsValidation = LoadValidationDataset(dataFolder, commands);





%% reducing the Dataset according to reduceDataset state
if reduceDataset
    numUniqueLabels = numel(unique(adsTrain.Labels));
    % Reduce the dataset by a factor of 20
    adsTrain = splitEachLabel(adsTrain,round(numel(adsTrain.Files) / numUniqueLabels / 20));
    adsValidation = splitEachLabel(adsValidation,round(numel(adsValidation.Files) / numUniqueLabels / 20));
end




%% Compute Auditory Spectrograms
% To prepare the data for efficient training of a convolutional neural
% network, convert the speech waveforms to auditory-based spectrograms.
%
% Define the parameters of the feature extraction. |segmentDuration| is the
% duration of each speech clip (in seconds). |frameDuration| is the
% duration of each frame for spectrum calculation. |hopDuration| is the
% time step between each spectrum. |numBands| is the number of filters
% in the auditory spectrogram.

[afe, afe_params] = DeclareAFE();
segmentSamples = afe_params(1);
frameSamples = afe_params(2);
hopSamples = afe_params(3);
overlapSamples = afe_params(4);
numBands = afe_params(5);

%%
% Read a file from the dataset. Training a convolutional neural network
% requires input to be a consistent size. Some files in the data set are
% less than 1 second long. Apply zero-padding to the front and back of
% the audio signal so that it is of length |segmentSamples|.

% To extract audio features, call |extract|. The output is a Bark spectrum
% with time across rows.
x = read(adsTrain);
numSamples = size(x,1);
numToPadFront = floor( (segmentSamples - numSamples)/2 );
numToPadBack = ceil( (segmentSamples - numSamples)/2 );

%xPadded = [zeros(numToPadFront,1,'like',x);
%           x;
%           zeros(numToPadBack,1,'like',x)];

xPadded = [zeros(floor((segmentSamples - size(x,1))/2),1);
           x;
           zeros(ceil((segmentSamples-size(x,1))/2),1)];

features = extract(afe,xPadded);
[numHops,numFeatures] = size(features)



%% Generate XTrain by feature extraction
params = [reduceDataset, numHops, numBands, segmentSamples];
XTrain = CreateXTrain(adsTrain, afe, params);

[numHops,numBands,numChannels,numSpec] = size(XTrain);






%% Generate XValidation by feature extraction
% Perform the feature extraction steps described above to the validation set.

XValidation = CreateXValidation(adsValidation,afe,params);
size(XValidation);





%% Isolate the train and validation labels. Remove empty categories.

YTrain = removecats(adsTrain.Labels);
YValidation = removecats(adsValidation.Labels);
size(YValidation);




%% Create Xbkg, Background Noise Data
% adsBkg = audioDatastore(fullfile(dataFolder, 'background'));
% 
% Xbkg = CreateXBackground(adsBkg,afe, params);
% [~,~,~,numBkgClips] = size(Xbkg);
% 




%% Split the spectrograms of background noise between the training,validation, and test sets. Because the |_background_noise|_ folder
% contains only about five and a half minutes of background noise, the
% background samples in the different data sets are highly correlated. To
% increase the variation in the background noise, you can create your own
% background files and add them to the folder. To increase the robustness
% of the network to noise, you can also try mixing background noise into
% the speech files.

% split_percent = 0.85;
% 
% numTrainBkg = floor(split_percent*numBkgClips);
% numValidationBkg = floor((1-split_percent)*numBkgClips);
% 
% XTrain(:,:,:,end+1:end+numTrainBkg) = Xbkg(:,:,:,1:numTrainBkg);
% YTrain(end+1:end+numTrainBkg) = "background";
% 
% XValidation(:,:,:,end+1:end+numValidationBkg) = Xbkg(:,:,:,numTrainBkg+1:end);
% YValidation(end+1:end+numValidationBkg) = "background";





%% Plot the distribution of the different class labels in the training and 
% validation sets.
figure('Units','normalized','Position',[0.2 0.2 0.5 0.5])

subplot(2,1,1)
histogram(YTrain)
title("Training Label Distribution")

subplot(2,1,2)
histogram(YValidation)
title("Validation Label Distribution")




%% Create CNN layers and options
[layers,options] = CreateMyCNN(XValidation,YValidation,YTrain,params);




%% Train the network.
% If you do not have a GPU, then training the network
% can take time.
trainedNet = trainNetwork(XTrain,YTrain,layers,options);





%% Evaluate Trained Network
% Calculate the final accuracy of the network on the training set (without
% data augmentation) and validation set. The network is very accurate on
% this data set. However, the training, validation, and test data all have
% similar distributions that do not necessarily reflect real-world
% environments. This limitation particularly applies to the |unknown|
% category, which contains utterances of only a small number of words.
YValPred = classify(trainedNet,XValidation);
validationError = mean(YValPred ~= YValidation);
YTrainPred = classify(trainedNet,XTrain);
trainError = mean(YTrainPred ~= YTrain);
disp("Training error: " + trainError*100 + "%")
disp("Validation error: " + validationError*100 + "%")



%%
% Plot the confusion matrix. Display the precision and recall for each
% class by using column and row summaries. Sort the classes of the
% confusion matrix. The largest confusion is between unknown words and
% commands, _up_ and _off_, _down_ and _no_, and _go_ and _no_.

figure('Units','normalized','Position',[0.2 0.2 0.5 0.5]);
cm = confusionchart(YValidation,YValPred);
cm.Title = 'Confusion Matrix for Validation Data';
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
% sortClasses(cm, [commands,"unknown","background"])

%% F score, precision, recall etc calculations
[cm,order] = confusionmat(YValidation,YValPred);
stats = confusionmatStats(cm);


%% ROC plot
[~,score] = classify(trainedNet,XValidation);

i = 1;
figure();
for cmd = commands
    [X,Y,T,AUC] = perfcurve(YValidation,score(:,i),cmd);
    subplot(3,2,i);
    
    plot(X,Y,'.');
    xlabel('False positive rate');
    ylabel('True positive rate');
    title(sprintf('Command: %s', cmd));
    
    i = i + 1;
end





