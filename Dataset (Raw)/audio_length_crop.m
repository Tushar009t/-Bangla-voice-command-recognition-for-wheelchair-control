function x_cropped = audio_length_crop(x_, Fs, time_period)

x = x_(:,1);                             % if input is multi channel, taking only first channel
t = 0: (1/Fs): (length(x)-1)*(1/Fs);     % creating time domain

% wanna see avgerage of each 2000 samples
average = zeros(1, round(length(x)/2000));  
j = 1;

time_period = time_period*44100/Fs;       % keeping number of samples equal

for i = 1:2000:length(x)-2000
   average(j) = mean(abs(x(i:i+2000)));
   j = j+1;
end

[~,I] = max(average);                % index of maximum point 

start_point = I*2000 - 0.6*Fs;       % going to 0.6 sec left of peak

if start_point < 1
    start_point = 1;                 % if peak was before 0.6 sec
end

% now we will crop audio
x_cropped = zeros(1,time_period*Fs);                 % cropped audio will be saved here   
t_cropped = 0: (1/Fs): (length(x_cropped)-1)*(1/Fs); % time domain of cropped audio

sample_remaining = length(x) - start_point;

if sample_remaining >=  length(x_cropped)
    x_cropped = x(start_point: start_point + length(x_cropped)-1);
else
    x1 = x(start_point: end);
    x_cropped(1:length(x1)) = x1;
end

size_temp = size(x_cropped);

    if size_temp(1)>1
        x_cropped_ = transpose(x_cropped);
        x_cropped = x_cropped_;
    end

end
