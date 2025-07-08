function cleaned_speech = rls_algorithm(noisy_speech, w, b_sec, a_sec)

    % Parameters
    fo     = 8;               % Filter order 
    lambda = 0.99999;         % Forgetting factor
    delta  = 0.0001;          % Initialization factor
    N      = length(w);

    % RLS state variables
    h = zeros(fo, 1);               % Filter coefficients
    P = (1/delta) * eye(fo);        % Inverse correlation matrix
    y_buf = zeros(fo, 1);           % Delay line for filtered reference
    cleaned_speech = zeros(N, 1);

    % Initializing notch filter states
    num_filters = length(b_sec);
    filter_states = cell(num_filters, 1);
    for i = 1:num_filters
        L = max(length(b_sec{i}), length(a_sec{i})) - 1;
        filter_states{i} = zeros(L, 1);
    end

    % Main loop
    for n = 1:N
       % specific sample of external noise
        x = w(n);

       % giving external noise to notch filters
        for i = 1:num_filters
            [x, filter_states{i}] = filter(b_sec{i}, a_sec{i}, x, filter_states{i});
        end

        % Updating delay line
        y_buf = [x; y_buf(1:end-1)];
        x_vec = y_buf;

        % Estimating noise
        y_hat = h' * x_vec;

        % Error (cleaned speech)
        e = noisy_speech(n) - y_hat;
        cleaned_speech(n) = e;
        
        % gain calculation
        Pi_x = P * x_vec;
        g = Pi_x / (lambda + x_vec' * Pi_x);

        % Updating weights and inverse correlation matrix
        h = h + g * e;
        P = (P - g * x_vec' * P) / lambda;
        
    end
end
