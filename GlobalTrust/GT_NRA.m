clc;
clear all;
fclose all;

N = 92;                         % The number of nodes
mnode = 28;                     % The number of malicious nodes
ttime = 30;                     % time for compute the reputation(min)
forwarding = 0.95;              % forwarding probability
alpha = 0.8;                    % probability that malicious node drops a packet
gamma = 0.7;                    % gamma coefficient
decision = 0.8;                 % decision coefficient

% Set honesty nodes & malicious nodes
% honesty node : 0, malicious node : 1
node = zeros(N,2);
a = randperm(92);
mali_node = a(1:mnode);
for k = 1:mnode
    for l = 1:N
        if mali_node(k) == l
            node(l,1) = 1;
        end
    end
end

tic
% load gps data
for k = 1:N
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

% Set behavior of nodes 
p_events = zeros(N, N);
n_events = zeros(N, N);
dist = zeros(N,N);
for k = 1:N
    for l = 1:N
        for m = 1:(2*ttime);
            % Calculate distance between nodes
            dist = sqrt((node_data(m,2*k)-node_data(m,2*l)).^2 + (node_data(m,(2*k)+1)-node_data(m,(2*l)+1)).^2);
            if k ~= l && dist <= 40000
                for n = 1:50
                    a = rand(2,1); 
                    % honesty node
                    if node(l,1) == 0 && a(1) <= forwarding
                        if a(2) < 0.95
                            p_events(k,l) = p_events(k,l) + 1;
                        else
                            n_events(k,l) = n_events(k,l) + 1;
                        end
                    elseif node(l,1) == 0 && a(1) > forwarding
                       if a(2) < 0.95
                           n_events(k,l) = n_events(k,l) + 1;
                       else
                           p_events(k,l) = p_events(k,l) + 1;
                       end 
                    % malicious node
                    elseif node(l,1) == 1 && a(1) >= alpha
                       if a(2) < 0.95
                           p_events(k,l) = p_events(k,l) + 1;
                       else
                           n_events(k,l) = n_events(k,l) + 1;
                       end
                    else
                        if a(2) < 0.95
                           n_events(k,l) = n_events(k,l) + 1;
                        else
                           p_events(k,l) = p_events(k,l) + 1;
                        end
                    end
                end 
            end            
        end
    end
end


% LTO & d
LTO = zeros(N,N);
d = 0;
for k = 1:N
    for l = 1:N
        if k == l || p_events(k,l)+n_events(k,l) == 0
            LTO(k,l) = NaN;                           
        else
            LTO(k,l) = p_events(k,l)/(p_events(k,l)+n_events(k,l));
            d = d+1;
            if node(k,1) == 1
                LTO(k,l) = 1 - LTO(k,l);
            end
        end
    end
end
d = d/(N*(N-1))

% Similarity
sim = zeros(N,N);
LTO_for_sim = (LTO .*2) -1;
LTO_for_sim(isnan(LTO_for_sim)) = 0;
for k = 1:N    
    for l = 1:N       
        norm_k = sqrt(sum(LTO_for_sim(k,:) .^2));
        norm_l = sqrt(sum(LTO_for_sim(l,:) .^2));
        deno = sum(LTO_for_sim(k,:) .* LTO_for_sim(l,:));
        sim(k,l) = deno / (norm_k * norm_l);
        if sim(k,l) < 0
            sim(k,l) = 0;
        end
    end
end

% SR
SR = zeros(N,N);
HR = ones(1,N);
HR(1) = 2;
SR_num = zeros(N,N);
sum_HR = zeros(N,N);
temp_LTO = LTO;
temp_LTO(isnan(temp_LTO)) = 0;

S_check = zeros(N,1);
for k = 1:N    
    for l = 1:N
        S_check(k) = S_check(k) + isnan(LTO(l,k));
    end
end

for k = 1:N
    for l = 1:N
        for m = 1:N
            if isnan(LTO(m,l)) == 0
                SR_num(k,l) = SR_num(k,l) + (HR(m)*sim(k,m));
                sum_HR(k,l) = sum_HR(k,l) + HR(m);
            end
        end
    end    
