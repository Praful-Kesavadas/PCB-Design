function X = my_fft(x, N)
    % Ensuring that input is a column vector
    x = x(:);

    % Check if N is a power of 2
    if mod(N, 2) ~= 0 && N ~= 1
        error('N must be a power of 2');
    end

    % Zero padding if x is shorter than N
    if length(x) < N
        x = [x; zeros(N - length(x), 1)];
    end

    % Base case
    if N == 1
        X = x;
        return;
    end

    % Recursive implementation of FFT
    even = my_fft(x(1:2:end), N/2);
    odd  = my_fft(x(2:2:end), N/2);

    W = exp(-2j * pi * (0:N/2-1)' / N);
    X = [even + W .* odd;
         even - W .* odd];
end