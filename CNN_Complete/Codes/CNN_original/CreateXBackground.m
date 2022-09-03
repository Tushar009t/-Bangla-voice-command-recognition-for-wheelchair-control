function [Xbkg] = CreateXBackground(adsBkg,afe, params)

reduceDataset = params(1);
numHops = params(2); 
numBands = params(3);
segmentSamples = params(4);

% The network must be able not only to recognize different spoken words but
% also to detect if the input contains silence or background noise.
%
% Use the audio files in the |_background|_ folder to create samples
% of one-second clips of background noise. Create an equal number of
% background clips from each background noise file. You can also create
% your own recordings of background noise and add them to the
% |_background|_ folder. Before calculating the spectrograms, the
% function rescales each audio clip with a factor sampled from a
% log-uniform distribution in the range given by |volumeRange|.

numBkgClips = 4000;
if reduceDataset
    numBkgClips = numBkgClips/20;
end

volumeRange = log10([1e-4,1]);
fs = afe.SampleRate;

numBkgFiles = numel(adsBkg.Files);
numClipsPerFile = histcounts(1:numBkgClips,linspace(1,numBkgClips,numBkgFiles+1));
Xbkg = zeros(numHops,numBands,1,numBkgClips,'single');


bkgAll = readall(adsBkg);
ind = 1;

for count = 1:numBkgFiles
    bkg = bkgAll{count};
    idxStart = randi(numel(bkg)-fs,numClipsPerFile(count),1);
    idxEnd = idxStart+fs-1;
    gain = 10.^((volumeRange(2)-volumeRange(1))*rand(numClipsPerFile(count),1) + volumeRange(1));
    for j = 1:numClipsPerFile(count)
        
        x = bkg(idxStart(j):idxEnd(j))*gain(j);
        
        x = max(min(x,1),-1);
        
        p = extract(afe,x);
        length_p = size(p);
        
        Xbkg(1:length_p(1),:,:,ind) = p;
        
        if mod(ind,1000)==0
            disp("Processed " + string(ind) + " background clips out of " + string(numBkgClips))
        end
        ind = ind + 1;
    end
end

epsil = 1e-6;
Xbkg = log10(Xbkg + epsil);

end

