N=10;         % number of nodes
e_num=20;         % number of edges in the network
s=1;              % Initialization of source node
w=[7 1 3 2 4 8 2 1 3 4 7 6 5 2 2 3 4 2 1 5];  
m=[1 1 3 2 3 2 4 4 3 6 6 6 6 5 7 7 7 8 9 10];  
n=[2 3 2 5 5 4 2 5 6 5 7 9 8 7 4 10 9 9 10 4];  
names={'A','B','C','D','E','F','G','H','L','M'};
G=digraph(m,n,w)
h=plot(G,'EdgeLabel',G.Edges.Weight,'Nodelabel',names,'EdgeColor','k','NodeColor','b')
h.MarkerSize=8;
S=sparse(m',n',w');
distance(1:N)=Inf;   % distance of each node initialized to infinity 
distance(s)=0;             % distance of source node intitalized to 0
predecessor(1:N)=0;
for i = 1 : N - 1
    for j = 1 : e_num
      v = n(j);
      u = m(j);
      t = distance(u) + w(j);
      if (t < distance(v) )
        distance(v) = t;
        predecessor(v) = u
      end
    end
  end
% For checking negative weight cycles
for j = 1 : e_num
    u = m(j);
    v = n(j);
    if ( distance(u) + w(j) < distance(v) )
      fprintf ( 1, '\n' );
      fprintf ( 1, 'BELLMAN_FORD - Fatal error!\n' );
      fprintf ( 1, '  Graph contains a cycle with negative weight.\n' );
      error ( 'BELLMAN_FORD - Fatal error!' );
    end
  end
for i=1:(N-1)
d=input('Please enter the destination node:');
totalCost = distance(d)
TR=shortestpathtree(G,1,d);
p=plot(G,'EdgeLabel',G.Edges.Weight,'Nodelabel',names,'EdgeColor','k','NodeColor','b')
p.MarkerSize=8;
highlight(p,TR,'EdgeColor','g','LineWidth',5);
end
