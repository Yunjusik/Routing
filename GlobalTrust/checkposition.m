N = 1;
grids = 25;
node_data = zeros(600,2*N);

% Set initial position of node_data
temp_pos = randperm(grids);
for k = 1:N    
    node_data(1,2*k-1) = mod((temp_pos(k)-1),5) - 2;
    node_data(1,2*k) = floor((temp_pos(k)-1)/5) - 2;
end

for i = 1:600
    if i > 1
        for k = 1:N
            change_pos = 5*rand(1,1);
            if change_pos < 1
                if node_data(i-1,2*k-1) < 2
                    node_data(i,2*k-1) = node_data(i-1,2*k-1) + 1;
                else
                    node_data(i,2*k-1) = 2;
                end
                node_data(i,2*k) = node_data(i-1,2*k);
            elseif change_pos < 2
                if node_data(i-1,2*k) < 2
                    node_data(i,2*k) = node_data(i-1,2*k) + 1;
                else
                    node_data(i,2*k) = 2;
                end
                node_data(i,2*k-1) = node_data(i-1,2*k-1);
            elseif change_pos < 3
                if node_data(i-1,2*k-1) > -2
                    node_data(i,2*k-1) = node_data(i-1,2*k-1) - 1;
                else
                    node_data(i,2*k-1) = -2;
                end
                node_data(i,2*k) = node_data(i-1,2*k);
            elseif change_pos < 4
                if node_data(i-1,2*k) > -2
                    node_data(i,2*k) = node_data(i-1,2*k) - 1;
                else
                    node_data(i,2*k) = -2;
                end
                node_data(i,2*k-1) = node_data(i-1,2*k-1);
            else
                node_data(i,2*k-1) = node_data(i-1,2*k-1);
                node_data(i,2*k) = node_data(i-1,2*k);
            end
        end
    end
end

