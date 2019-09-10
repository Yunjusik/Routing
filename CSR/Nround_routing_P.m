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
               matrix(i, j) = distance;   % 이 매트릭스에 나중에 Cost를 삽입해야함, Cost는 SR(i,j)*GR(j)의 역수로 해야됨
%              line([I_th_Xloc(i) I_th_Xloc(j)], [I_th_Yloc(i) I_th_Yloc(j)], 'LineStyle', ':');                         
           else
               matrix(i, j) = inf;
           end
      end
 end

 [sp, spcost] = dijkstra_P(matrix, s, d); %%% 1은 소스 15는 목적지
 sp;
 spcost;
 
% if length(sp) ~= 0
%     for i = 1:(length(sp)-1)
%         line([I_th_Xloc(sp(i)) I_th_Xloc(sp(i+1))], [I_th_Yloc(sp(i)) I_th_Yloc(sp(i+1))], 'Color','r','LineWidth', 0.50, 'LineStyle', '-.');
%     end;
% end;
 

%%%%%라우팅 경로에서 mal 노드 갯수 확인


no_of_mal = 0; %현재 path 에 포함된 말리노드숫자

mal_in_path =[]; %현재 path의 말리셔스 노드를 배열로 반환

for i = 1:length(mali_node)

   if  find(sp == mali_node(i)) >= 1

      no_of_mal = no_of_mal + 1;
      mal_in_path = [mal_in_path mali_node(i)];

   else
    

   end
end

if sp ~= 0 
S_ratio =  (0.5^(no_of_mal)) * (0.95^(length(sp) - no_of_mal -1 ));
             %말리셔스 노드수     % 말리셔스 아닌 노드수 = 총길이 - 말리노드수
else 
S_ratio =  -1; % range가 안닿아서 실패한 라우팅은 -1의 성공률로 하고, 나중에 -1인 S_ratio를,
               % 라우팅 성공률 평균 계산에 제외시키면 된다
end
