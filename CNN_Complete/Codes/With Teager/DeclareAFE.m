function [afe, afe_params] = DeclareAFE()



fs = 48000;         %44100; % Known sample rate of the data set.

segmentDuration = 2;
frameDuration = 0.025;
hopDuration = 0.010;

segmentSamples = round(segmentDuration*fs);
frameSamples = round(frameDuration*fs);
hopSamples = round(hopDuration*fs);
overlapSamples = frameSamples - hopSamples;

FFTLength = 2048;
numBands = 50;

afe = audioFeatureExtractor( ...
    'SampleRate',fs, ...
    'FFTLength',FFTLength, ...
    'Window',hann(frameSamples,'periodic'), ...
    'OverlapLength',overlapSamples, ...
    'barkSpectrum',true);

setExtractorParams(afe,'barkSpectrum','NumBands',numBands,'WindowNormalization',false);



afe_params = [segmentSamples,frameSamples,hopSamples,overlapSamples,numBands];
end

