%module fwlib
%{
#include "./extern/fwlib/fwlib32.h"

%}
%include typemaps.i

%typemap(in, numinputs=0) unsigned long *cncids (uint32_t temp[4]) %{
  // allocate uint32_t array
  for (int i = 0; i < 4; i++) temp[i] = 0;
  // cast type for when called by fn
  $1 = (unsigned long *) temp;
%}

%typemap(argout) unsigned long *cncids %{ 
  // cast back to allocated type
  uint32_t *temp = (uint32_t *) $1;
  PyObject *o = PyList_New(4);
  for (int i = 0; i < 4; ++i) {
    PyObject *oo = PyLong_FromUnsignedLong(temp[i]);
    PyList_SetItem(o, i, oo);
  }
  $result = SWIG_Python_AppendOutput($result, o);
%}

%typemap(in,numinputs=0) ODBSYS *OUTPUT %{
    $1 = malloc(sizeof(ODBSYS));
%}

%typemap(argout) ODBSYS* OUTPUT {
  char s[5] = "";
  PyObject *o = PyDict_New();
  PyObject *oo;

  oo = PyLong_FromLong($1->addinfo);
  PyDict_SetItemString(o, "addinfo", oo);

  oo = PyLong_FromLong($1->max_axis);
  PyDict_SetItemString(o, "max_axis", oo);

  snprintf(s, 3, "%s", $1->cnc_type);
  oo = PyUnicode_FromString(s);
  PyDict_SetItemString(o, "cnc_type", oo);

  snprintf(s, 3, "%s", $1->mt_type);
  oo = PyUnicode_FromString(s);
  PyDict_SetItemString(o, "mt_type", oo);

  snprintf(s, 5, "%s", $1->series);
  oo = PyUnicode_FromString(s);
  PyDict_SetItemString(o, "series", oo);

  snprintf(s, 5, "%s", $1->version);
  oo = PyUnicode_FromString(s);
  PyDict_SetItemString(o, "version", oo);

  snprintf(s, 3, "%s", $1->axes);
  oo = PyUnicode_FromString(s);
  PyDict_SetItemString(o, "axes", oo);

  $result = SWIG_Python_AppendOutput($result, o);
}

short cnc_startupprocess(long log_level, const char *log_file_name);
short cnc_allclibhndl3(const char *ip, unsigned short port, long timeout, unsigned short *OUTPUT);
short cnc_rdcncid(unsigned short libh, unsigned long *cncids);
short cnc_sysinfo(unsigned short libh, ODBSYS *OUTPUT);
short cnc_freelibhndl(unsigned short libh);
short cnc_exitprocess();
