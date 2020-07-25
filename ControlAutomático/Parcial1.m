%%%%%%%%%% De Espacio estado a FUNCIÓN DE TRANSFERENCIA S %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
syms s
%{

A=[0 20.6; 1 0];
B=[0;1];
C=[1 0];
D=0;
sImA=[s*eye(2)-A];
sImAinv=simplify(inv(sImA));
G=simplify(C*sImAinv*B+D)
CoefEcCaracA=poly(eig(A));
autovalores=eig(A);
%}

%%%%%%%%%%% RESPUESTA EN EL TIEMPO %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
syms s t
A=[-5 50; 0 -3];
B=[0; 10];
C=[1 0];
D=0;
E=0;
H=0;
w=0;
u=(2/s);
x0=[2; 3];
sImA=[s*eye(2)-A]
sImAinv=simplify(inv(sImA))
Omega=ilaplace(sImAinv) %Se multiplica por x(0) para obtener resp. por c.i.
xtCI=Omega*x0;

xs=sImAinv*(B*u+E*w);  %Resp. por entradas
xtEntradas=ilaplace(xs);

xtTotal=xtCI+xtEntradas;; %Respuesta total

yt=C*xtTotal+ilaplace(D*u);%+ilaplace(H*w) %Resp. a la salida. Verificar 'w'
%}

%%%%%%%%%%%%%% FORMAS CANÓNICAS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
A=[1 1 -1; 2 1 -3; 1 2 0];
B=[ 0; 1 ;2 ];
C=[0 1 2];
D=0;

%Controlable
S=[B A*B (A^2)*B]; %Es controlable si det(S) dif. de cero o rango igual a n.
detS=det(S);
rankS=rank(S);
%autovalores=eig(A1)
CoefEcCaracA=poly(eig(A)); % s^n + an-1*s^(n-1)+..+a0
%Para hallar M
%P=S*M
%C2=C*P  %Ya se sabe los valores de A2, B2 y D2=D;

%Observable
V=[C; C*A; C*A^2]; %Es observable si det(V) dif. de cero o rango igual a n.
detV=det(V);
rankV=rank(V);
%invQ=M*V
%B2=invQ*B %Ya se sabe los valores de A2, C2 y D2=D;
%}

%%%%%%%%%%%%%%%%%%% SISTEMA DE REGULACIÓN O SEGUIMIENTO CON INTEGRADOR %%%%%%%%%%%
%{
A=[-2 0 0; 0.4 -0.2 0; 0 1 0];
B=[1; 0; 0];
C=[0 0 1];
D=0;
S=[B A*B (A^2)*B] %Es controlable si det(S) dif. de cero o rango igual a n.
detS=det(S)

sImA=[s*eye(3)-A]
CoefEcCaracA=poly(eig(A))

EcCaracDeseada=poly([ (-0.81+0.392j) (-0.81-0.392j) -5])

M=[0.4 2.2 1;2.2 1 0; 1 0 0]; %Del CoefEcCaracA
P=S*M;
Pinv=inv(P);
Kx=[4.05 8.51 4.42]; %Del CoefEcCaracA y EcCaracDeseada
K=Kx*Pinv
%}

%%%%%%%%%%%%%%%%%%% SISTEMA DE SEGUIMIENTO SIN INTEGRADOR %%%%%%%%%%%
%{
A=[-5 50; 0 -2];
B=[ 0; 100];
C=[1 0];
D=0;

sA=[A zeros([max(size(A)) 1]);-C 0];
sB=[B;0];

S=[sB sA*sB (sA^2)*sB]; %Es controlable si det(S) dif. de cero o rango igual a n.
detS=det(S);
rankS=rank(S);

sImA=[s*eye(max(size(sA)))-sA];
CoefEcCaracA=poly(eig(sA));

EcCaracDeseada=poly([(-4+4.68j) (-4-4.68j) -20]);
%
M=[10 7 1; 7 1 0; 1 0 0]; %Del CoefEcCaracA
P=S*M;
Pinv=inv(P);
Kx=[758.05 187.9 21]; %Del CoefEcCaracA y EcCaracDeseada
K=Kx*Pinv
%}

%%%%%%%%%%%%%%%%%%% OBSERVADORES DE ORDEN COMPLETO %%%%%%%%%%%%%%%%%%%
%{
A=[-2 0 0; 0.4 -0.2 0; 0 1 0];
B=[1; 0; 0];
C=[0 0 1];
D=0;

V=[C; C*A; C*A^2]
detV=det(V)
rankV=rank(V)

sImA=[s*eye(max(size(A)))-A]
CoefEcCaracA=poly(eig(A))

EcCaracDeseada=poly([ (-5+0.392j) (-5-0.392j) -25] )

Kx=[628.84; 274.75; 32.8];
M=[0.4 2.2 1;2.2 1 0; 1 0 0];
Q=inv(M*V);
K=Q*Kx
%}