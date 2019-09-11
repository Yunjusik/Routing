function [T__mat,T_mat] = Active_BLAA(N, node_data, mp)
global mali_node
Dist = 120;                     % One-hop wireless radio range(m)
ttime = 300;                    % Time for compute the round
forwarding = 0.95;              % Forwarding probability
mmnode = round(N*mp);            % Number of malicious nodes
W = 4; %maximum route length for active detection
G = 0.95; %gamma coefficent, 어테뉴에이션은 일단 없다고 가정
delta = 0.5;
T_mat = zeros(N,N,10); % 라운드별 각 노드에대한 trust를 모은 matrix
alpha = 1;
% Set honesty nodes & malicious nodes
% honesty node : 0, malicious node : 1
node = zeros(N,ttime/30+2);
temp_mali = randperm(N);% temp_mali에서는 N을 임의로 배열시킴
mali_node = temp_mali(1:mmnode);
%mali_node는 N개 노드중 mnode개수만큼 임의로 mali 노드를 선출
for l = 1:N
    if sum(l==mali_node) == 1
        node(l,1) = 1;
    end
end
%기존에 node는 92x12 행렬이고 0벡터였는데, 위에서 정한 mali노드에 해당하는 영역에 1을 할당시킴
TA = temp_mali(mmnode+1);


% Calculate TA's reputation
d = zeros(1,ttime/30);  %d는 뭘까
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
                    if node(k,1) == 0 %현 노드가 정상일때
                        % honesty node $상대방이 정상노드면
                        if node(request_node,1) == 0 %request node가 honest면
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
                        % malicious node %상대가 mali면
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
                        
                    else % 만약 현재 노드k가 mali 라면,,,
                       % if node(request_node,1) == 1 %말리노드에게 
                        %    n_events(k, request_node) = n_events(k, request_node) + 1;
                       % else %정상노드에게
                       %     n_events(k, request_node) = n_events(k, request_node) + 1;
                       % end %black hole attack은 정상이건 mali건 패킷을죄다 드랍함
                    end
                end
            end 
        end
    end


    % LTO & d
    LTO = zeros(N,N); %Active Trust에서 LTO는 direction Trust
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
    T_mat(:,:,i) = LTO; %한 홉 내의 데이터 전송을 관찰하여, T_mat에 적립.
end

TT_mat = zeros(N,N,10); %attenuation 고려
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
%Attenation 적용끝 
 





%위 과정을 통해 T_mat 이 다 모여졌다고 가정
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







% SR, GR 최종 반환, SRGR의 93번에 대한 값은 1로 고정한다

T__mat = ones(N+1,N+1,10);
for a = 1:10
    for b = 1:N
        for c = 1:N 
            T__mat(b,c,a) = C(b,c,a);
        end
    end
end
