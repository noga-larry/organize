function exp = cellArrayToOrRegexp(arr)

exp = '';
for i = 1: length(arr)
    exp = [exp '|' arr{i}];
end

