.. idl:

Dendrogram Generation with IDL
==============================

There are currently several codes to generate dendrograms -- we are
working on unifying these packages. For now, we will look at the
original IDL code written by Erik Rosolowsky, available `here <https://github.com/ChrisBeaumont/dendro_idl>`_

Make sure this is in your IDL path

Also download :download:`this file <demo.fits>`, which is used in this tutorial.

First, read in the image::

       im = mrdfits('demo.fits')

The code expects a binary mask -- an array that has the same shape as
the image, where each entry is 1 if that pixel is to be included in
the output, and 0 otherwise. For now, lets just use the entire image,
and create a mask of all 1s::

    mask = byte(im * 0) + 1B

There are a few other important parameters:

- friends. This is used to control when a pixel is considered a local
  maximum (i.e., a leaf in the dendrogram). A pixel must be brighter
  than all of its neighbors within "friends" pixels. If the input is a
  3D cube, then friends only applies to the first 2 dimensions.
- specfriends. Just like friends, but applies to the third dimension for 3D cubes.
- delta. The height of each leaf must be at least "delta" above its first merger
- minpix. Every leaf must contain at least minpix pixels before its first merger.
- minpeak. Every leaf must have an intensity of at least minpeak


We will use these values for now::

   friends = 3
   delta = 1.0
   minpix = 10
   minpeak = 5.0

We create the dendrogram with the Topologize procedure::

   topologize, im, mask, friends = friends, delta = delta, minpix = minpix, minpeak = minpeak, /fast, pointer = ptr

This puts the output of the into a pointer variable ptr. For convenience, lets dereference that and store in a normal variable::

   dendro = *ptr

Viewing the Dendrogram
**********************

The `cloud-viz <http://code.google.com/p/cloud-viz/>`_ package provides some ability to view dendrograms. Simply invoke with::

    dendroviz, ptr

to play around. More coming soon.


Description of Dendrogram Structure Fields
******************************************
Lets examine the contents of the pointer output from topologize. The original code represents the dendrogram in a slightly cumbersome way, but there are at least several programs which save you from having to understand too much of what's going on here::

  IDL> help, *ptr, /struct
  ** Structure <192e208>, 21 tags, length=3610048, data length=3610041, refs=1:
   MERGER          DOUBLE    Array[49, 49]
   CLUSTER_LABEL   INT       Array[150801]
   CLUSTER_LABEL_H LONG      Array[98]
   CLUSTER_LABEL_RI
                   LONG      Array[60217]
   LEVELS          DOUBLE    Array[96]
   CLUSTERS        LONG      Array[2, 48]
   HEIGHT          DOUBLE    Array[97]
   KERNELS         LONG      Array[49]
   ORDER           LONG      Array[49]
   NEWMERGER       DOUBLE    Array[49, 49]
   X               LONG      Array[150801]
   Y               LONG      Array[150801]
   V               LONG      Array[150801]
   T               FLOAT     Array[150801]
   SZ              LONG      Array[5]
   CUBEINDEX       LONG      Array[150801]
   SZDATA          LONG      Array[5]
   ALL_NEIGHBORS   BYTE         0
   XLOCATION       DOUBLE    Array[97]
   NPIX            LONG      Array[49, 49]
   FAST            INT              1

Here's what some of these fields describe:

- kernels : These list the 1D indices (of the input image) of the
  location of 49 local maxima. Each of these kernels defines a leaf in
  the dendrogram
- clusters: Describes which two structures merge at each merger in the
  dendrogram. The number of mergers is always one less than the number
  of kernels. clusters[*, i] lists the ids of the two structures that
  merge to form structure i + n_kernel (the first n_kernel structures
  are the leaves.
- merger : The [i,j] entry lists the intensity below which kernel i
  and j are contained within a single contour
- x : A 1 dimensional list of x locations in the original data. (Not
  all pixels are included, if the input mask contains zeros. This is
  cumbersome, I know)
- y : Like x
- v : The velocity, if the input image was 3 dimensional
- t : The intensity at each (x,y,v) location
- cluster_label : the ID of the highest (most leafward) dendrogram
  structure that each (x,y,v) point belongs to.
- cubeindex : the 1d index of each (x,y,v) location in the original
  cube
- height: The height of each structure in the dendrogram, for
  plotting. The height of the leaves is the intensity of the local
  maximum. The height of all other structures is the intensity of the
  relevant contour merger
- xlocation : The xlocation of each structure, for plotting. At the
  moment, this carries no physical meaning.
