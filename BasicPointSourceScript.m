clear

I=-.029;       %Injected current in mA
d=400;    %micrometers perpendicular distance of the point source from the center of the axon.
d2=0;       %z offset. In micrometers distance to the right of the node, parallel to the axon.  Negative number indicates left of the node.
x=0;    %Could do an offset in the x direction

number_nodes=161;
PW = 0.01;
fiberD=12;%um

%Save variables for use by Neuron
save num_nodes.dat number_nodes -ascii
save PW.dat PW -ascii
save fiberD.dat fiberD -ascii;

n=1;%node width
m=3;%mysa width
f=(2.5811*fiberD)+19.59;
deltax=969.3*log(fiberD)-1144.6; %Distance between nodes
s=(deltax-n-(2*m)-(2*f))/6; %stin width

widths=[n m f s s s s s s f m];
if mod(number_nodes,2) == 0
    %number is even
    w=repmat(widths,1,(number_nodes-2));
    w=cat(2,w,widths(1:6));
else
    %number is odd
    w=repmat(widths,1,(number_nodes-1));%widths of each segement
    w(end+1)=1;
end

centers=w/2;%middle of each segement ex. middle of each node, middle of each mysa...
z=[];
for b=1:length(w)
   z(end+1)=centers(b)+sum(w(1:b-1))-centers(1)+d2;%um z=transvers distance up and down the arm from the point source to the position on the axon
end
cond_long=1/(3e6); %ohm*um longitudinal conductivity
cond_trans=1/(1.2e7); %ohm*um transverse conductivity

%Calculates voltage along nerve at the center of each segment (z)
Ve=I./(4*pi*sqrt((x.^2*cond_long*cond_trans)'+(d.^2*cond_long*cond_trans)'+(z.^2*cond_trans^2)'))';  %voltage in mV
Vemirror=fliplr(Ve);%mirrors for either side of the electrode
if mod(number_nodes,2) == 1 %number is odd
    Vemirror=Vemirror(1:end-1);%removes extra node in the middle for odd number of nodes
end

Vfinal=cat(2,Vemirror,Ve);%combines two mirrored vectors

nodes=find(w==1);
mysas=find(w==3);
fluts=find(w==f);
stins=find(w==s);

nodesfinal=nodes;
NODE=Vfinal(nodesfinal);
save nodes.dat NODE -ascii

mysasfinal=mysas;%cat(2,mysas,mysas2);
MYSA=Vfinal(mysasfinal);
save mysas.dat MYSA -ascii

flutsfinal=fluts;%cat(2,fluts,fluts2);
FLUT=Vfinal(flutsfinal);
save fluts.dat FLUT -ascii

stinsfinal=stins;%cat(2,stins,stins2);
STIN=Vfinal(stinsfinal);
save stins.dat STIN -ascii

[status,result] = system('C:\nrn\bin\nrniv.exe -nobanner -nopython sensory_final.hoc -c quit()');
fire=str2num(result(end-1))








