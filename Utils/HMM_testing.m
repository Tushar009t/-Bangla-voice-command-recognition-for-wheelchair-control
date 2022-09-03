%%
trans = [0.95,0.05;
         0.10,0.90];
emis = [0.2, 0.2, 0.2, 0.2, 0.1, 0.1;
        1/10, 1/10, 1/10, 1/10, 1/10, 1/2];


transGuess = randPmat(2,2);
emisGuess = randPmat(2,6);

seq1 = hmmgenerate((2,100),trans,emis);
seq2 = hmmgenerate((2,100),trans,emis);
seqs = {seq1,seq2};
[estTR,estE] = hmmtrain(seqs,transGuess,emisGuess,'Maxiterations',300)




%%
[seq,states] = hmmgenerate(5000,trans,emis);
estimatedStates = hmmviterbi(seq,trans,emis);

estimatedStates_D = hmmviterbi(seq,transGuess,emisGuess);

subplot(511); plot(states)
subplot(512); plot(estimatedStates)
subplot(513); plot(states-estimatedStates)
subplot(514); plot(estimatedStates_D)
subplot(515); plot(states-estimatedStates_D)


function mat  = randPmat(N,M)
mat = zeros(N,M);
for i = 1:N
    mat(i,:) = diff(sort([0, rand(1,M-1), 1]));       
end
end