clear all;
clc;

decision = 0.8;
mnode = 0.3;
ttime = 300;

% load gps data
for k = 1:92
    gps = fopen(sprintf('./KAIST/KAIST_30sec_0%02d.txt', k), 'r');
    temp = fscanf(gps, '%g %g %g', [3 (2*ttime)]);
    if max(size(temp)) < (2*ttime)
        for l = max(size(temp))+1 : (2*ttime)
            temp(1,l) = 30*(l-1);
            temp(2,l) = NaN;
            temp(3,l) = NaN;
        end
    end
    if k == 1
        node_data = temp;
    else
        node_data = [node_data; temp(2, :); temp(3, :)];
    end
end
node_data = node_data';

temp_FP = zeros(100,10);
temp_FN = zeros(100,10);
temp_d = zeros(100,10);

CBA_FP = zeros(1,10);
CBA_FN = zeros(1,10);
CBA_d = zeros(1,10);

for i = 1:10
    alpha = i * 0.1;
    for j = 1:100
        [FP_prob, FN_prob, d] = GT_CBA(node_data, alpha, mnode, decision);
        temp_FP(j,:) = FP_prob;
        temp_FN(j,:) = FN_prob;
        temp_d(j,:) = d;
    end
    CBA_FP(i) = sum(sum(temp_FP))/1000;
    CBA_FN(i) = sum(sum(temp_FN))/1000;
    d(i) = sum(sum(d))/1000;
end       

fclose all;
