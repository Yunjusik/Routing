function [mal_ratio,S_ratio,sp] = SP_Routing(noOfNodes,n,s,d)
% �� ������ GR�ȵǴ³� �ϴܰŸ���,
% ���� path�� ������ GR�ȵǴ³� ��¿�� �������Խ��Ѽ� ������� ����

%GR, SR�� ����Ǿ��ִٰ� ����.
%SR = (92 x 92 x 10) �� 10����, 1����� ��� �����Ϳ��� 60ȸ
%GR = (92 x 1 x 10)
%CSR = (92 x 92 x 10)
R=120;
global XX
global YY
global mali_node
I_th_Xloc = XX(n,:);
I_th_Yloc = YY(n,:);

    
    
    %����� ��Ʈ������ �ٽø���
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
   %for������ �ٽ� matrix�����߰�, �ٽ� ����� ����
   [sp, spcost] = dijkstra_P(matrix, s, d);
 sp

 
%%%%%����� ��ο��� mal ��� ���� Ȯ��





no_of_mal =0;

if sp ~= 0  % ��ΰ� �����Ѵٸ�

   for i = 2:length(sp)  %�ҽ����� ������ mal �˻�

       if (find(mali_node == sp(i)) >= 1)

      no_of_mal = no_of_mal +1;  %�ᱹ no_of_mal �� S,D ������ mal�� ī��Ʈ�Ѵ�.
        else
        
        end
   end
   
    if length(sp) == 2 %1ȩ�ΰ��� mal_ratio 
% ��ξ��� ��ȩ���� ������ mal_ratio�� 0������. 
      mal_ratio = 0; 
      S_ratio = (0^(no_of_mal)) * (0.95^(length(sp) - no_of_mal -1 ))
      
    else 

        mal_ratio = no_of_mal/(length(sp)-2);

        S_ratio = (0^(no_of_mal)) * (0.95^(length(sp) - no_of_mal -1 ))

    end
    
else  %��ΰ� �������� �ʴ´ٸ�

S_ratio = -1;
mal_ratio = -1;

end