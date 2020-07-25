clc
clear all
close all
A=imread('persona_enferma.jpg');%Leemos la imagen de la persona
figure,imshow(A), title('Imagen en RGB'); %Grafica normal de temperatura
A2=rgb2hsv(A);%Convertimos a formato HSV
figure,imshow(A2), title('Imagen en HSV');%Grafica en HSV
A5=A2(:,:,2);%Trabajamos la capa de saturación
figure,imshow(A5),title('Capa de Saturación ')
A5eq=histeq(A5);%Ecualizamos la capa de Saturacion
A2(:,:,2)=A5eq;%Reemplazamos la capa ecualizada
figure,imshow(A2),title('Despues de ecualizar en HSV')
Argb=hsv2rgb(A2);%Convertimos a rgv
figure,imshow(Argb),title('Despues de ecualizar en HSV rgb')
A_gray=rgb2gray(Argb);%Convertimos a escala de grises
figure,imshow(A_gray),title('Capa gris')
A_beq=uint8(histeq(A_gray)*255);%Transformamos a uint8
figure,imshow(A_beq);
Abw=(A_beq>150);%Umbralizamos para diferenciar pacientes sanos y enfermos
figure,imshow(Abw)
se3 = strel('disk', 12);%Kernel para closing
Abw2=imclose(Abw,se3);% Aplicamos close para acercar objetos
figure,imshow(Abw2)
BW2=bwareafilt(Abw2,1);%Nos quedamos con el mas grande
figure,imshow(BW2);
BW2=bwareafilt(BW2,1);%Nos quedamos con el mas grande
figure,imshow(BW2);
Im = BW2==0; %Negamos el BW2 
im2 = bwareafilt(Im,2);%Seleccion de fondo
figure,imshow(im2);
im3 = im2~=BW2; %% Se muestran cuerpos especificos que no sean el fondo
figure,imshow(im3);
im3 = im3==0;%% Negacion a la imagen para aplicar regionprops
figure,imshow(im3);
inf = regionprops (im3,'Area','BoundingBox','Centroid');
cant = length(inf); %% Indicador de enfermedad
if cant>0 
    figure,imshow(A), title('Paciente sano');
    disp('Paciente sano')
else
    figure,imshow(A), title('Consultar un medico');
    disp ('Consultar un medico')
end


