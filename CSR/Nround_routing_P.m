function [S_ratio] = Nround_routing_P(noOfNodes,n,s,d)

R=250;

global XX
global YY
global mali_node

 I_th_Xloc = XX(n,:);
 I_th_Yloc = YY(n,:);

% figure(1);
% clf;
% hold on;
 
 
 for i = 1:noOfNodes

%      plot(I_th_Xloc(i), I_th_Yloc(i), '.');
%      text(I_th_Xloc(i), I_th_Yloc(i), num2str(i));
      
     for j = 1:noOfNodes
           distance = sqrt((I_th_Xloc(i) - I_th_Xloc(j))^2 + (I_th_Yloc(i) - I_th_Yloc(j))^2);
           if distance <= R
               matrix(i, j) = distance;   % �� ��Ʈ������ ���߿� Cost�� �����ؾ���, Cost�� SR(i,j)*GR(j)�� ������ �ؾߵ�
%              line([I_th_Xloc(i) I_th_Xloc(j)], [I_th_Yloc(i) I_th_Yloc(j)], 'LineStyle', ':');                         
           else
               matrix(i, j) = inf;
           end
      end
 end

 [sp, spcost] = dijkstra_P(matrix, s, d); %%% 1�� �ҽ� 15�� ������
 sp;
 spcost;
 
% if length(sp) ~= 0
%     for i = 1:(length(sp)-1)
%         line([I_th_Xloc(sp(i)) I_th_Xloc(sp(i+1))], [I_th_Yloc(sp(i)) I_th_Yloc(sp(i+1))], 'Color','r','LineWidth', 0.50, 'LineStyle', '-.');
%     end;
% end;
 

%%%%%����� ��ο��� mal ��� ���� Ȯ��


no_of_mal = 0; %���� path �� ���Ե� ����������

mal_in_path =[]; %���� path�� �����Ž� ��带 �迭�� ��ȯ

for i = 1:length(mali_node)

   if  find(sp == mali_node(i)) >= 1

      no_of_mal = no_of_mal + 1;
      mal_in_path = [mal_in_path mali_node(i)];

   else
    

   end
end

if sp ~= 0 
S_ratio =  (0.5^(no_of_mal)) * (0.95^(length(sp) - no_of_mal -1 ));
             %�����Ž� ����     % �����Ž� �ƴ� ���� = �ѱ��� - ��������
else 
S_ratio =  -1; % range�� �ȴ�Ƽ� ������ ������� -1�� �������� �ϰ�, ���߿� -1�� S_ratio��,
               % ����� ������ ��� ��꿡 ���ܽ�Ű�� �ȴ�
end
