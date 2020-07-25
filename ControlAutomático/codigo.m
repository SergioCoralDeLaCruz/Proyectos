syms z
%%% F(s)--->F(t)----->F(kT)------>F(z) %%%
%{
syms a s t k z T
Xs=(1)/(s^2);
Xt=ilaplace(Xs);
Xk=subs(Xt,t,k*T);
Xz=ztrans(Xk,k,z)
%pretty(simplify(Xs))
%}

%%% TeoremaValorFinal (1), inicial(inf) %%%
%{
syms a s t k z T
xz=1/(1-z^-1) -1/(1-exp(-a*T)*z^-1);
xinf=limit((1-z^-1)*xz,z,1)
%}

%%% Transformada z inversa %%%%
%{
syms a s t k z T;
Fz=1/(z-2) - 1/(z-1);
fk=iztrans(Fz,k)
%}

%%%%%%% Método de serie de potencias %%%
%{
b=[10 10];
a=[1 -1];
n=10;
c = power_series(b,a,n)
c=filter(b,a,[1 0 0 0 0 0 0 0 0]);
%}



%%%%%%% De FT-s A Transformada Z Lazo Abierto Con Gzoh %%%%%%%
syms w x k z
%{
num=[1];
den=[1 1 0]; %%% s^2+s^1+s^0
Ts=0.1;
[numd,dend]=c2dm(num,den,Ts,'zoh') %%% z^2+z^1+z^0
%}

%%Otra forma:
%{
num=[0.08];
den=[1 0.5]; %%% s^2+s^1+s^0
Ts=1;
sys=tf(num,den)
sysd=c2d(sys,Ts,'zoh')
%}


%%%%%%% De T-z a T-w %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
denominador=vpa(poly2sym(dend),6);
numerador=vpa(poly2sym(numd),6);
div=vpa(k*(numerador/denominador),5);
div=vpa(simplify(1+div),5);
Z=(1+(Ts/2)*w)/(1-(Ts/2)*w);
%%Plano W:
W=(vpa(simplify(subs(div,x,Z)),5))
%simplify(1 - (k*((697145410053851*(w/20 + 1))/(144115188075855872*(w/20 - 1)) - 5394335437594579/1152921504606846976))/((8578625086068125*(w/20 + 1))/(4503599627370496*(w/20 - 1)) + (w/20 + 1)^2/(w/20 - 1)^2 + 4075025458697629/4503599627370496))
%}


%%%%%%% Hallar Lugar de las raices Lazo Abierto en Z %%%%%%%
%{
Ts=0.1
num=[1];
den=[1 1 0]; %%% s^2+s^1+s^0
[numd,dend]=c2dm(num,den,Ts,'zoh') %%% z^2+z^1+z^0
%numd=[0.632 0] %z^1+z^0
%dend=[1 -1.368 0.368]
sysd=tf(numd,dend,Ts)
rlocus(sysd)
grid on
%}




%%%%%%% DBode Lazo Abierto %%%%%%%
%{
num=[100];
den=[1 11 10]; %%% s^2+s^1+s^0
Ts=0.02;
[numd,dend]=c2dm(num,den,Ts,'zoh') %%% z^2+z^1+z^0
%}
%{
numd=conv(numd,[0.6335 -0.6265]);
dend=conv(dend,[1 -1]); %%% s^2+s^1+s^0
dbode(numd,dend,Ts)
grid on
%}

%{
u=[2.479 -0.479];
v=[1 -1];
c=conv(u,v)
%}


%%%%%%%%%%% Espacio-Estado continuo a discreto %%%%%%%%%%%%
%{
syms T
A=[-5 50; 0 -3];
B=[0; 10];
C=[1 0];
D=0;
Ts=0.04;
[Phi_o, Gamma_r,Cd,Dd]=c2dm(A,B,C,D,Ts,'zoh')
%}

%%%%%%%% De Espacio-Estado discreto A FT-Z (Si no dan Esp-Est en t, sino irse a Parcial1)%%%%%%
%%% Para conocer si tiene integrador %%%%%%%%5
%{
syms z
Phi_o=[1 0.6321;0 0.3679];
Gamma_r=[0.3679; 0.6321];
C=[1 0];
D=0;
zImPhi_o=[z*eye(2)-Phi_o];
zImPhi_o_inv=simplify(inv(zImPhi_o));
G=simplify(C*zImPhi_o_inv*Gamma_r+D)
%}


