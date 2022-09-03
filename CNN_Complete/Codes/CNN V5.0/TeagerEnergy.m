function [ex, ey] = TeagerEnergy(audio)
%% %calculates the energy operator of a signal

%% %input
%Raw signal (Vector)

%% %Output
%Teager operator (ex)

%% %Method
%The Teager Energy Operator is determined as
	%[x[n]] = x^2[n] + x[n - 1]x[n + 1]
%in the discrete case.

audio = audio(:);

%% (x(t)) = (dx/dt)^2+ x(t)(d^2x/dt^2) 
% Energy
y = diff(audio);
y = [0;y];
squ = y(2:length(y)-1).^2;
oddi = y(1:length(y)-2);
eveni = y(3:length(y));
ey = squ - (oddi.*eveni);

ey = ey/max(ey) - mean(ey/max(ey));



%% [x[n]] = x^2[n] - x[n - 1]x[n + 1] 
% Teager
squ1 = audio(2:length(audio)-1).^2;
oddi1 = audio(1:length(audio)-2);
eveni1 = audio(3:length(audio));
ex = squ1 - (oddi1.*eveni1);
ex = [ex(1); ex; ex(length(audio)-2)]; %make it the same length

ex = ex/max(ex) - mean(ex/max(ex));
%% plots

% figure;
% subplot(211);
% plot((sig/max(sig))-mean(sig/max(sig)),'b'),hold on;
% plot((ey/max(ey))-mean(ey/max(ey)),'Linewidth',2,'LineStyle','--','color','r');
% axis tight;
% 
% legend('Original Signal','Energy Operator');


%subplot(212);
% plot((sig/max(sig))-mean(sig/max(sig)),'b'),hold on;
% plot(ex,'Linewidth',2,'LineStyle','--','color','g');
% legend('Original Signal','Teager Energy');
% axis tight,
% 
% zoom on;

