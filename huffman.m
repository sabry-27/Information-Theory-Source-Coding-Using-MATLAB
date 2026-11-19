
clc; clear; close all;

% source
% Test case from the report:
% [0.35 0.30 0.20 0.10 0.04 0.005 0.005]
raw = strtrim(input('Enter probabilities as a vector, e.g. [0.7 0.3]: ', 's'));

if isempty(raw) || raw(1) ~= '[' || raw(end) ~= ']'
    error('Enter probabilities in this format: [0.7 0.3].');
end

p = str2num(raw);

if ~isnumeric(p) || isempty(p) || ~isvector(p) || ~isreal(p) || any(~isfinite(p)) || any(p <= 0)
    error('Invalid probabilities. Example: [0.7 0.3]. Use positive numbers that add up to 1.');
end

p = p(:).';
if numel(p) < 2
    error('Enter at least two symbol probabilities, e.g. [0.7 0.3].');
end
if abs(sum(p) - 1) > 1e-10
    error('The probabilities must add up to 1, e.g. [0.7 0.3].');
end

n = numel(p);

% integer weights so ties never get messed up by floating point
w = round(p * 1e12);
groups = num2cell(1:n);      % symbols inside each node
codes  = repmat({''}, 1, n);

% huffman: keep merging the two smallest nodes
while numel(w) > 1
    [w, idx] = sort(w, 'descend');
    groups = groups(idx);

    for s = groups{end},   codes{s} = ['1' codes{s}]; end
    for s = groups{end-1}, codes{s} = ['0' codes{s}]; end

    groups{end-1} = [groups{end-1} groups{end}];
    w(end-1) = w(end-1) + w(end);
    groups(end) = [];
    w(end) = [];
end

% results
len = cellfun(@length, codes);
L   = sum(p .* len);
H   = -sum(p .* log2(p));
eff = H / L;

fprintf('%-8s %-8s %-12s %-6s\n', 'Symbol', 'Prob', 'Codeword', 'Length');
fprintf('%s\n', repmat('-', 1, 36));
for i = 1:n
    fprintf('%-8s %-8.3f %-12s %-6d\n', ['s' num2str(i)], p(i), codes{i}, len(i));
end

fprintf('\nEntropy H    = %.4f bits/symbol\n', H);
fprintf('Avg length L = %.4f bits/symbol\n', L);
fprintf('Efficiency   = %.2f %%\n', eff*100);
fprintf('Kraft sum    = %.4f\n', sum(2.^(-len)));  
