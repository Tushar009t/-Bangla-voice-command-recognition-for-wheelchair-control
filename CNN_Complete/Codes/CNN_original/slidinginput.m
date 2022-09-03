%% sliding input
delay = 20 ;% in miliseconds
window_time = 2; %displayed data length in seconds
deviceReader = audioDeviceReader(fs,delay/1000*fs);
audio = ones(1,window_time*fs);

command = 'none';
i = 1;
figure;
while i <=  1000
    tic
    audiotemp = deviceReader();
    audio = circshift(audio,-delay/1000*fs);
    audio = [audio(1:window_time*fs - delay/1000*fs) audiotemp'];
    plot(audio);
    title(command);
    axis([0 window_time*fs -1 1]);
    auditorySpect = helperExtractAuditoryFeatures(audio',fs);
    size(auditorySpect);
    auditorySpect_cropped = auditorySpect(:,:);
    command = classify(trainedNet,auditorySpect_cropped);
    disp(i);
    time = toc;
    pause(delay/1000-time);
    i = i+1;
    disp(command);
   %sound(audio,fs);
end

%%
release(deviceReader);