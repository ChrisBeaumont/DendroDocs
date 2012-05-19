.. cpp:

Dendrogram Generation with C++
==============================

If you can get it to work, I recommend generating dendrograms with C++
-- the code runs much faster, works direcly with fits files, and is
based on a simpler algorithm. This page will walk you through
installing and running the program, and getting the output into IDL.

Installation
------------
The code is available on GitHub `here <https://github.com/ChrisBeaumont/Dendro>`_, and comes with a README and INSTALL file. You can either clone the git repository, our download the latest version from the `download <https://github.com/ChrisBeaumont/Dendro/downloads>`_ page.

You will need to install CCfits in order to run this program. If this is installed in a standard location, you should be fine with running::

    ./configure
    make
    make install

If this complains about not finding CCfits, you will need to supply extra ``CPPFLAGS`` and ``LDFLAGS`` to specify where to look for CCfits::

    ./configure CPPFLAGS="-I/path/to/CCfits/headers" LDFLAGS="-L/path/to/CCfits/libraries"


This will create an executable ``dendro``, which is the main program.

Running
-------

``dendro`` runs from the command line as follows::

    dendro [input_file] -o [output_file] -f [friends] -s [specfriends] -m [minpeak]

.. NOTE::
  ``dendro`` requires that the input fits file be in 32 bit float format.


The ``friends``, ``specfriends``, and ``minpeak`` values behve the same way as described in :doc:`idl`. This produces a multi-extension fits file with the same basic information as the output from the IDL routine:

 * Extension 0 is the original data.
 * Extension 1 corresponds to the CLUSTER_LABEL tag of the IDL output structure.
 * Extension 2 corresponds to the CLUSTERS tag.
 * Extension 3 is the KERNELS tag

Reading into IDL
----------------
The routine ``ptr = dendrcpp2idl(file_name)`` will read a fits file created by the ``dendro`` C++ program and produce an IDL pointer compatible with the rest of the analysis routines.

Likewise, the dendroviz program accepts as input the name of one of these fits files::

    dendroviz, 'fits_file_name'

Pruning
-------

The C++ routine lacks parameters like ``delta`` and ``npix``, which
are used by IDL to 'prune' dendrograms of insignificant leaves. Instead, pruning is done in 2 passes::

    [from command line]
    dendro in_file -o out_file

    idl
    IDL> ptr = dendrocpp2idl(out_file)
    IDL> to_prune = generate_prunelist(ptr, delta = 1.0, npix = 10, $
                                       minflux = 1.0, minpeak=5, $
				       out_file = 'new_seeds.txt')
    IDL> exit

    dendro in_file -o pruned_out_file -k new_seeds.txt

The ``-k`` option in ``dendro`` specifies a file listing which pixels
define the leaves of the dendrogram. The file is a 2-column list,
giving "pixel_index, intensity". The intensity is a sanity check, to
make sure the pixel locations are specified correctly -- if they don't
agree, the program exits in error.

``generate_prunelist`` is an IDL routine which will generate the required prune file, based on the pruning parameters described in :doc:`idl`


