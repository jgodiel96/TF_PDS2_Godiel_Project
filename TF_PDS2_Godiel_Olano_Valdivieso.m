

function varargout = TF_PDS2_Godiel_Olano_Valdivieso(varargin)
% TF_PDS2_GODIEL_OLANO_VALDIVIESO MATLAB code for TF_PDS2_Godiel_Olano_Valdivieso.fig
%      TF_PDS2_GODIEL_OLANO_VALDIVIESO, by itself, creates a new TF_PDS2_GODIEL_OLANO_VALDIVIESO or raises the existing
%      singleton*.
%
%      H = TF_PDS2_GODIEL_OLANO_VALDIVIESO returns the handle to a new TF_PDS2_GODIEL_OLANO_VALDIVIESO or the handle to
%      the existing singleton*.
%
%      TF_PDS2_GODIEL_OLANO_VALDIVIESO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TF_PDS2_GODIEL_OLANO_VALDIVIESO.M with the given input arguments.
%
%      TF_PDS2_GODIEL_OLANO_VALDIVIESO('Property','Value',...) creates a new TF_PDS2_GODIEL_OLANO_VALDIVIESO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TF_PDS2_Godiel_Olano_Valdivieso_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TF_PDS2_Godiel_Olano_Valdivieso_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TF_PDS2_Godiel_Olano_Valdivieso

% Last Modified by GUIDE v2.5 09-Jul-2021 03:03:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TF_PDS2_Godiel_Olano_Valdivieso_OpeningFcn, ...
                   'gui_OutputFcn',  @TF_PDS2_Godiel_Olano_Valdivieso_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before TF_PDS2_Godiel_Olano_Valdivieso is made visible.
function TF_PDS2_Godiel_Olano_Valdivieso_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TF_PDS2_Godiel_Olano_Valdivieso (see VARARGIN)

% Choose default command line output for TF_PDS2_Godiel_Olano_Valdivieso
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TF_PDS2_Godiel_Olano_Valdivieso wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = TF_PDS2_Godiel_Olano_Valdivieso_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global trainedClassifierSVM
global validationAccuracy


closepreview;

vid=videoinput('winvideo',1); % se escoge la camara web
preview(vid);
pause(5);
I = getsnapshot(vid); %captura de foto
axes(handles.axes1)%imagen tomada
imshow(uint8(I)); % se muestra la foto tomada
impixelinfo;
title('Imagen capturada');
%Foto en escala de grises sin recuantizar y tamano de la imagen
Igray=rgb2gray(I);
[M,N]=size(Igray); % determina el tamaño de la imagen.

%-------------------Recuantizacion de imagenes en escala de grises------
r=1; %Para hacer procesamiento, los valores de las imágenes tiene que %ser convertidas a datos tipo double.
Igray=double(Igray);
fe=max(max(Igray));
Irecuan=round(Igray*((2^r)-1)/fe);
Irecuan=round(Irecuan*fe/((2^r)-1));
axes(handles.axes2)
imshow(uint8(Irecuan));
impixelinfo;
title('Recuantizacion de imagen escala de grises a r=1');
[Iobjeto,numobjeto] = bwlabel(Irecuan,8); % obtencion de numeros de objetos preliminar

% Variables de calculo de fosforos
AMIN=2000; % tamaño minimo de un palo entero
prom=2200; %tamaño promedio de un palo entero
A=round(prom*1.5);  %Tamaño minimo para detectar un monton de palos
mayores=0;
menores=0;
vectormayor=[];
vectormenor=[];

for i=1:numobjeto
    ip=find(Iobjeto==i);
    Ap=length(ip);
    if Ap<AMIN && Ap>50  %Ap= tamaño palo analizado
         menores=menores+1;
         vectormenor=[vectormenor,Ap];
     end;   
     if Ap>A
         mayores=mayores+1;
         vectormayor=[vectormayor,Ap];
     end;
end;    
disp(strcat('se han detectado : ',num2str(mayores),'montones de palos'));
disp(strcat('se han detectado : ',num2str(menores),'palos cortados'));
cuentapalosmayores=0;
listamayores=[];
for j=1:length(vectormayor)
    cantidadmayores=vectormayor(j)/prom; % Tamaño promedio de un palo
    listamayores=[listamayores,cantidadmayores];
