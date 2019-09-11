function [T__mat,T_mat] = Active_BLAA(N, node_data, mp)
global mali_node
Dist = 120;                     % One-hop wireless radio range(m)
ttime = 300;                    % Time for compute the round
forwarding = 0.95;              % Forwarding probability
mmnode = round(N*mp);            % Number of malicious nodes
W = 4; %maximum route length for active detection
G = 0.95; %gamma coefficent, ���״����̼��� �ϴ� ���ٰ� ����
delta = 0.5;
T_mat = zeros(N,N,10); % ���庰 �� ��忡���� trust�� ���� matrix
alpha = 1;
% Set honesty nodes & malicious nodes
% honesty node : 0, malicious node : 1
node = zeros(N,ttime/30+2);
temp_mali = randperm(N);% temp_mali������ N�� ���Ƿ� �迭��Ŵ
mali_node = temp_mali(1:mmnode);
%mali_node�� N�� ����� mnode������ŭ ���Ƿ� mali ��带 ����
for l = 1:N
    if sum(l==mali_node) == 1
        node(l,1) = 1;
    end
end
%������ node�� 92x12 ����̰� 0���Ϳ��µ�, ������ ���� mali��忡 �ش��ϴ� ������ 1�� �Ҵ��Ŵ
TA = temp_mali(mmnode+1);


% Calculate TA's reputation
d = zeros(1,ttime/30);  %d�� ����
BR = zeros(N,ttime/30);
GR = zeros(N,ttime/30);
for i = 1:(ttime/30)    
    % Set behavior of nodes
    p_events = zeros(N,N);
    n_events = zeros(N,N);
    for k = 1:N
        for l = 1:60
            prob_a = rand(N,50);
            prob_b = rand(N,50);
            neighbor = 0;
            request_node = 0;
            for m = 1:N
                % Calculate distance between nodes
                dist = sqrt((node_data(l+60*(i-1),2*k)-node_data(l+60*(i-1),2*m)).^2 + (node_data(l+60*(i-1),(2*k)+1)-node_data(l+60*(i-1),(2*m)+1)).^2);
                if k ~= m && dist <= Dist*W
                    if neighbor == 0
                        neighbor = m;
                    else
                        neighbor = [neighbor; m];
                    end                                                    
                end            
            end
         
            temp_size = max(size(neighbor));
            for n = 1:50
                temp = randperm(temp_size);
                request_node = neighbor(temp(1));
                if request_node ~= 0
                    if node(k,1) == 0 %�� ��尡 �����϶�
                        % honesty node $������ �������
                        if node(request_node,1) == 0 %request node�� honest��
                            if prob_a(request_node,n) <= forwarding 
                                if prob_b(request_node,n) <= 0.95
                                    p_events(k,request_node) = p_events(k,request_node) + 1;
                                else
                                    n_events(k,request_node) = n_events(k,request_node) + 1;
                                end 
                            else
                                if prob_b(request_node,n) <= 0.95
                                    n_events(k,request_node) = n_events(k,request_node) + 1;
                                else
                                    p_events(k,request_node) = p_events(k,request_node) + 1;
                                end
                            end
                        % malicious node %��밡 mali��
                        else                    
                            
                                if prob_a(request_node,n) <= alpha 
                                    if prob_b(request_node,n) <= 0.95
                                        n_events(k,request_node) = n_events(k,request_node) + 1;
                                    else
                                        n_events(k,request_node) = n_events(k,request_node) + 1;
                                    end 
                                else 
                                    if prob_b(request_node,n) <= 0.95
                                        p_events(k,request_node) = p_events(k,request_node) + 1;
                                    else
                                        n_events(k,request_node) = n_events(k,request_node) + 1;
                                    end
                                end
                      
                               
                        end
                        
                    else % ���� ���� ���k�� mali ���,,,
                       % if node(request_node,1) == 1 %������忡�� 
                        %    n_events(k, request_node) = n_events(k, request_node) + 1;
                       % else %�����忡��
                       %     n_events(k, request_node) = n_events(k, request_node) + 1;
                       % end %black hole attack�� �����̰� mali�� ��Ŷ���˴� �����
                    end
                end
            end 
        end
    end


    % LTO & d
    LTO = zeros(N,N); %Active Trust���� LTO�� direction Trust
    for k = 1:N
        for l = 1:N
            if k == l || (p_events(k,l)+n_events(k,l)) == 0
                LTO(k,l) = NaN;                           
            else
                LTO(k,l) = p_events(k,l)/(p_events(k,l)+n_events(k,l));
                d(i) = d(i) + 1;
            end           
        end
    end
    d(i) = d(i)/(N*(N-1));
    %attenuation function applied to directional trust
    T_mat(:,:,i) = LTO; %�� ȩ ���� ������ ������ �����Ͽ�, T_mat�� ����.
