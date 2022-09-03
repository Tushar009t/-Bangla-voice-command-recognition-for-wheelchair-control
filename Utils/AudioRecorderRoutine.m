
% For each sample, recording will be for 2 sec.
% Press Enter after each recording.
T = 2;

Fs = 44100;
bits = 16;
channel = 1;

start_index = 1;   %save the .wav files starting from index 1
N = 20;             %Will record for N samples;


% Change the command you want to record, and your roll no
command = 'pichone';
%rollNo = 01;
recObj = audiorecorder(Fs,bits,channel,1);

for i = start_index:start_index+N-1
    disp('Start speaking...')
    recordblocking(recObj, T);
    disp('End of Recording.');
    play(recObj);

    y = getaudiodata(recObj);

    audiowrite(sprintf('%s_%d.wav',command, i),y, Fs)
                        %Just change the file name here according
                        %to your choice
   x = input("\n Continue?");
end