end
    
for k = 1:N
    for l = 1:N
        if SR_num(k,l) ~= 0
            for m = 1:N
                if isnan(LTO(m,l)) == 0
                    SR(k,l) = SR(k,l) + (temp_LTO(m,l)*((HR(m)*sim(k,m))/SR_num(k,l)));
                end
            end
        elseif S_check(l) ~= N 
            for m = 1:N
                if isnan(LTO(m,l)) == 0
                    SR(k,l) = SR(k,l) + (temp_LTO(m,l)*(HR(m)/sum_HR(k,l)));
                end
            end
        else
            SR(k,l) = NaN;
        end
    end
end

% D
SR_dist = zeros(N,N);
D = zeros(1,1);
D_num = N;
cul_num = 0;
for k = 1:N
    for l = 1:N
        SR_dist(k,l) = sqrt(sum((SR(k,:)-SR(l,:)).^2));
    end
end

Z = linkage(SR_dist);
while D_num >= N/2    
    cul_num = cul_num + 1;
    cluster_size = zeros(1,2);
    W = cluster(Z,'maxclust', cul_num);
    for k = 1:N/2
        if k == 1
            cluster_size = size(find(W==k));
        else            
            cluster_size = [cluster_size ; size(find(W==k))];
            if min(size(find(W==k))) == 0
                break;
            end
        end
    end
    D_num = max(max(cluster_size));
end

W = cluster(Z,'maxclust', cul_num-1);
for k = 1:N/2
    if k == 1
        cluster_size = size(find(W==k));
    else            
        cluster_size = [cluster_size ; size(find(W==k))];
        if min(size(find(W==k))) == 0
            break;
        end
    end
end

for k = 1:N
    if W(k) == find(cluster_size==max(max(cluster_size)))
        if D == 0
            D = k;
        else
            D = [D; k];
        end
    end
end

% BR
BR = zeros(N,1);
for k = 1:N
    for l = 1:N
        if S_check(k) == N
            BR(k) = NaN;
        else
            for m = 1:max(size(D))
                if D(m) == l
                    BR(k) = BR(k) + SR(l,k);
                end
            end
        end
    end
end
BR = BR ./ max(size(D));

% CR
CR = zeros(N,1);
LTO_k = zeros(N,1);
for k = 1:N
    for l = 1:N
        LTO_k(k) = LTO_k(k) + isnan(LTO(k,l));
    end
end

for k = 1:N
    Cr_num = 0;
    sum_LTO = 0;
    if LTO_k(k) == N
        CR(k) = NaN;
    else
        for l = 1:N
            if isnan(LTO(k,l)) == 0                
                sum_LTO = sum_LTO + (LTO(k,l)-BR(l))^2;
                Cr_num = Cr_num + 1;
            end            
        end
        CR(k) = 1-sqrt(sum_LTO/Cr_num);
    end
end

% GR
GR = zeros(N,1);
for k = 1:N
    if isnan(BR(k)) == 1 && isnan(CR(k)) == 1
        GR(k) = NaN;
    elseif isnan(BR(k)) == 0 && isnan(CR(k)) == 0
        GR(k) = gamma*BR(k) + (1-gamma)*CR(k);
    elseif isnan(BR(k)) == 1 && isnan(CR(k)) == 0
        GR(k) = CR(k);
    else
        GR(k) = BR(k);
    end
end

% node decision
for k = 1:N
    if isnan(GR(k)) == 1;
        node(k,2) = NaN;
    elseif GR(k) < decision;
        node(k,2) = 1;
    else
        node(k,2) = 0;
    end
end

% Simulation result
FP = 0;
FN = 0;
FP_prob = 0;
FN_prob = 0;
for k = 1:N;
    if node(k,1) ~= node(k,2)
        if node(k,1) == 0
            FP = FP + 1;
        else
            FN = FN + 1;
        end
    end
end
FP_prob = FP/(N-mnode)
FN_prob = FN/mnode

toc
fclose all;

