N = 100;
alpha = 1.5;
timeslot = zeros(6,100);
complexity = zeros(6,100);
timeslot_norm = zeros(6,100);
complexity_norm = zeros(6,100);
w = zeros(1,11);
for k = 1:11;
    w(k) = (k-1)/10;
end

beta = w(1:6);

for k = 1:6
    for l = 1:100
        timeslot(k,l) = alpha*(N/l+(1-beta(k))*l+beta(k)*N);
        if l == 1
            complexity(k,l) = N^3;
        else
            complexity(k,l) = max(max((N/l)^3,(1-beta(k)).^3*(l^3)),(beta(k)*N)^3);
        end
    end
    timeslot_norm(k,:) = timeslot(k,:)./max(timeslot(k,:));
    complexity_norm(k,:) = complexity(k,:)./N^3;
end


total_time = zeros(11,100,6);
for k = 1:11
    for l = 1:100
        for m = 1:6
            total_time(k,l,m) = (1-w(k))*timeslot_norm(m,l) + w(k)*complexity_norm(m,l);
        end
    end
end

min_cluster = zeros(6,11);
for k = 1:6
    for l = 1:11
         temp_min = find(total_time(l,:,k)==min(total_time(l,:,k)));
         min_cluster(k,l) = temp_min(1);
    end
end

figure
mesh(1:100, w, total_time(:,:,1));
title('beta = 0');
figure
mesh(1:100, w, total_time(:,:,2));
title('beta = 0.1');
figure
mesh(1:100, w, total_time(:,:,3));
title('beta = 0.2');
figure
mesh(1:100, w, total_time(:,:,4));
title('beta = 0.3');
figure
mesh(1:100, w, total_time(:,:,5));
title('beta = 0.4');
figure
mesh(1:100, w, total_time(:,:,6));
title('beta = 0.5');