function partitions = getNonOverlappingPartions(wholeSet,k)

N = length(wholeSet);
p = randperm(N);
wholeSet = wholeSet(p);
partitionSize = floor(N/k);
partitions = cell(k,2);

for i = 1:k
    ind_b = 1+(i-1)*partitionSize;
    ind_e = i*partitionSize;
    partitions{i,1} = wholeSet(ind_b:ind_e);
    partitions{i,2} = wholeSet(setdiff(1:N,ind_b:ind_e));    
end