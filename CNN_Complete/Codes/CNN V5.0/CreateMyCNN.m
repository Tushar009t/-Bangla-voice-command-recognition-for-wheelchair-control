function [layers,options] = CreateMyCNN(XValidation,YValidation,YTrain,params)

reduceDataset = params(1);
numHops = params(2); 
numBands = params(3);
segmentSamples = params(4);

%% Define Neural Network Architecture
% Create a simple network architecture as an array of layers. Use
% convolutional and batch normalization layers, and downsample the feature
% maps "spatially" (that is, in time and frequency) using max pooling
% layers. Add a final max pooling layer that pools the input feature map
% globally over time. This enforces (approximate) time-translation
% invariance in the input spectrograms, allowing the network to perform the
% same classification independent of the exact position of the speech in
% time. Global pooling also significantly reduces the number of parameters
% in the final fully connected layer. To reduce the possibility of the
% network memorizing specific features of the training data, add a small
% amount of dropout to the input to the last fully connected layer.
%
% The network is small, as it has only five convolutional layers with few
% filters. |numF| controls the number of filters in the convolutional
% layers. To increase the accuracy of the network, try increasing the
% network depth by adding identical blocks of convolutional, batch
% normalization, and ReLU layers. You can also try increasing the number of
% convolutional filters by increasing |numF|.
%
% Use a weighted cross entropy classification loss.
% <matlab:edit(fullfile(matlabroot,'examples','deeplearning_shared','main','weightedClassificationLayer.m'))
% |weightedClassificationLayer(classWeights)|> creates a custom
% classification layer that calculates the cross entropy loss with
% observations weighted by |classWeights|. Specify the class weights in the
% same order as the classes appear in |categories(YTrain)|. To give each
% class equal total weight in the loss, use class weights that are
% inversely proportional to the number of training examples in each class.
% When using the Adam optimizer to train the network, the training
% algorithm is independent of the overall normalization of the class
% weights.

classWeights = 1./countcats(YTrain);
classWeights = classWeights'/mean(classWeights);
numClasses = numel(categories(YTrain));

timePoolSize = ceil(numHops/8);

dropoutProb = 0.2;
numF = 12;
layers = [
    imageInputLayer([numHops numBands])
    
    convolution2dLayer(3,numF,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(3,'Stride',2,'Padding','same')
    
    
    convolution2dLayer(3,2*numF,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(3,'Stride',2,'Padding','same')
    
    
    convolution2dLayer(3,4*numF,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(3,'Stride',2,'Padding','same')
    
    
    convolution2dLayer(3,4*numF,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    convolution2dLayer(3,4*numF,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    
    maxPooling2dLayer([timePoolSize,1])
    dropoutLayer(dropoutProb)
    
    
    fullyConnectedLayer(numClasses)
    softmaxLayer
    
    weightedClassificationLayer(classWeights)];

%% Train Network
% Specify the training options. Use the Adam optimizer with a mini-batch
% size of 128. Train for 25 epochs and reduce the learning rate by a factor
% of 10 after 20 epochs.

miniBatchSize = 128;
validationFrequency = floor(numel(YTrain)/miniBatchSize);
options = trainingOptions('adam', ...
    'InitialLearnRate',3e-4, ...
    'MaxEpochs',25, ...
    'MiniBatchSize',miniBatchSize, ...
    'Shuffle','every-epoch', ...
    'Plots','training-progress', ...
    'Verbose',false, ...
    'ValidationData',{XValidation,YValidation}, ...
    'ValidationFrequency',validationFrequency, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',20);

end

