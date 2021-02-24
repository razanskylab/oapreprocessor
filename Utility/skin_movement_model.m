


surfRaw = P.surfMeasured;
[nX, nY] = size(surfRaw);


% bring into time domain format to vizualize 
surfTime = surfRaw;
surfTime(:, 2:2:end) = flip(surfTime(:, 2:2:end), 1);
surfTime = surfTime(:);

deltaSurf = surfRaw(nX * 2+ 1:end) - surfRaw(1: end-nX * 2);

figure();
subplot(2, 2, 1)
plot(surfRaw(:, 1:100:end))
ylabel('x')

subplot(2, 2, 2)
plot(surfRaw(1:100:end, :)')
xlabel('y');

subplot(2, 2, 3)

yyaxis left
plot(surfTime - mean(surfTime))
yyaxis right
plot(nX*2+1:(nX * nY), deltaSurf)


subplot(2, 2, 4)
plot(abs(fft(deltaSurf)))