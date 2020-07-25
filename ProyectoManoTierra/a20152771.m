%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tierraOriginal = imread('tierra.jpg'); %%cargamos la imagen
tierraGris = rgb2gray(tierraOriginal); %%Escala de grises
figure,
subplot 121, imshow(tierraOriginal), title("Imagen original 'tierra.jpg' ")
subplot 122, imshow(tierraGris), title("Imagen en escala de grises")

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tierraRojo = tierraOriginal(:, :,1);    % tomamos el plano rojo
tierraVerde = tierraOriginal(:, :,2);    % tomamos el plano verde
tierraAzul = tierraOriginal(:, :,3);    % tomamos el plano azul 

h_Trojo = imhist(tierraRojo); % obtenemos el histograma del plano rojo
h_Tverde= imhist(tierraVerde); % obtenemos el histograma del plano verde
h_Tazul = imhist(tierraAzul); % obtenemos el histograma del plano azul
h_Tgris=  imhist(tierraGris); % obtenemos el histograma de la escala de grises

%Graficamos las imágenes con sus histogramas
figure
subplot 241, imagesc(tierraGris), axis image, title('Escala de grises')
subplot 242, imagesc(tierraRojo), axis image,colormap gray,title('Canal R')
subplot 243, imagesc(tierraVerde),axis image, colormap gray,title('Canal G')
subplot 244, imagesc(tierraAzul), axis image, colormap gray,title('Canal B')
subplot 245, imhist(tierraGris),title('Histograma de la escala de grises'), grid
subplot 246, imhist(tierraRojo),title('Histograma del canal R'), grid
subplot 247, imhist(tierraVerde),title('Histograma del canal G'), grid
subplot 248, imhist(tierraAzul),title('Histograma del canal B'), grid

%Obtenemos la matriz de las máscaras
MascaraGris=zeros(size(tierraGris, 1),size(tierraGris, 2));
MascaraRojo=zeros(size(tierraRojo, 1),size(tierraRojo, 2));
MascaraVerde=zeros(size(tierraVerde, 1),size(tierraVerde, 2));
MascaraAzul=zeros(size(tierraAzul, 1),size(tierraAzul, 2));

%%Para cada caso, utilizamos un valor umbral de 230 para segmentar las imágenes. 
%%Es en ese punto donde las gráficas se reparten aproximadamente.

%%Para la imagen en la escala de grises:
for ind = 1:(size(tierraGris, 1))
    for ind2=1:(size(tierraGris, 2))
      if(tierraGris(ind,ind2)<230)
          MascaraGris(ind,ind2)=1; %Obtenemos la Mascara de la imagen en escala de grises
      end
    end
end

%%Para la imagen en el plano Rojo:
for ind = 1:(size(tierraRojo, 1))
    for ind2=1:(size(tierraRojo, 2))
      if(tierraRojo(ind,ind2)<230)
          MascaraRojo(ind,ind2)=1; %Obtenemos la Mascara de la imagen en el plano Rojo
      end
    end
end

%%Para la imagen en el plano Verde:
for ind = 1:(size(tierraVerde, 1))
    for ind2=1:(size(tierraVerde, 2))
      if(tierraVerde(ind,ind2)<230)
          MascaraVerde(ind,ind2)=1;  %Obtenemos la Mascara de la imagen en el plano Verde
      end
    end
end

%%Para la imagen en el plano Azul:
for ind = 1:(size(tierraAzul, 1))
    for ind2=1:(size(tierraAzul, 2))
      if(tierraAzul(ind,ind2)<230)
          MascaraAzul(ind,ind2)=1;  %Obtenemos la Mascara de la imagen en el plano Azul
      end
    end
end

figure
subplot 221, imagesc(MascaraGris), axis image,colormap gray, title('Máscara con esc. de grises')
subplot 222, imagesc(MascaraRojo), axis image,colormap gray, title('Máscara con el canal R')
subplot 223, imagesc(MascaraVerde),axis image,colormap gray, title('Mascara con el canal G')
subplot 224, imagesc(MascaraAzul), axis image,colormap gray, title('Máscara con el canal B')

%%Para realizar la segmentación se utilza la máscara con el canal R, ya que es la más apropiada.


%%Realizamos el filtro lineal disk de 7x7:
h = fspecial('disk',7);
figure, imagesc(h),colormap gray,axis image,grid on, title("Filtro 'disk'") %%Mostramos el filtro
figure, surf(h),title("Representación como superficie") %Mostramos su representación como superficie
%%Filtramos la máscara:
MascaraFiltrada = imfilter(MascaraRojo,h);
%%Mostramos la mascara filtrada:
figure, imagesc(MascaraFiltrada),colormap gray,axis image, title("Máscara filtrada")


%%Hallamos la mascara invertida (InteriorCirculo=0)
MascaraInvertida=1-MascaraFiltrada;
imagesc(MascaraInvertida),colormap gray,axis image

Mano = imread('mano.jpg'); %%cargamos la imagen

SeccionMano=Mano(40:259,205:420,:); %Guardamos una seccion de la mano
Mano(40:259,205:420,:)=0; %%Borramos una seccion de la imagen original

MascaraInvertida3=repmat(MascaraInvertida,1,1,3); %%Hacemos 3 planos de una misma matriz de la Mascara Invertida
Mascara3=repmat(MascaraFiltrada,1,1,3); %%Hacemos 3 planos de una misma matriz de la Mascara 

SeccionMano2=uint8(double(SeccionMano).*MascaraInvertida3);    %%Borramos el interior del circulo donde estará el planeta

tierraEditada=uint8(double(tierraOriginal).*Mascara3); %%Borramos el esterior del circulo en la imagen del planeta
SeccionMano3=SeccionMano2 + tierraEditada; %%Colocamos la tierra en la sección de la imagen de la mano
figure, imagesc(SeccionMano3),axis image %%Seccion de la mano con el planeta

Mano(40:259,205:420,:)= (SeccionMano3); %%Colocamos la tierra en la mano
figure, imshow(Mano),title("Imagen editada") %%Obtenemos la imagen editada