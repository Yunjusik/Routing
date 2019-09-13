


global XX
global YY
global mali_node
%global mali_node
ttime = 300;
R = 80; %  전송반경
noOfNodes  = 1000;

hold on;
L = 500;
node_data = zeros(600, 2*noOfNodes+1);

matrix = zeros(noOfNodes);
dist = zeros(1,noOfNodes);


% L 반지름 직경만큼 원형으로 랜덤 노드 발생
x = zeros( 1 , noOfNodes);
y = zeros( 1, noOfNodes);
for i = 1 : noOfNodes-1 % 노드수
   x(i) = (-1 + 2 * rand(1)) * L;
   y(i) =  sqrt(L^2 - x(i)^2)*(-1 + 2 *rand(1));
   dist(i) = sqrt(x(i)^2+y(i)^2);
end



for i = 1:noOfNodes
   plot(x(i), y(i), '.');
     text(x(i), y(i), num2str(i));
    for j = 1:noOfNodes
           distance = sqrt((x(i) - x(j))^2 + (y(i) - y(j))^2);
           matrix(i,j) = distance;

           if distance <= R        
           line([x(i) x(j)], [y(i) y(j)], 'LineStyle', ':');
           else               
           end
    end
 end

dist2 = dist;
List = []; %라우팅 소스노드 정하기
for i = 1 : round(0.2 * noOfNodes)
    [a b] = max(dist2);
    dist2(b) = 0;
    List = [List b];
end

for i = 1:600
    node_data(i,1) = i;
    for j = 1 : noOfNodes
        node_data(i,2*j) = x(j);
        node_data(i,2*j+1) = y(j);
    end
end
XX = zeros(600,noOfNodes);
YY = zeros(600,noOfNodes);
%--------------------
sink = noOfNodes;
for i = 1: 600
     for k = 1:noOfNodes
        XX(i,k) = x(k);     % XX는 노드데이터에서 x성분만 추출 (600 x node수+싱크)
        YY(i,k) = y(k);   % YY는 노드데이터에서 y좌표만 추출 (600 x node수+싱크)
    end
end
%-------------------
%alpha = 0.5;
%mp = 0.3;

%[SR,GR,d] = MGT_ex(noOfNodes-1, node_data, alpha, mp);
%[mal_ratio,S_ratio,mat] = Trust_routing22(SR,GR,noOfNodes,1,5,sink);

%0----------


%%%라우팅 반복부 : 1~ 600라운드까지,
%%% s->d는 일단 임의로 정함 

Sum_S_ratio = 0;
S_ratio = 0;
mal_ratio=0;
Sum_mal_ratio = 0;
Count = 0;
Time=600; % 몇회차까지 라우팅을 진행할건지. 최대 600
z=1; %z는 랜덤성을 최소화하기 위한 iteration 숫자
S_ratio_array = zeros(z,Time/60); % z회만큼 array를 누적시킬예정
mal_ratio_array = zeros(z,Time/60); 
S_Routing_array = zeros(z,Time/60);
alpha = 1;
mp = 0;
Result = [];
Result2 = [];
Result3 = [];
h = waitbar(0,'진행 상황'); % 제목 넣어서 waitbar를 띄움.
Count2 =0; %총 라우팅수
%-----------------


for mp = 0.3 : 0.05 : 0.55
    
for i = 1: z 
    i
    [T__mat,T_mat] = Active_BLA(noOfNodes-1, node_data, mp)
        for n = 60 : 60 : Time %라운드 반복
            for s = 1:round(0.2 * noOfNodes) % 200번 반복
               
                if (find(List(s) == mali_node) >=1)
                else
                    [mal_ratio,S_ratio] = Active_R2(T__mat,noOfNodes,n,List(s));
                    Count2 = Count2 +1;
                    if S_ratio ~= -1 %%거리문제로 라우팅 실패한 경우 라우팅 성공률에 포함시키지않음
                    Sum_S_ratio = Sum_S_ratio + S_ratio; %라우팅 가능하면 S_ratio를 누적
                
                    Sum_mal_ratio = Sum_mal_ratio + mal_ratio; %라우팅 가능시 mal_ratio를 누적
         
                    Count = Count+1; %라우팅 성공시 카운터
                    end
                end
            end  

            S_ratio_array(i,n/60) = Sum_S_ratio/Count; % 배열에 회차당 평균 성공률 삽입
            mal_ratio_array(i,n/60) = Sum_mal_ratio/Count ;% 배열에 회차당 평균 말리노드포함률 삽입
            S_Routing_array(i,n/60) =  Count/Count2;
            
            
            Sum_S_ratio = 0; % 한바퀴 다돌면 평균 성공률 0으로 초기화함
            Sum_mal_ratio = 0;        
            Count = 0;
            Count2 = 0;
                        
        end %100회차까지 끝
        
end
S_ratio_per_round = mean(S_ratio_array, 'omitnan'); % 라운드별 성공률을 z회차만큼 누적시켰기 때문에 다시 평균내어 보여줌
mal_ratio_per_round = mean(mal_ratio_array, 'omitnan');
S_Routing_per_round = mean(S_Routing_array, 'omitnan');

AVG_ratio = mean(S_ratio_per_round, 'omitnan');
AVG_ratio2 = mean(mal_ratio_per_round, 'omitnan');
AVG_ratio3 = mean(S_Routing_per_round, 'omitnan');


Result = [Result AVG_ratio];
Result2 = [Result2 AVG_ratio2];
Result3 = [Result3 AVG_ratio3];
waitbar(mp/0.5)
end

mp = [0.3 : 0.05 : 0.6];


figure(2)
subplot(2,1,1)
plot(mp,Result,'b--o')
subplot(2,1,2)
plot(mp,Result2, 'b-*')
%legend( 'success data routing ratio ' , 'Malicious node ratio of routing path ')
figure(3)
plot(mp,Result3, 'b-*')