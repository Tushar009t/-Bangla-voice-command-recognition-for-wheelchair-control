

%y = audioread(ADS.Files{4});

subplot(211);
[x_cropped, Fs, t_sized] = audio_length_crop(ADS.Files{4}, 2, 0.03);
title('Cropped');

subplot(212);
plot(audioread(ADS.Files{4}));
title('Orifinal');