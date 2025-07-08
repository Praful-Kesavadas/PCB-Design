
Fs = 44100;  % Sampling rate

% Load signals
w_raw              = load('external_noise.txt');         
noisy_speech       = load('noisy_speech.txt');  
clean_speech_ref   = load('clean_speech.txt');  

% initial SNR calculation
snr_before = 10*log10( mean(clean_speech_ref.^2) /mean((noisy_speech - clean_speech_ref).^2) );
fprintf('SNR before cancellation: %.2f dB\n', snr_before);

mode = lower(input('Mode (''full'' or ''partial''): ','s'));

if strcmp(mode,'partial')
    freqs = input('Frequencies TO PRESERVE (Hz), e.g. [500 1500]: ');
    nSec  = numel(freqs);
    b_sec = cell(nSec,1);
    a_sec = cell(nSec,1);
    for i = 1:nSec
        f0   = freqs(i);
        w0   = 2*pi*f0/Fs;
        r    = 0.999;
        b_sec{i} = [1, -2*cos(w0),    1];
        a_sec{i} = [1, -2*r*cos(w0), r^2];
    end
else 
    % incase of full suppression
    b_sec = {1};
    a_sec = {1};
end

% Pass the cell arrays into your NLMS:
cleaned = rls_algorithm(noisy_speech, w_raw, b_sec, a_sec);
sound(cleaned, Fs);

% SNR after cancellation
snr_after = 10*log10( mean(clean_speech_ref.^2) / ...
                     mean((cleaned - clean_speech_ref).^2) );
fprintf('SNR after %s suppression: %.2f dB\n', mode, snr_after);
%{  
% Plotting and playing output
figure;
plot(clean_speech_ref, 'b', 'LineWidth',1.2); hold on;
plot(cleaned,           'r', 'LineWidth',1.2);
legend('Reference','Output');
xlabel('Sample'); ylabel('Amplitude');
title(sprintf('Clean vs. Output (%s)',mode));

% FFT comparision
N_fft  = 2^nextpow2(length(cleaned));
f_axis = Fs * (0:(N_fft/2-1)) / N_fft;

% Zero padding to N_fft length
Y_clean = my_fft(cleaned,   N_fft);
Y_orig  = my_fft(noisy_speech, N_fft);

mag_clean = abs(Y_clean(1:N_fft/2));
mag_orig  = abs(Y_orig(1:N_fft/2));

figure;
plot(f_axis, (mag_orig), 'b', 'LineWidth', 1.2); hold on;
plot(f_axis, ...
    (mag_clean),'r', 'LineWidth', 1.2);
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title(sprintf('Spectrum: Original vs. Output (%s mode)', mode));
legend('Original Noisy Speech','Cleaned Output');
grid on;

if strcmp(mode,'partial')
    for f0 = freqs(:).'
        xline(f0, '--k', sprintf('%d Hz', round(f0)), ...
             'LabelVerticalAlignment','bottom');
    end
    legend('Original','Output','Preserved Tones');
end
%}