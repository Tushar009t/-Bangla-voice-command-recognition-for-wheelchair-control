%% sliding input
clc;
fs = 44100;

delay = 50 ;% in miliseconds
window_time = 2; %displayed data length in seconds
deviceReader = audioDeviceReader(fs,delay/1000*fs);
audio = zeros(1,window_time*fs);
y = 6; %bg


%%
command = 'none';
i = 1;
figure(55);
% set(gca,'visible','off');
memory = zeros(1,ceil(0.75*window_time*1000/delay));      % storing previous outcomes to neglect false detections


tol = 0.3;  % percentage of the memory to be a particular command to be sure


activeCommand = 'background';
while i <=  500
    tic
    audiotemp = deviceReader();
    audio = circshift(audio,-delay/1000*fs);
    audio = [audio(1:window_time*fs - delay/1000*fs) audiotemp'];
    plot(audio);
    title(command);
    axis([0 window_time*fs -1 1]);
    auditorySpect = MyhelperExtractAuditoryFeatures(audio',fs);
    size(auditorySpect);
    auditorySpect_cropped = auditorySpect(:,:);
    temp_command = classify(trainedNet,auditorySpect_cropped);
    %disp(i);
    time = toc;
    pause(delay/1000-time);
    i = i+1;
    %disp(temp_command);
   %sound(audio,fs);
   %extra layer for false detection
   % 4 for shamne, 3 for pichone, 2 dane, 1 bame, 5 thamo 6 bg
   memory = circshift(memory,-1);
   memory(end) = temp_command;
    if length(find(memory == memory(end))) > tol*length(memory)
        command = temp_command;
        if memory(end) ~= 6
            if  ~strcmp(command,activeCommand)
                activeCommand = command;
                y = memory(end);
            end
        end
        
    end
%     disp(command);
    
    disp(y);
    disp(activeCommand);
    
end

%%
release(deviceReader);