end

TT_mat = zeros(N,N,10); %attenuation ���
TT_mat(:,:,1) = T_mat(:,:,1);
TT_mat(:,:,2) = (T_mat(:,:,1).*(G^1) + T_mat(:,:,2).*(G^0))./2;
TT_mat(:,:,3) = (T_mat(:,:,1).*(G^2) + T_mat(:,:,2).*(G^1) + T_mat(:,:,3).*(G^0) )./3;
TT_mat(:,:,4) = (T_mat(:,:,1).*(G^3) + T_mat(:,:,2).*(G^2) + T_mat(:,:,3).*(G^1) + T_mat(:,:,4).*(G^0))./4;
TT_mat(:,:,5) = (T_mat(:,:,1).*(G^4) + T_mat(:,:,2).*(G^3) + T_mat(:,:,3).*(G^2) + T_mat(:,:,4).*(G^1) + T_mat(:,:,5).*(G^0))./5;
TT_mat(:,:,6) = (T_mat(:,:,1).*(G^5) + T_mat(:,:,2).*(G^4) + T_mat(:,:,3).*(G^3) + T_mat(:,:,4).*(G^2) + T_mat(:,:,5).*(G^1) + T_mat(:,:,6).*(G^0))./6    ;
TT_mat(:,:,7) = (T_mat(:,:,1).*(G^6) + T_mat(:,:,2).*(G^5) + T_mat(:,:,3).*(G^4) + T_mat(:,:,4).*(G^3) + T_mat(:,:,5).*(G^2) + T_mat(:,:,6).*(G^1) + T_mat(:,:,2).*(G^0))./7  ;
TT_mat(:,:,8) = (T_mat(:,:,1).*(G^7) + T_mat(:,:,2).*(G^6) + T_mat(:,:,3).*(G^5) + T_mat(:,:,4).*(G^4) + T_mat(:,:,5).*(G^3) + T_mat(:,:,6).*(G^2) + T_mat(:,:,2).*(G^1) + T_mat(:,:,8).*(G^0))./8;
TT_mat(:,:,9) = (T_mat(:,:,1).*(G^8) + T_mat(:,:,2).*(G^7) + T_mat(:,:,3).*(G^6) + T_mat(:,:,4).*(G^5) + T_mat(:,:,5).*(G^4) + T_mat(:,:,6).*(G^3) + T_mat(:,:,2).*(G^2) + T_mat(:,:,8).*(G^1)+T_mat(:,:,9).*(G^0) )./9;
TT_mat(:,:,10) = (T_mat(:,:,1).*(G^9) + T_mat(:,:,2).*(G^8) + T_mat(:,:,3).*(G^7) + T_mat(:,:,4).*(G^6) + T_mat(:,:,5).*(G^5) + T_mat(:,:,6).*(G^4) + T_mat(:,:,7).*(G^3) + T_mat(:,:,8).*(G^2)+T_mat(:,:,9).*(G^1) + T_mat(:,:,10).*(G^0))./10;
%Attenation ���볡 
 





%�� ������ ���� T_mat �� �� �����ٰ� ����
% next recommendation Trust Merging process


U = zeros(N,N,10); %Recommendation Trust merging
C= zeros(N,N,10); %Comprehensive Trust
for k = 1: 10
    for i=1:N
        for j=1:N
            if TT_mat(i,j,k) == 0 && sum(TT_mat(:,j,k),'omitnan')==0 
                U(i,j,k) =0;
            else
            U(i,j,k) = TT_mat(i,j,k)/sum(TT_mat(:,j,k),'omitnan');
            end
            C(i,j,k) = (delta).*(TT_mat(i,j,k)) + (1-delta).*(U(i,j,k));
        end
    end
end







% SR, GR ���� ��ȯ, SRGR�� 93���� ���� ���� 1�� �����Ѵ�

T__mat = ones(N+1,N+1,10);
for a = 1:10
    for b = 1:N
        for c = 1:N 
            T__mat(b,c,a) = C(b,c,a);
        end
    end
end
