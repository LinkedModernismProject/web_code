.. highlightlang:: c

.. _fileobjects:

File Objects
------------

.. index:: object: file

Python's built-in file objects are implemented entirely on the :ctype:`FILE\*`
support from the C standard library.  This is an implementation detail and may
change in future releases of Python.  The ``PyFile_`` APIs are a wrapper over
the :mod:`io` module.


.. cfunction:: PyFile_FromFd(int fd, char *name, char *mode, int buffering, char *encoding, char *newline, int closefd)

   Create a new :ctype:`PyFileObject` from the file descriptor of an already
   opened file *fd*. The arguments *name*, *encoding* and *newline* can be
   *NULL* to use the defaults; *buffering* can be *-1* to use the default.
   Return *NULL* on failure.

   .. warning::

     Take care when you are mixing streams and descriptors! For more 
     information, see `the GNU C Library docs
     <http://www.gnu.org/software/libc/manual/html_node/Stream_002fDescriptor-Precautions.html#Stream_002fDescriptor-Precautions>`_.


.. cfunction:: int PyObject_AsFileDescriptor(PyObject *p)

   Return the file descriptor associated with *p* as an :ctype:`int`.  If the
   object is an integer, its value is returned.  If not, the
   object's :meth:`fileno` method is called if it exists; the method must return
   an integer, which is returned as the file descriptor value.  Sets an
   exception and returns ``-1`` on failure.


.. cfunction:: PyObject* PyFile_GetLine(PyObject *p, int n)

   .. index:: single: EOFError (built-in exception)

   Equivalent to ``p.readline([n])``, this function reads one line from the
   object *p*.  *p* may be a file object or any object with a :meth:`readline`
   method.  If *n* is ``0``, exactly one line is read, regardless of the length of
   the line.  If *n* is greater than ``0``, no more than *n* bytes will be read
   from the file; a partial line can be returned.  In both cases, an empty string
   is returned if the end of the file is reached immediately.  If *n* is less than
   ``0``, however, one line is read regardless of length, but :exc:`EOFError` is
   raised if the end of the file is reached immediately.


.. cfunction:: int PyFile_WriteObject(PyObject *obj, PyObject *p, int flags)

   .. index:: single: Py_PRINT_RAW

   Write object *obj* to file object *p*.  The only supported flag for *flags* is
   :const:`Py_PRINT_RAW`; if given, the :func:`str` of the object is written
   instead of the :func:`repr`.  Return ``0`` on success or ``-1`` on failure; the
   appropriate exception will be set.


.. cfunction:: int PyFile_WriteString(const char *s, PyObject *p)

   Write string *s* to file object *p*.  Return ``0`` on success or ``-1`` on
   failure; the appropriate exception will be set.
