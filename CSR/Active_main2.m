global mali_node
global XX
global YY

%global mali_node
ttime = 300;
R = 120; %  전송반경
noOfNodes  = 500;

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
mp = 0;
alpha = 0.5;
Sum_S_ratio = 0;
S_ratio = 0;
mal_ratio = 0;
Sum_mal_ratio = 0;
Count = 0;
Count2=0;
Count3=0;

Time=600; % 몇회차까지 라우팅을 진행할건지. 최대 600
z=5; %z는 랜덤성을 최소화하기 위한 iteration 숫자

SR_per_Iteration = zeros(1,z);
MR_per_Iteration = zeros(1,z);
Result = [];
Result2 = [];


h = waitbar(0,'진행 상황'); % 제목 넣어서 waitbar를 띄움.


%-----------------
for mp = 0.1 : 0.05 :0.5    
    for i = 1: z 
        
        %[SR,GR,d] = MGT_ex(noOfNodes-1,node_data, alpha, mp);
        %[T__mat,T_mat] = Active_BLA(noOfNodes-1, node_data, mp);
        [T__mat,T_mat] = Active_CBA(noOfNodes-1, node_data, mp);
        
        for s = 1:noOfNodes-1 % 소스 1부터 n-1까지 변화를줌, Dest는 n
              %새로운 s가 지정되면, 원래의 cost matrix를 복구
             C = T__mat; % cost matrix를 C라는 전역변수로 대입
                         % s가 바뀔때마다 C는 다시 cost matrix원본으로 바뀜
             
             if (find(s == mali_node) >=1)
             else
               
                for n = 60 : 60 : Time %10라운드간 
                   mp, n, i
                    [mal_ratio,S_ratio,sp] = Active_R2(C,noOfNodes,n,s);
                    if length(sp) ~= 2
   
                    Count2= Count2 +1;   %라우팅 실행의 총 카운트    
                    %Active Trust에서는 한번 거친 노드는 다시 거치지 않음.
                                   mal_ratio    
                                       
                    if S_ratio ~= -1  %routing이 성공된 경우
                       Sum_S_ratio = Sum_S_ratio + S_ratio; %라우팅 가능하면 S_ratio를 누적
                       Sum_mal_ratio = Sum_mal_ratio + mal_ratio; %라우팅 가능시 mal_ratio를 누적
                       Count = Count+1; % 성공했을때만 세는 카운트
                       
                       
                       if length(sp) >=3 %라우팅이 성공적이고, 경유노드가 있다면,
                           for a = 2:length(sp)-1
                               C(:,sp(a),:) =0;
                           end                   
                       end
                    end
                    end
                end
             end
        end %source 1~ 499까지 한바퀴 돔(각 10라운드로)
        %이때 카운트도 횟수만큼 누적되어있음
        SR_per_Iteration(i) = Sum_S_ratio/Count2;
        MR_per_Iteration(i) = Sum_mal_ratio/Count;
        Count=0;
        Count2=0;
        Sum_S_ratio =0;
        Sum_mal_ratio =0;    
    end
    Result = [Result mean(SR_per_Iteration, 'omitnan')];
    Result2 = [Result2 mean(MR_per_Iteration, 'omitnan')];
    waitbar(length(Result)/6)
end

mp = [0.1 : 0.05 :0.5];

figure(1)
subplot(2,1,1)
plot(mp,Result,'b--o')                
subplot(2,1,2)
plot(mp,Result2, 'b-*')                
grid on                
                
 %Active CBA, iteration 5회