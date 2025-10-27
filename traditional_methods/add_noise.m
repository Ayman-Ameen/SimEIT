function signal = add_noise(signal, SNR_dB)
% ADD_NOISE Adds Gaussian noise to a signal at a specified SNR (dB)
%   signal = add_noise(signal, SNR_dB)
%   Adds random noise to the input signal based on the desired SNR in dB.

SNR         = 10.^(SNR_dB/20);
noise       = rand(size(signal));
rms_signal  = sqrt(mean(signal.^2));
rms_noise   = sqrt(mean(noise.^2)) ;
signal      = signal + (noise .* (rms_signal/rms_noise)/SNR);

end