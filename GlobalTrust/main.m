
global XX
global YY
%global mali_node
ttime = 300;
R = 250; %  ���۹ݰ�
noOfNodes  = 93;

%Temp_mal = randperm(noOfNodes);
%mali_node = Temp_mal(1:round(28));

%%%%%%% gps ����Ÿ �ҷ�����
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
node_data = node_data';  %%%%% 92������� 600���� �ൿ�� 600 x 185��ķ� ����

XX = zeros(600,93);
YY = zeros(600,93);

%--------------------
sink = 93;

for i = 1: 600
    
    node_data(i ,186) = 0;
    node_data(i ,187) = 0;
   
    for k = 1:93
        
        XX(i,k) = node_data(i,2*k);     % XX�� ��嵥���Ϳ��� x���и� ���� (600 x 92)
        YY(i,k) = node_data(i,2*k+1);   % YY�� ��嵥���Ϳ��� y��ǥ�� ���� (600 x 92)
    end
end
%-------------------




%%%����� �ݺ��� : 1~ 600�������,
%%% s->d�� �ϴ� ���Ƿ� ���� 

Sum_S_ratio = 0;
S_ratio = 0;
mal_ratio=0;
Sum_mal_ratio = 0;
Count = 0;
Time=600; % ��ȸ������ ������� �����Ұ���. �ִ� 600
z=100; %z�� �������� �ּ�ȭ�ϱ� ���� iteration ����
S_ratio_array = zeros(z,Time/60); % zȸ��ŭ array�� ������ų����
mal_ratio_array = zeros(z,Time/60); 
alpha = 0.5;
mp = 0;
Result = [];
Result2=[];
h = waitbar(0,'���� ��Ȳ'); % ���� �־ waitbar�� ���.
%-----------------
for mp = 0 : 0.05 :0.5
    
for i = 1: z 
    i
    [SR,GR,d] = MGT_CBA(node_data, alpha, mp);
        for n = 60 : 60 : Time %���� �ݺ�
            n
            for s = 1:92 % �ҽ� 1���� 92���� ��ȭ����, Dest�� 93
                [S_ratio,mal_ratio] = Trust_routing2P(SR,GR,noOfNodes,n,s,93);
                
                if S_ratio ~= -1 %%�Ÿ������� ����� ������ ��� ����� �������� ���Խ�Ű������
                Sum_S_ratio = Sum_S_ratio + S_ratio; %����� �����ϸ� S_ratio�� ����
                
      Sum_mal_ratio = Sum_mal_ratio + mal_ratio; %����� ���ɽ� mal_ratio�� ����
         
                Count = Count+1; %ī��Ʈ�� 1����
                end
              
            end  
            S_ratio_array(i,n/60) = Sum_S_ratio/Count; % �迭�� ȸ���� ��� ������ ����
            mal_ratio_array(i,n/60) = Sum_mal_ratio/Count ;% �迭�� ȸ���� ��� ����������Է� ����

            Sum_S_ratio = 0; % �ѹ��� �ٵ��� ��� ������ 0���� �ʱ�ȭ��
       Sum_mal_ratio = 0;        
            Count = 0;
            
                        
        end %100ȸ������ ��
        
end
S_ratio_per_round = mean(S_ratio_array, 'omitnan'); % ���庰 �������� zȸ����ŭ �������ױ� ������ �ٽ� ��ճ��� ������
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




