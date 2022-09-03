
Fs = 44100; %Hz
i = 2; %i'th data

X = load('labeledAudioSet.mat');
XROI = X.labelData.Labels(i,:);
XSource = X.labelData.Source(i);

FileName = XSource{1};
ROI = Xtable{1,1}{1}{1,1}; %In sec;


x = audioread(FileName);