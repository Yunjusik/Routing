function [sp, spcost] = dijkstra2(matriz_costo, s, d)


n=size(matriz_costo,1);
S(1:n) = 0;     
dist(1:n) = inf;   
prev(1:n) = n+1;    

dist(s) = 0;


for h = 1:n
    candidate=[];
    for i=1:n
        if S(i)==0
            candidate=[candidate dist(i)];
        else
            candidate=[candidate inf];
        end
   
    end
    
    
    [u_index u]=min(candidate);
    S(u)=1;
    for i=1:n
        if  u==s  
           if  matriz_costo(u,i)<dist(i)
               dist(i) = matriz_costo(u,i);
               prev(i)=u;
           end   
        
        
        else
            if u==i
               continue
            end   
           if dist(u) * matriz_costo(u,i)<dist(i)
           dist(i) = dist(u) * matriz_costo(u,i);
           prev(i)=u;
           end
        end
    end
end


sp = [d];

while sp(1) ~= s
   
    if prev(sp(1))<=n
        sp=[prev(sp(1)) sp];
    else   
        sp = 0;
        spcost = -1; 
        return;
    end
    
end
spcost = dist(d);

