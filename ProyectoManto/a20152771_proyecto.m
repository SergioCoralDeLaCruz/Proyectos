%Cargamos la imagen
manto = imread('manto.jpg');
%Obtenemos plano rojo, verde y azul
mantoR = manto(:,:,1);
mantoG = manto(:,:,2);
mantoB = manto(:,:,3);
%Hacemos un filtro pasabajo
%Butterworth 2D
[h,w] = size(mantoR);% Dimensiones de imagen en 2D 
% Vectores que representan valores para los ejes U e V 
[u,v] = meshgrid(-floor(w/2):floor(w/2)-1,-floor(h/2):floor(h/2)-1); 
B = sqrt(2) - 1; % Constante para Butterworth 
D = sqrt(u.^2 + v.^2); % Distancia al centro de la imagen
D0 = 50; % D0 indica la distancia de corte 
N = 5; % Orden del filtro 
h_lp = 1 ./ (1 + B * ((D ./ D0).^(2 * N))); % Filtro pasabajo

%Filtramos la imagen en el plano rojo
f0R = fftshift(fft2(mantoR));
imfilBajoR=f0R.*h_lp;
%Filtramos la imagen en el plano verde
f0G = fftshift(fft2(mantoG));
imfilBajoG=f0G.*h_lp;
%Filtramos la imagen en el plano azul
f0B = fftshift(fft2(mantoB));
imfilBajoB=f0B.*h_lp;


%Mostramos el filtro y la imagen en el plano rojo
figure,
subplot 221,imshow(log10(abs(f0R)),[]),axis image,colormap gray, title('Magnitud de FFT2 de plano rojo')
subplot 222,imshow(h_lp,[]),axis image,colormap gray, title('Filtro pasabajo en frecuencia')
subplot 223,imshow(log10(1+abs(imfilBajoR)),[]),axis image,colormap gray, title('Plano rojo filtrado en frecuencia')
subplot 224,imshow(real(abs((ifft2(imfilBajoR)))),[]), colormap gray, title('Plano rojo filtrado en el espacio')

%Mostramos el filtro y la imagen en el plano verde
figure,
subplot 221,imshow(log10(abs(f0G)),[]),axis image,colormap gray, title('Magnitud de FFT2 de plano verde')
subplot 222,imshow(h_lp,[]),axis image,colormap gray, title('Filtro pasabajo en frecuencia')
subplot 223,imshow(log10(1+abs(imfilBajoG)),[]),axis image,colormap gray, title('Plano verde filtrado en frecuencia')
subplot 224,imshow(real(abs((ifft2(imfilBajoG)))),[]), colormap gray, title('Plano verde filtrado en el espacio')

%Mostramos el filtro y la imagen en el plano azul
figure,
subplot 221,imshow(log10(abs(f0B)),[]),axis image,colormap gray, title('Magnitud de FFT2 de plano azul')
subplot 222,imshow(h_lp,[]),axis image,colormap gray, title('Filtro pasabajo en frecuencia')
subplot 223,imshow(log10(1+abs(imfilBajoB)),[]),axis image,colormap gray, title('Plano azul filtrado en frecuencia')
subplot 224,imshow(real(abs((ifft2(imfilBajoB)))),[]), colormap gray, title('Plano azul filtrado en el espacio')
%Se puede observar que la imagen con el filtro pasabajo remarca la forma de
%onda de las lineas del manto. Además, la imagen se ve mas borrosa, ya que
%se eliminaron los cambios bruscos que provenian de las altas frecuencias.

%Convertimos de rgb a hsv, y obtenemos cada plano
hsv = rgb2hsv(manto);
hsvH=hsv(:,:,1);
hsvS=hsv(:,:,2);
hsvV=hsv(:,:,3);
%Mostramos los planos RGB y HSV
figure,
subplot 231, imshow(mantoR,[]), title('R')
subplot 232, imshow(mantoG,[]), title('G')
subplot 233, imshow(mantoB,[]), title('B')
subplot 234, imshow(255*hsvH,[]), title('H')
subplot 235, imshow(255*hsvS,[]), title('S')
subplot 236, imshow(255*hsvV,[]), title('V')
%El formato RGB te otorga la intensidad de cada color primario, mientras
%que el formato HSV te otorga las tonalidades, las saturaciones y los brillos de la
%imagen.

%Se grafica el histograma del plano Hue y Saturación de la imagen
histH=imhist(uint8(255*hsvH));
histS=imhist(uint8(255*hsvS));
figure, 
subplot 211,plot(histH,'.-r'), title('Histograma de Hue');
subplot 212,plot(histS,'.-r'), title('Histograma de Saturación');
%Se puede observar que las tonalidades que predominan en la imagen son los
%rojos y los amarillos. Y que la saturación de la imagen va de 100 a 220.

%Se obtienen las máscaras a partir del plano Hue y Saturacion
maskH = (hsvH > 0.0627) .* (hsvH < 0.0784);
maskS = (hsvS > 0.7059);
mask=maskH.*maskS;
%Aplicamos un filtro gaussiano
H = fspecial('gaussian',10);
imfil = imfilter(mask,H);
imUmb=imfil>0.85;

%Se observo que el filtro y la umbralizacion no es suficiente, por lo cual
%se optó realizar una apertura y un cierre
matriz = ones(5);
imOpen = imopen(imUmb,matriz);
imClose = imclose(imOpen,matriz);

%Se identifican cada región
L = bwlabel(imClose);
info = regionprops(L, 'BoundingBox');
n_blobs = length(info);

%Se dibujan las imágenes de las máscaras y la imagen final con los bounding
%box
figure,
subplot 221, imshow(255*mask,[]), title('Máscara original')
subplot 222, imshow(imfil), title('Máscara filtrada')
subplot 223, imshow(imClose), title('umbralizada')
subplot 224, imshow(manto), title('Final'), hold on
for ind = 1:n_blobs
rectangle('Position', info(ind).BoundingBox,'EdgeColor','g','LineWidth', 2);
end
%El método presentado permite identificar tonalidades de colores de manera 
%eficaz. Para ello, es necesario convertir la imagen al formato HSV, ya que
%así es mas facil realizar una máscara de una tonalidad específica. %
%En este caso fue necesario utilizar morfología, ya que los colores de la 
%imagen eran parecidos y quedaban manchas en la máscara.