end;
sumamayores=sum(listamayores);
totalamontonados=round(sumamayores);
aux1=numobjeto-length(vectormayor)+totalamontonados;
disp(strcat('se han detectado : ',num2str(aux1),' palos en total'));

imshow(uint8(Irecuan));
[V,K]=bwlabel(Irecuan,8);
helper=0;
for i=1:K
 ip=find(V==i);
 AParea=length(ip);

 if AParea>300
    if helper==0
        ip1=ip;
        helper=helper+1;
    elseif helper==1
        ip2=ip;
        helper=helper+1;
    elseif helper==2
        ip3=ip;
        helper=helper+1;
    end
 end
end
helper=0;
%SEPARAR OBJETOS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Func1=zeros(M,N);
Func1(ip1)=255;
Func2=zeros(M,N);
Func2(ip2)=255;
Func3=zeros(M,N);
Func3(ip3)=255;
[x1,y1]=find(Func1==255);
[x2,y2]=find(Func2==255);
[x3,y3]=find(Func3==255);
%SEPARAR OBEJETOS cortaobjetos

Areaobj1=Func1(min(x1-10):max(x1+10),min(y1-10):max(y1+10));
Areaobj2=Func2(min(x2-10):max(x2+10),min(y2-10):max(y2+10));
Areaobj3=Func3(min(x3-10):max(x3+10),min(y3-10):max(y3+10));

%GRAFICAR OBJETOS SEPARADOS esto se mete al boton de mostrar procesos de la
%guide
axes(handles.axes3)
imshow(uint8(Areaobj1));
impixelinfo;
axes(handles.axes4)
imshow(uint8(Areaobj2));
impixelinfo;
axes(handles.axes5)
imshow(uint8(Areaobj3));
impixelinfo;
%DATOS del objeto
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

BW1=im2bw(Areaobj1,0.5);
dato1=regionprops(BW1,'Perimeter','Area','Eccentricity','Orientation','Extent','MinorAxisLength','MajorAxisLength');%'Extrema'
BW2=im2bw(Areaobj2,0.5);
dato2=regionprops(BW2,'Perimeter','Area','Eccentricity','Orientation','Extent','MinorAxisLength','MajorAxisLength');%'Extrema'
BW3=im2bw(Areaobj3,0.5);
dato3=regionprops(BW3,'Perimeter','Area','Eccentricity','Orientation','Extent','MinorAxisLength','MajorAxisLength');%'Extrema'

[M1,N1,P1]=size(BW1);
SEP_A=zeros(M1,N1);
SEP_A(1:(M1-115),:)=1;
SEP_B=zeros(M1,N1);
SEP_B((M1-115):M1,:)=1;
GAA=SEP_B.*BW1;
GAA2=SEP_A.*BW1;
BAJON=regionprops(GAA,'Area');
ALTON=regionprops(GAA2,'Area');
BajoLetra=BAJON(1).Area;
AltoLetra=ALTON(1).Area;
Area=dato1(1).Area;
EjePrincipal=dato1(1).MinorAxisLength;
EjeMenor=dato1(1).MajorAxisLength;
Perimetro=max(dato1.Perimeter);
disp(strcat('Perimetro 1 : ',num2str(Perimetro)));
disp(strcat('Area 1 : ',num2str(Area)));
disp(strcat('EjePrincipal 1 : ',num2str(EjePrincipal)));
disp(strcat('EjeMenor 1 : ',num2str(EjeMenor)));
disp(strcat('AltoLetra 1 : ',num2str(AltoLetra)));
disp(strcat('BajoLetra 1 : ',num2str(BajoLetra)));
disp(strcat('    '));

