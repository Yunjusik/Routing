global mali_node
global XX
global YY

%global mali_node
ttime = 300;
R = 120; %  ���۹ݰ�
noOfNodes  = 500;

hold on;
L = 500;
node_data = zeros(600, 2*noOfNodes+1);


matrix = zeros(noOfNodes);
dist = zeros(1,noOfNodes);

% L ������ ���游ŭ �������� ���� ��� �߻�
x = zeros( 1 , noOfNodes);
y = zeros( 1, noOfNodes);
for i = 1 : noOfNodes-1 % ����
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
        XX(i,k) = x(k);     % XX�� ��嵥���Ϳ��� x���и� ���� (600 x node��+��ũ)
        YY(i,k) = y(k);   % YY�� ��嵥���Ϳ��� y��ǥ�� ���� (600 x node��+��ũ)
    end
end
%-------------------
%alpha = 0.5;
%mp = 0.3;

%[SR,GR,d] = MGT_ex(noOfNodes-1, node_data, alpha, mp);
%[mal_ratio,S_ratio,mat] = Trust_routing22(SR,GR,noOfNodes,1,5,sink);

%0----------


%%%����� �ݺ��� : 1~ 600�������,
%%% s->d�� �ϴ� ���Ƿ� ���� 
mp = 0;
alpha = 0.5;
Sum_S_ratio = 0;
S_ratio = 0;
mal_ratio = 0;
Sum_mal_ratio = 0;
Count = 0;
Count2=0;
Count3=0;

Time=600; % ��ȸ������ ������� �����Ұ���. �ִ� 600
z=5; %z�� �������� �ּ�ȭ�ϱ� ���� iteration ����

SR_per_Iteration = zeros(1,z);
MR_per_Iteration = zeros(1,z);
Result = [];
Result2 = [];


h = waitbar(0,'���� ��Ȳ'); % ���� �־ waitbar�� ���.


%-----------------
for mp = 0.1 : 0.05 :0.5    
    for i = 1: z 
        
        %[SR,GR,d] = MGT_ex(noOfNodes-1,node_data, alpha, mp);
        %[T__mat,T_mat] = Active_BLA(noOfNodes-1, node_data, mp);
        [T__mat,T_mat] = Active_CBA(noOfNodes-1, node_data, mp);
        
        for s = 1:noOfNodes-1 % �ҽ� 1���� n-1���� ��ȭ����, Dest�� n
              %���ο� s�� �����Ǹ�, ������ cost matrix�� ����
             C = T__mat; % cost matrix�� C��� ���������� ����
                         % s�� �ٲ𶧸��� C�� �ٽ� cost matrix�������� �ٲ�
             
             if (find(s == mali_node) >=1)
             else
               
                for n = 60 : 60 : Time %10���尣 
                   mp, n, i
                    [mal_ratio,S_ratio,sp] = Active_R2(C,noOfNodes,n,s);
                    if length(sp) ~= 2
   
                    Count2= Count2 +1;   %����� ������ �� ī��Ʈ    
                    %Active Trust������ �ѹ� ��ģ ���� �ٽ� ��ġ�� ����.
                                   mal_ratio    
                                       
                    if S_ratio ~= -1  %routing�� ������ ���
                       Sum_S_ratio = Sum_S_ratio + S_ratio; %����� �����ϸ� S_ratio�� ����
                       Sum_mal_ratio = Sum_mal_ratio + mal_ratio; %����� ���ɽ� mal_ratio�� ����
                       Count = Count+1; % ������������ ���� ī��Ʈ
                       
                       
                       if length(sp) >=3 %������� �������̰�, ������尡 �ִٸ�,
                           for a = 2:length(sp)-1
                               C(:,sp(a),:) =0;
                           end                   
                       end
                    end
                    end
                end
             end
        end %source 1~ 499���� �ѹ��� ��(�� 10�����)
        %�̶� ī��Ʈ�� Ƚ����ŭ �����Ǿ�����
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
                
 %Active CBA, iteration 5ȸ