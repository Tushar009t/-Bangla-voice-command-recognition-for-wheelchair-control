%Real time Input
clc

fs = 44100;
nBits = 8;
NumChannels = 1;
device_ID = 2;

recObj = audiorecorder(fs,nBits,NumChannels,device_ID);
disp('Start speaking.')

recordblocking(recObj,2);
disp('End of Recording.');

x_real = getaudiodata(recObj);
%sound(x_real,fs)
[x_real, ~] = TeagerEnergy(x_real);
auditorySpect = MyhelperExtractAuditoryFeatures(x_real,fs);
command = classify(trainedNet,auditorySpect)