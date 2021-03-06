;************************************************
;Name: Donald Peat
;Projection of Thermal Data to 3d geographic globe
;02/13/2014
;*************************************************

pro thermal_projection,filename,nsteps
compile_opt idl2

;*******USER INPUT*******
filename=''
nsteps=0
read,prompt='please enter the filename:',filename
read,prompt='please enter number of timesteps:',nsteps
if (n_elements(nsteps) le 0) then nsteps=500

;*******READ FILE INFO*******
openu,lun,filename,/get_lun,/swap_if_little_endian
nx=0
ny=0
readu,lun,nx
readu,lun,ny
data=fltarr(nx,ny)
readu,lun,data
close,lun

;*******PLOT ARRAY AND SITES 2D*******
device,decomposed=0
loadct,33
window,1,retain=2
contour,data,nlevels=30,xstyle=1,ystyle=1,/fill
plots,115,15,psym=4,symsiz=5.,color=200,thick=3
plots,150,45,psym=4,symsiz=5.,color=200,thick=3
plots,260,10,psym=4,symsiz=5.,color=200,thick=3

;*******PROJECT 2D TO SPHERE MAP*******
window,2,retain=2
map_set,-30.,150.,/orthographic,/horizon,/isotropic,/noborder
lon=findgen(nx)*360./(nx-1)
lat=findgen(ny)*180./(ny-1)-90
contour,data,lon,lat,nlevels=30,/overplot,/cell_fill
oplot,[lon[115]],[lat[15]],psym=4,symsiz=5.,color=200,thick=3
oplot,[lon[150]],[lat[45]],psym=4,symsiz=5.,color=200,thick=3
oplot,[lon[260]],[lat[10]],psym=4,symsiz=5.,color=200,thick=3
plots,200,180,psym=4,symsiz=5.,color=200,thick=3
print,"site 1 is at longitude,latitude:",[lon[115]],[lat[15]]
print,"site 2 is at longitude,latitude:",[lon[150]],[lat[45]]
print,"site 3 is at longitude,latitude:",[lon[260]],[lat[10]]

;*******1D ARRAYS FOR EACH SITE*******
site1=fltarr(nsteps)
site2=fltarr(nsteps)
site3=fltarr(nsteps)

;*******DIST/SMOOTHING LOOPS OVER TIME*******
data[nx-1,*]=data[0,*]    
n=0
for n=1,nsteps do begin      
 for i=0,nx-2 do begin      
  for j=1,ny-2 do begin    
      data[i,j] = 0.2 * (data[i-1,j] + data[i+1,j] + data[i,j+1] + data[i,j-1] + data[i,j])
       site1[n-1]=data[115,15]
       site2[n-1]=data[150,45] 
       site3[n-1]=data[260,10] 
  endfor                       
 endfor 

m=(n mod 50)
if (m eq 0) then begin
w=0
if (n*30 le 180) then w=(180.+(30*n))
if (n*3 ge 180) then w=((180+(30*n)) mod 360)
window,2,retain=2
map_set,-30.,w,/orthographic,/horizon,/isotropic,/noborder
contour,data,lon,lat,nlevels=30,/overplot,/cell_fill  
oplot,[lon[115]],[lat[15]],psym=4,symsiz=5.,color=200,thick=3
oplot,[lon[150]],[lat[45]],psym=4,symsiz=5.,color=200,thick=3
oplot,[lon[260]],[lat[10]],psym=4,symsiz=5.,color=200,thick=3
endif
endfor     

;*******PLOT 1D SITE ARRAYS*******
window,3,retain=2
time=findgen(nsteps)
datamin=min(data)
datamax=max(data)
plot,time,site1,yrange=[datamin,datamax],color=100,linestyle=8
plots,time,site2,color=250,linestyle=2
plots,time,site3,color=155,linestyle=4 

;*******SAVE SITE ARRAYS AND NSTEPS TO UNFORM FILE*******
openw,lun,'midterm.out',/get_lun,/swap_if_little_endian 
writeu,lun,nsteps,site1,site2,site3
close,lun

;*******SAVE FINAL IMAGE TO POSTSCRIPT FILE*******
device,decomposed=0
set_plot,'ps' 
device,/color,bits_per_pixel=8,filename='midterm.ps',xsize=10,ysize=10
data[nx-1,*]=data[0,*]
n=0
for n=1,nsteps do begin      
 for i=0,nx-2 do begin      
  for j=1,ny-2 do begin    
   data[i,j] = 0.2 * (data[i-1,j] + data[i+1,j] + data[i,j+1] + data[i,j-1] + data[i,j])   
  endfor                       
 endfor
endfor
w=((180+(30*nsteps)) mod 360)
map_set,-30.,w,/orthographic,/horizon,/isotropic,/noborder
contour,data,lon,lat,nlevels=30,/overplot,/cell_fill   
oplot,[lon[115]],[lat[15]],psym=4,symsiz=5.,color=200,thick=3
oplot,[lon[150]],[lat[45]],psym=4,symsiz=5.,color=200,thick=3
oplot,[lon[260]],[lat[10]],psym=4,symsiz=5.,color=200,thick=3

device,/close_file
set_plot,'x'
return

end 