%%%%%%%%%%%%%%%%%%% SISTEMA DE REGULACIÓN O SEGUIMIENTO CON INTEGRADOR - ACKERMANN %%%%%%%%%%%
%{
%{
Phi_o=[-2 0 0; 0.4 -0.2 0; 0 1 0];
Gamma_r=[1; 0; 0];
Cd=[0 0 1];
Dd=0;
%}

S=[Gamma_r Phi_o*Gamma_r] %Es controlable si det(S) dif. de cero o rango igual a n.
detS=det(S)
rankS=rank(S)

a1=exp(0.1*(-0.36+2.4j))
a2=exp(0.1*(-0.36-2.4j))
%a3=exp(0.02*(-20))
EcCaracDeseada=poly([a1 a2]) %OJO EN a3
EcCaracDeseada_Phi_o= 1*Phi_o^2-1.873983498265129*Phi_o + 0.930530895811206*eye(2)
G=[0 1]*inv(S)*EcCaracDeseada_Phi_o
%}

%%%%%%%%%%%%%%%%%%% SISTEMA DE REGULACIÓN O SEGUIMIENTO CON INTEGRADOR - MÉTODO COMÚN %%%%%%%%%%%
%{

S=[Gamma_r Phi_o*Gamma_r (Phi_o^2)*Gamma_r] %Es controlable si det(S) dif. de cero o rango igual a n.
detS=det(S)
rankS=rank(S)

zImPhi_o=[z*eye(3)-Phi_o]
CoefEcCaracA=poly(eig(Phi_o))

a1=exp(0.1*(-2.24+1.5j));
a2=exp(0.1*(-2.24-1.5j));
a3=exp(0.1*(-10));
EcCaracDeseada=poly([(a1) (a2) 0.4066]);

M=[2.1817 -2.5752 1;-2.5752 1 0; 1 0 0]; %Del CoefEcCarac
P=S*M;
Pinv=inv(P);
Gx=[0.3468 -0.9004 0.5882]; %Del CoefEcCarac y EcCaracDeseada
G=Gx*Pinv
%}

%%%%%%%%%%%%%%%%%%% SISTEMA DE SEGUIMIENTO SIN INTEGRADOR - ACKERMANN %%%%%%%%%%%
%{
%{
Phi_o=[-2 0 0; 0.4 -0.2 0; 0 1 0];
Gamma_r=[1; 0; 0];
Cd=[0 0 1];
Dd=0;
%}

Phi_o_prima=[Phi_o Gamma_r; 0 0 0] %Si es de grado 3, entonces 4 ceros
Gamma_r_prima=[0; 0; 1]

S=[Gamma_r Phi_o*Gamma_r] %Es controlable si det(S) dif. de cero o rango igual a n.
detS=det(S)
rankS=rank(S)

a1=exp(0.04*(-2.4+3.2j))
a2=exp(0.04*(-2.4-3.2j))
a3=exp(0.04*(-12))
EcCaracDeseada=poly([a1 a2 a3]) %OJO EN a3
EcCaracDeseada_Phi_o_prima= 1*Phi_o_prima^3 -2.420847460405045*Phi_o_prima^2 + 1.940394185111286*Phi_o_prima -0.510686183366188*eye(3)
G_prima=[0 0 1]*inv([Gamma_r_prima Phi_o_prima*Gamma_r_prima (Phi_o_prima^2)*Gamma_r_prima ])*EcCaracDeseada_Phi_o_prima
G=(G_prima+[0 0 1])*inv([ Phi_o-eye(2)  Gamma_r ; C*Phi_o  C*Gamma_r])
%}


%%%%%%%%%%%%%%%%%%% OBSERVADOR DE ORDEN COMPLETO (OOC) - MÉTODO COMÚN %%%%%%%%%%%
%{

V=[C; C*Phi_o] %Es controlable si det(S) dif. de cero o rango igual a n.
detV=det(V)
rankV=rank(V)

zImPhi_o=[z*eye(2)-Phi_o]
CoefEcCaracA=poly(eig(Phi_o))

a1=exp(0.1*(-1.8+2.4j));
a2=exp(0.1*(-1.8-2.4j));
%a3=exp(0.1*(-10));
EcCaracDeseada=poly([(a1) (a2)])

M=[-2.209561  1;1 0]; %Del CoefEcCarac
Q=inv(M*V);
Gx=[-0.302324;0.586902]; %Del CoefEcCarac y EcCaracDeseada
G=Q*Gx
%}


%%%%%%%%%%%%%%%%%%% OBSERVADOR DE ORDEN COMPLETO (OOC) - ACKERMANN %%%%%%%%%%%
%{

V=[C; C*Phi_o] %Es controlable si det(S) dif. de cero o rango igual a n.
detV=det(V)
rankV=rank(V)


a1=exp(0.04*(-12+3.2j))
a2=exp(0.04*(-12-3.2j))
EcCaracDeseada=poly([(a1) (a2)])
EcCaracDeseada_Phi_o=1*Phi_o^3-1.379444725612230*Phi_o^2+0.540853067607839*Phi_o-0.042852126867040*eye(2)
G=EcCaracDeseada_Phi_o*inv(V)*[0;1]
%}