LETRA_1=table(Area,Perimetro,EjePrincipal,EjeMenor,AltoLetra,BajoLetra);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[M2,N2,P2]=size(BW2);
SEP_A=zeros(M2,N2);
SEP_A(1:(M2-115),:)=1;
SEP_B=zeros(M2,N2);
SEP_B((M2-115):M2,:)=1;
GAA=SEP_B.*BW2;
GAA2=SEP_A.*BW2;
BAJON=regionprops(GAA,'Area');
ALTON=regionprops(GAA2,'Area');
BajoLetra=BAJON(1).Area;
AltoLetra=ALTON(1).Area;
Area=dato2(1).Area;
EjePrincipal=dato2(1).MinorAxisLength;
EjeMenor=dato2(1).MajorAxisLength;
Perimetro=max(dato2.Perimeter);
disp(strcat('Perimetro 2 : ',num2str(Perimetro)));
disp(strcat('Area 2 : ',num2str(Area)));
disp(strcat('Ejeprinciplal 2 : ',num2str(EjePrincipal)));
disp(strcat('EjeMenor 2 : ',num2str(EjeMenor)));
disp(strcat('AltoLetra 2 : ',num2str(AltoLetra)));
disp(strcat('BajoLetra 2 : ',num2str(BajoLetra)));
disp(strcat('    '));
LETRA_2=table(Area,Perimetro,EjePrincipal,EjeMenor,AltoLetra,BajoLetra);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[M3,N3,P3]=size(BW3);
SEP_A=zeros(M3,N3);
SEP_A(1:(M3-115),:)=1;
SEP_B=zeros(M3,N3);
SEP_B((M3-115):M3,:)=1;
GAA=SEP_B.*BW3;
GAA2=SEP_A.*BW3;
BAJON=regionprops(GAA,'Area');
ALTON=regionprops(GAA2,'Area');
BajoLetra=BAJON(1).Area;
AltoLetra=ALTON(1).Area;
Area=dato3(1).Area;
EjePrincipal=dato3(1).MinorAxisLength;
EjeMenor=dato3(1).MajorAxisLength;
Perimetro=max(dato3.Perimeter);
disp(strcat('Perimetro 3 : ',num2str(Perimetro)));
disp(strcat('Area 3 : ',num2str(Area)));
disp(strcat('Ejeprinciplal 3 : ',num2str(EjePrincipal)));
disp(strcat('EjeMenor 3 : ',num2str(EjeMenor)));
disp(strcat('AltoLetra 3 : ',num2str(AltoLetra)));
disp(strcat('BajoLetra 3 : ',num2str(BajoLetra)));
LETRA_3=table(Area,Perimetro,EjePrincipal,EjeMenor,AltoLetra,BajoLetra);
T1=LETRA_1;
RESPUESTA_1=predict(trainedClassifierSVM,T1{:,trainedClassifierSVM.PredictorNames})
T2=LETRA_2;
RESPUESTA_2=predict(trainedClassifierSVM,T2{:,trainedClassifierSVM.PredictorNames})
T3=LETRA_3;
RESPUESTA_3=predict(trainedClassifierSVM,T3{:,trainedClassifierSVM.PredictorNames})
set(handles.text10,'String',RESPUESTA_1);
set(handles.text11,'String',RESPUESTA_2);
set(handles.text12,'String',RESPUESTA_3);
  
function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global trainedClassifierSVM;
global validationAccuracy;

load ('TF PDS2.mat', 'BasedeDatosTFPDS2')

[q,t]=size(BasedeDatosTFPDS2);
ind=randperm(q,q);
for i=1:q
    BasedeDatosTFPDS2(i,:)=BasedeDatosTFPDS2(ind(i),:);
end
Tentrena=BasedeDatosTFPDS2(1:round(q*70/100),:); %El 70% para el entrenamiento
Tvalida=BasedeDatosTFPDS2(round(q*70/100)+1:end,:); %El 30% para la validacion

% ENTRENO LA RED
[trainedClassifierSVM, validationAccuracy] = trainClassifierSVM(Tentrena);

% Valido la red con los 30% de datos 
%trainedClassifier es la red entrenada
%ysal es la salida de la red cuando se le ingresa un nuevo dato
[a,b]=size(Tvalida);
yfit=[];
for i=1:a
    T=Tvalida(i,1:end-1); 
    ysal=predict(trainedClassifierSVM, T{:,trainedClassifierSVM.PredictorNames}); 
    yfit = [yfit; ysal];
end
res=[Tvalida(:,end),yfit];
test=categorical(Tvalida.Letra);
yt=categorical(yfit);
[cm,order]=confusionmat(test,yt);

figure()
plotConfMat2(cm,{'A' 'B' 'C' 'D' 'E' 'F' 'G' 'H' 'I' 'J' 'K' 'L' 'M' 'N' 'O' 'P' 'Q' 'R' 'S' 'T' 'U' 'V' 'W' 'X' 'Y' 'Z'})
