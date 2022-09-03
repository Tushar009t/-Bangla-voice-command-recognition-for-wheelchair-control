%% wav_file_input
[x,fs] = audioread('pichone1.wav');
%size(x);


auditorySpect = MyhelperExtractAuditoryFeatures(x(:,1),fs);
%size(auditorySpect)
command = classify(trainedNet,auditorySpect)


%% Real time Input

fs = 44100;
nBits = 8;
NumChannels = 1;
device_ID = 1;

recObj = audiorecorder(fs,nBits,NumChannels,device_ID);
disp('Start speaking.')

recordblocking(recObj,2);
disp('End of Recording.');

x_real = getaudiodata(recObj);
sound(x_real,fs)

auditorySpect = MyhelperExtractAuditoryFeatures(x_real,fs);
command = classify(trainedNet,auditorySpect)