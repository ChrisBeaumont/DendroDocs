pro colorplot
  common colorplot, ptr
  if n_elements(ptr) eq 0 then begin
     im = mrdfits('demo.fits', 0, header)
     mask = byte(im * 0) + 1B

     friends = 3
     delta = 1.0
     minpix = 10
     minpeak = 5.0

     levels = findgen(500) / 499. * 20
     topologize, im, mask, friends=friends, $
                 delta = delta, minpix = minpix, $
                 minpeak = minpeak, $
                 levels = levels, $
                 /fast, pointer = ptr
     
     ;- make a fake header -- levelprops wants it, 
     ;- and the demo fits file doesn't have one
     mkhdr, hd, im
     sxaddpar, hd, 'crpix1', 1
     sxaddpar, hd, 'crpix2', 1
     sxaddpar, hd, 'crpix3', 1
     sxaddpar, hd, 'crval1', 1
     sxaddpar, hd, 'crval2', 1
     sxaddpar, hd, 'crval3', 1
     sxaddpar, hd, 'cdelt1', 1 / 3600.
     sxaddpar, hd, 'cdelt2', -1 / 3600.
     sxaddpar, hd, 'cdelt3', 1 / 3600.
     
     levelprops, ptr, $
                 dist = 500., $
                 hd = hd
  endif
     
  ;- plot the dendrogram
  loadct, 0, /silent
  xy = dplot_xy(ptr)
  plot, xy[0,*], xy[1,*], pos = [.05, 0, .95, .8], xra = [-1, max(xy[0,*])+1], /xsty

  ;- load a color table
  device, decomposed = 0
  loadct, 25, /silent

  ;- overplot rmat as a color
  colors = (*ptr).rmat
  lo = min(colors, max = hi)
  print, lo, hi
  colors = bytscl(colors) ;- to put in range 0-255
  
  ;- loop over leaves and branches
  nst = n_elements((*ptr).height)
  for i = 0, nst - 1, 1 do begin

     ;- id of structure this merges with, and
     ;- id of the merged structure
     partner = merger_partner(i, (*ptr).clusters, merge = m)
     if m eq -1 then continue ;- don't plot the root

     y0 = (*ptr).height[i] ;- top of structure
     y1 = (*ptr).height[m] ;- bottom of structure
     x = (*ptr).xlocation[i] ;- x location

     ;- find one of the leaves nested inside i
     seed = min(leafward_mergers(i, (*ptr).clusters))
     
     ;- sample the colors from y0 to y1
     sample = findgen(20) / 19. * (y1 - y0) + y0
     c = interpol(colors[seed, *], (*ptr).levels, sample)

     ;- plot each segment
     for j = 0, n_elements(sample) - 2, 1 do $
        oplot, [x, x], sample[j:j+1], color = c[j], thick = 3
  endfor
  colorbar, minrange = lo, maxrange = hi, format='(f0.2)'
end
