%module fwlib
%{
#include "./extern/fwlib/fwlib32.h"
%}
%include typemaps.i

%typemap(in, numinputs=0) unsigned long *cncids (unsigned long *cncids) {
  long temp[4];
  $1 = temp;
}

%typemap(argout) unsigned long *cncids %{
  PyObject *o = PyList_New(4);
  for (int i = 0; i < 4; ++i) {
    PyObject *oo = PyLong_FromUnsignedLong($1[i]);
    PyList_SetItem(o, i, oo);
  }
  // tmp = SWIG_NewPointerObj($1, $1_descriptor, SWIG_POINTER_OWN);

  $result = SWIG_Python_AppendOutput($result, o);
%}

short cnc_startupprocess(long log_level, const char *log_file_name);
short cnc_allclibhndl3(const char *ip, unsigned short port, long timeout, unsigned short *OUTPUT);
short cnc_rdcncid(unsigned short libh, unsigned long *cncids);
short cnc_freelibhndl(unsigned short libh);
short cnc_exitprocess();
