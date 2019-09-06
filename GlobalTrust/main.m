
global XX
global YY
%global mali_node
ttime = 300;
R = 250; %  전송반경
noOfNodes  = 93;

%Temp_mal = randperm(noOfNodes);
%mali_node = Temp_mal(1:round(28));

%%%%%%% gps 데이타 불러오기
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
node_data = node_data';  %%%%% 92개노드의 600라운드 행동을 600 x 185행렬로 저장

XX = zeros(600,93);
YY = zeros(600,93);

%--------------------
sink = 93;

for i = 1: 600
    
    node_data(i ,186) = 0;
    node_data(i ,187) = 0;
   
    for k = 1:93
        
        XX(i,k) = node_data(i,2*k);     % XX는 노드데이터에서 x성분만 추출 (600 x 92)
        YY(i,k) = node_data(i,2*k+1);   % YY는 노드데이터에서 y좌표만 추출 (600 x 92)
    end
end
%-------------------




%%%라우팅 반복부 : 1~ 600라운드까지,
%%% s->d는 일단 임의로 정함 

Sum_S_ratio = 0;
S_ratio = 0;
mal_ratio=0;
Sum_mal_ratio = 0;
Count = 0;
Time=600; % 몇회차까지 라우팅을 진행할건지. 최대 600
z=100; %z는 랜덤성을 최소화하기 위한 iteration 숫자
S_ratio_array = zeros(z,Time/60); % z회만큼 array를 누적시킬예정
mal_ratio_array = zeros(z,Time/60); 
alpha = 0.5;
mp = 0;
Result = [];
Result2=[];
h = waitbar(0,'진행 상황'); % 제목 넣어서 waitbar를 띄움.
%-----------------
for mp = 0 : 0.05 :0.5
    
for i = 1: z 
    i
    [SR,GR,d] = MGT_CBA(node_data, alpha, mp);
        for n = 60 : 60 : Time %라운드 반복
            n
            for s = 1:92 % 소스 1부터 92까지 변화를줌, Dest는 93
                [S_ratio,mal_ratio] = Trust_routing2P(SR,GR,noOfNodes,n,s,93);
                
                if S_ratio ~= -1 %%거리문제로 라우팅 실패한 경우 라우팅 성공률에 포함시키지않음
                Sum_S_ratio = Sum_S_ratio + S_ratio; %라우팅 가능하면 S_ratio를 누적
                
      Sum_mal_ratio = Sum_mal_ratio + mal_ratio; %라우팅 가능시 mal_ratio를 누적
         
                Count = Count+1; %카운트도 1증가
                end
              
            end  
            S_ratio_array(i,n/60) = Sum_S_ratio/Count; % 배열에 회차당 평균 성공률 삽입
            mal_ratio_array(i,n/60) = Sum_mal_ratio/Count ;% 배열에 회차당 평균 말리노드포함률 삽입

            Sum_S_ratio = 0; % 한바퀴 다돌면 평균 성공률 0으로 초기화함
       Sum_mal_ratio = 0;        
            Count = 0;
            
                        
        end %100회차까지 끝
        
end
S_ratio_per_round = mean(S_ratio_array, 'omitnan'); % 라운드별 성공률을 z회차만큼 누적시켰기 때문에 다시 평균내어 보여줌
mal_ratio_per_round = mean(mal_ratio_array, 'omitnan');


AVG_ratio = mean(S_ratio_per_round, 'omitnan');
AVG_ratio2 = mean(mal_ratio_per_round, 'omitnan');

Result = [Result AVG_ratio];
Result2 = [Result2 AVG_ratio2];
waitbar(mp/0.5)
end

mp = [0 : 0.05 : 0.5];


figure(1)
subplot(2,1,1)
plot(mp,Result,'b--o')
subplot(2,1,2)
plot(mp,Result2, 'b-*')
legend( 'success data routing ratio ' , 'Malicious node ratio of routing path ')
grid on




