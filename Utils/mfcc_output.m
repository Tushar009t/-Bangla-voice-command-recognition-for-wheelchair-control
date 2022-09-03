
time_period=2;
file_name='Dataset/shamne/shamne_01 _07.wav';

ADS = audioDatastore('Dataset/shamne',...
    'FileExtensions','.wav');

N = length(ADS.Files);
C = 3;

CFs = zeros(N,C+1);
for i = 1:N
    file_name = ADS.Files{i};
    % output of audio_length_crop function
    [x_cropped, Fs, t_sized] = audio_length_crop(file_name, time_period);
    %sound(x_cropped,Fs);


    win = hann(1024,'periodic');
    S   = stft(x_cropped,'Window',win,'OverlapLength',...
        512,'Centered',false);
    [coeffs,delta,deltaDelta] = mfcc(S,Fs, 'NumCoeffs', C);


    coeffs = normalize(coeffs);
    
    CFs(i,:) = coeffs(55,:);
end

%Fitting to GMM model
GMModel = fitgmdist(CFs,2);

%% PCA for 2D visualization
[~, scores] = pca(CFs,'NumComponents',2);

figure();
plot(scores(:,1),scores(:,2),'.');
%%

mu1 = [1 2];
Sigma1 = [2 0; 0 0.5];
mu2 = [-3 -5];
Sigma2 = [1 0;0 1];
rng(1); % For reproducibility
X = [mvnrnd(mu1,Sigma1,100); mvnrnd(mu2,Sigma2,100)];















