function [mal_ratio,S_ratio,sp] = SP_Routing(noOfNodes,n,s,d)
% 이 버전은 GR안되는놈 일단거르고,
% 만약 path가 없을시 GR안되는놈 어쩔수 없이포함시켜서 라우팅을 진행

%GR, SR이 저장되어있다고 가정.
%SR = (92 x 92 x 10) 총 10라운드, 1라운드는 노드 데이터에서 60회
%GR = (92 x 1 x 10)
%CSR = (92 x 92 x 10)
R=120;
global XX
global YY
global mali_node
I_th_Xloc = XX(n,:);
I_th_Yloc = YY(n,:);

    
    
    %라우팅 매트릭스를 다시만듬
   for i = 1:noOfNodes
      for j = 1:noOfNodes
             distance = sqrt((I_th_Xloc(i) - I_th_Xloc(j))^2 + (I_th_Yloc(i) - I_th_Yloc(j))^2);
                 if distance <= R 
                     %matrix(i, j) = 1/ ( CSR(i,j) * GR(i, 1 , ceil(n/60)));
                     matrix(i,j) = distance;
                     %matrix(i,j) = 1 / GR(i,1,ceil(n/60)) ;
                 else
                     matrix(i, j) = inf;
                 end
      end
   end
   %for문으로 다시 matrix복구했고, 다시 라웅팅 시전
   [sp, spcost] = dijkstra_P(matrix, s, d);
 sp

 
%%%%%라우팅 경로에서 mal 노드 갯수 확인





no_of_mal =0;

if sp ~= 0  % 경로가 존재한다면

   for i = 2:length(sp)  %소스다음 노드부터 mal 검사

       if (find(mali_node == sp(i)) >= 1)

      no_of_mal = no_of_mal +1;  %결국 no_of_mal 은 S,D 제외한 mal을 카운트한다.
        else
        
        end
   end
   
    if length(sp) == 2 %1홉인경우는 mal_ratio 
% 경로없이 한홉으로 갈때는 mal_ratio를 0으로함. 
      mal_ratio = 0; 
      S_ratio = (0^(no_of_mal)) * (0.95^(length(sp) - no_of_mal -1 ))
      
    else 

        mal_ratio = no_of_mal/(length(sp)-2);

        S_ratio = (0^(no_of_mal)) * (0.95^(length(sp) - no_of_mal -1 ))

    end
    
else  %경로가 존재하지 않는다면

S_ratio = -1;
mal_ratio = -1;

end