clc;
clear;
close all;

%% 1. Input Source Probabilities
raw = strtrim(input('Enter probabilities as a vector, e.g. [0.7 0.3]: ', 's'));

if isempty(raw) || raw(1) ~= '[' || raw(end) ~= ']'
    error('Enter probabilities in this format: [0.7 0.3].');
end

p = str2num(raw); %#ok<ST2NM>

%% 2. Validate Probabilities
if isempty(p) || ~isnumeric(p) || ~isvector(p) || ~isreal(p) || ...
        any(~isfinite(p)) || any(p <= 0)
    error('Invalid probabilities. Use positive numbers that add up to 1.');
end

p = p(:).';

N = length(p);
if N < 2
    error('Enter at least two symbol probabilities, e.g. [0.7 0.3].');
end

if abs(sum(p) - 1) > 1e-10
    error('The probabilities must add up to 1.');
end

% Generate symbol names
symbols = 1:N;

%% 3. Sort Probabilities in Descending Order
[p, idx] = sort(p, 'descend');
symbols = symbols(idx);

%% 4. Initialize Codewords
codewords = repmat({''}, 1, N);

%% 5. Generate Binary Fano Codes
codewords = fano_encode(p, codewords, 1, N);

%% 6. Calculate Codeword Lengths
code_lengths = zeros(1, N);

for i = 1:N
    code_lengths(i) = length(codewords{i});
end

%% 7. Calculate Average Codeword Length
L_avg = sum(p .* code_lengths);

%% 8. Calculate Source Entropy
H = -sum(p .* log2(p));

%% 9. Calculate Efficiency
Efficiency = L_avg / H;

% Conventional source coding efficiency in percentage
CodingEfficiency = (H / L_avg) * 100;

%% 10. Display Results
fprintf('\n========== Binary Fano Coding ==========\n\n');

fprintf('%-10s %-15s %-15s %-15s\n', ...
    'Symbol', 'Probability', 'Codeword', 'Length');

fprintf('------------------------------------------------------\n');

for i = 1:N
    fprintf('S%-9d %-15.4f %-15s %-15d\n', ...
        symbols(i), p(i), codewords{i}, code_lengths(i));
end

fprintf('------------------------------------------------------\n');

fprintf('Sum of Probabilities       = %.6f\n', sum(p));
fprintf('Average Codeword Length    = %.6f bits/symbol\n', L_avg);
fprintf('Source Entropy H(X)        = %.6f bits/symbol\n', H);
fprintf('Efficiency L_avg / H(X)    = %.6f\n', Efficiency);
fprintf('Coding Efficiency          = %.2f%%\n', CodingEfficiency);

fprintf('\n==========================================\n');

%% 11. Recursive Fano Encoding Function
function codewords = fano_encode(p, codewords, first, last)

    % Stop when the subset contains only one symbol
    if first >= last
        return;
    end

    % Calculate the total probability of the current subset
    total_probability = sum(p(first:last));

    % Find the split that minimizes the difference
    % between the probabilities of the two subsets
    best_split = first;
    min_difference = inf;
    cumulative_probability = 0;

    for k = first:last-1

        cumulative_probability = cumulative_probability + p(k);

        remaining_probability = total_probability ...
                              - cumulative_probability;

        difference = abs(cumulative_probability ...
                         - remaining_probability);

        if difference < min_difference
            min_difference = difference;
            best_split = k;
        end
    end

    % Assign 0 to the first subset
    for i = first:best_split
        codewords{i} = [codewords{i} '0'];
    end

    % Assign 1 to the second subset
    for i = best_split+1:last
        codewords{i} = [codewords{i} '1'];
    end

    % Repeat Fano coding for both subsets
    codewords = fano_encode(p, codewords, first, best_split);

    codewords = fano_encode(p, codewords, best_split+1, last);

end