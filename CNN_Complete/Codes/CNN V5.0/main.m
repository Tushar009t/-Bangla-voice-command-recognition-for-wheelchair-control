clc
clear all
close all
%% reduceDataset state declaration
% To train the network with the entire dataset and achieve the highest
% possible accuracy, set |reduceDataset| to |false|. To run this example
% quickly, set |reduceDataset| to |true|.

reduceDataset = false;

%% Load Speech Commands Data Set
dataFolder = fullfile('E:\Current Projects\EEE 312 Project\CNN\Dataset (Raw)\Dataset_male_aug');
commands = categorical(["bame","dane","pichone","shamne","thamo","unknown"]);




%% Loading Datastore
ads = LoadTrainDataset(dataFolder, commands);
%ads = shuffle(ads);

train_split = 0.7;
validation_split = 0.15;
test_split = 0.15;
NumData  = length(ads.Labels);


%% Creating Training, Validation and Test Datastore
[adsTrain,adsValidation,adsTest] = splitEachLabel(ads,train_split,validation_split);


%% Displaying Dataset infos
disp("Label Count for Train Dataset: ");
countEachLabel(adsTrain)

disp("Label Count for Validation Dataset: ");
countEachLabel(adsValidation)

disp("Label Count for Test Dataset: ");
countEachLabel(adsTest)


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

%% To calculate numHops,numFeatures
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

xPadded = [zeros(floor((segmentSamples - size(x,1))/2),1);
           x;
           zeros(ceil((segmentSamples-size(x,1))/2),1)];

features = extract(afe,xPadded);
[numHops,numFeatures] = size(features);



%% Generate XTrain and YTrain by feature extraction
params = [reduceDataset, numHops, numBands, segmentSamples];


XTrain = CreateXTrain(adsTrain, afe, params);
YTrain = removecats(adsTrain.Labels);

[numHops,numBands,numChannels,numSpec] = size(XTrain);


%% Generate XValidation and YValidation by feature extraction
% Perform the feature extraction steps described above to the validation set.
XValidation = CreateXValidation(adsValidation,afe,params);
YValidation = removecats(adsValidation.Labels);
size(XValidation);


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
% If you do not have a GPU, then training the network can take time.
trainedNet = trainNetwork(XTrain,YTrain,layers,options);




%% Evaluate Trained Network
% Calculate the final accuracy of the network on the training set (without
% data augmentation) and validation set. The network is very accurate on
% this data set. However, the training, validation, and test data all have
% similar distributions that do not necessarily reflect real-world
% environments. This limitation particularly applies to the |unknown|
% category, which contains utterances of only a small number of words.

XTest = CreateXValidation(adsTest,afe,params);
YTest = removecats(adsTest.Labels);

size(XTest);

YValPred = classify(trainedNet,XValidation);
validationError = mean(YValPred ~= YValidation);

YTrainPred = classify(trainedNet,XTrain);
trainError = mean(YTrainPred ~= YTrain);

YTestPred = classify(trainedNet,XTest);
testError = mean(YTestPred ~= YTest);


disp("Training error: " + trainError*100 + "%")
disp("Validation error: " + validationError*100 + "%")
disp("Test error: " + testError*100 + "%")



%% Plot the confusion matrix
% Display the precision and recall for each
% class by using column and row summaries. Sort the classes of the
% confusion matrix. The largest confusion is between unknown words and
% commands, _up_ and _off_, _down_ and _no_, and _go_ and _no_.

figure('Units','normalized','Position',[0.2 0.2 0.5 0.5]);
%cm = confusionchart(YValidation,YValPred);

cm = confusionchart(YTest,YTestPred);
cm.Title = 'Confusion Matrix for Test Data';
cm.ColumnSummary = 'column-normalized';
cm.RowSummary = 'row-normalized';
% sortClasses(cm, [commands,"unknown","background"])



%% F score, precision, recall etc calculations
%[cm,order] = confusionmat(YValidation,YValPred);
[cm,order] = confusionmat(YTest,YTestPred);
stats = confusionmatStats(cm);
stats.accuracy


%% ROC plot
[~,score] = classify(trainedNet,XTest);

i = 1;
figure();
for cmd = commands
    [X,Y,T,AUC] = perfcurve(YTest,score(:,i),cmd);
    subplot(3,2,i);
    
    plot(X,Y,'.');
    xlabel('False positive rate');
    ylabel('True positive rate');
    title(sprintf('Command: %s', cmd));
    
    i = i + 1;
end


