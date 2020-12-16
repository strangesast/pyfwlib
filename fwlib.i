%module fwlib
%{
#include "./extern/fwlib/fwlib32.h"
typedef struct odbaxdt_t {
  char    name[4];
  int32_t data;
  int16_t dec;
  int16_t unit;
  int16_t flag;
  int16_t reserve;
} ODBAXDT_T ;

static PyStructSequence_Field axdata_fields[] = {
  {"name", "axis name"},
  {"data", "position data"},
  {"dec", "decimal position"},
  {"unit", "data unit"},
  {"flag", "flags"},
  {"reserve", "reserve"},
  NULL
};

static PyStructSequence_Desc axdata_desc = {
    "axdata",
    NULL,
    axdata_fields,
    6
};

static PyTypeObject AxdataType = {0};

static PyStructSequence_Field sysinfo_fields[] = {
  {"addinfo", "additional information"},
  {"max_axis", "maximum axis number"},
  {"cnc_type", "cnc type"},
  {"mt_type", "M/T/TT"},
  {"series", "series NO."},
  {"version", "version NO."},
  {"axes", "axis number"}
};

static PyStructSequence_Desc sysinfo_desc = {
    "sysinfo",
    NULL,
    sysinfo_fields,
    7
};

static PyTypeObject SysinfoType = {0};

%}
%include typemaps.i

%{
void deinit()
{
  cnc_exitprocess();
}
%}

%init %{
  PyStructSequence_InitType(&AxdataType, &axdata_desc);
  PyStructSequence_InitType(&SysinfoType, &sysinfo_desc);
  cnc_startupprocess(0, 'focas.log');
  atexit(deinit);
%}

%typemap(in, numinputs=0) unsigned long *cncids (uint32_t temp[4]) %{
  // allocate uint32_t array
  for (int i = 0; i < 4; i++) temp[i] = 0;
  // cast type for when called by fn
  $1 = (unsigned long *) temp;
%}

%typemap(argout) unsigned long *cncids %{ 
  // cast back to allocated type
  uint32_t *temp = (uint32_t *) $1;
  PyObject *o = PyTuple_New(4);
  for (int i = 0; i < 4; ++i) {
    PyObject *oo = PyLong_FromUnsignedLong(temp[i]);
    PyTuple_SetItem(o, i, oo);
  }
  $result = SWIG_Python_AppendOutput($result, o);
%}

%typemap(in,numinputs=0) ODBSYS *odbsys (ODBSYS *temp) %{
  temp = malloc(sizeof(ODBSYS));
  $1 = temp;
%}
%typemap(in,numinputs=0) ODBSYS *odbsys %{
    $1 = malloc(sizeof(ODBSYS));
%}

%typemap(argout) ODBSYS* odbsys %{
  char s[5] = "";
  PyObject *o = PyStructSequence_New(&SysinfoType);
  PyObject *oo;

  oo = PyLong_FromLong($1->addinfo);
  PyStructSequence_SetItem(o, 0, oo);

  oo = PyLong_FromLong($1->max_axis);
  PyStructSequence_SetItem(o, 1, oo);

  snprintf(s, 3, "%s", $1->cnc_type);
  oo = PyUnicode_FromString(s);
  PyStructSequence_SetItem(o, 2, oo);

  snprintf(s, 3, "%s", $1->mt_type);
  oo = PyUnicode_FromString(s);
  PyStructSequence_SetItem(o, 3, oo);

  snprintf(s, 5, "%s", $1->series);
  oo = PyUnicode_FromString(s);
  PyStructSequence_SetItem(o, 4, oo);

  snprintf(s, 5, "%s", $1->version);
  oo = PyUnicode_FromString(s);
  PyStructSequence_SetItem(o, 5, oo);

  snprintf(s, 3, "%s", $1->axes);
  oo = PyUnicode_FromString(s);
  PyStructSequence_SetItem(o, 6, oo);

  $result = SWIG_Python_AppendOutput($result, o);
%}

%typemap(freearg) ODBSYS *odbsys %{
  free($1);
%}

%typemap(in,numinputs=0) (short *axis_count, ODBAXISNAME *odbaxisname) %{
  ODBAXISNAME temp0[MAX_AXIS] = {0};
  short temp1 = MAX_AXIS;
  $2 = (ODBAXISNAME *)temp0;
  $1 = &temp1;
%}

%typemap(argout) (short *axis_count, ODBAXISNAME* odbaxisname) %{
  ODBAXISNAME n;
  char b[3] = {0};
  PyObject *o = PyTuple_New(*$1);
  for (int i = 0; i < *$1; ++i) {
    n = $2[i];
    b[0] = n.name;
    b[1] = n.suff;
    PyObject *oo = PyUnicode_FromString(b);
    PyTuple_SetItem(o, i, oo);
  }
  $result = SWIG_Python_AppendOutput($result, o);
%}


%typemap(in) (short* type, short num, short* len, ODBAXDT* axdata) %{
  short l = MAX_AXIS;
  if (PySequence_Check($input)) {
    int size = PySequence_Size($input);
    short type[10] = {0};
    ODBAXDT *axdata = (ODBAXDT *) malloc(size * l * sizeof(ODBAXDT_T));

    for (int i = 0; i < size; i++) {
      PyObject *o = PySequence_GetItem($input, i);
      if (PyLong_Check(o)) {
        long v = PyLong_AsLong(o);
        if (v >= 0) {
          type[i] = (short) v;
          continue;
        }
      }
      PyErr_SetString(PyExc_TypeError, "invalid types array");
      SWIG_fail;
    }
    $1 = type;
    $2 = size;
    $3 = &l;
    $4 = axdata;
  } else {
    PyErr_SetString(PyExc_TypeError, "uhh");
    SWIG_fail;
  }
%}

%typemap(argout) (short* type, short num, short* len, ODBAXDT* axdata) %{
  short num = *$3;
  ODBAXDT_T *arr = (ODBAXDT_T *) $4;
  PyObject *o = PyTuple_New(num * $2);
  for (int i = 0; i < num; i++) {
    for (int j = 0; j < $2; j++) {
      PyObject *oo = PyStructSequence_New(&AxdataType);
      PyObject *v;
      ODBAXDT_T d = arr[j * MAX_AXIS + i];

      v = PyUnicode_FromString(d.name);
      PyStructSequence_SetItem(oo, 0, v);

      v = PyLong_FromLong(d.data);
      PyStructSequence_SetItem(oo, 1, v);

      v = PyLong_FromLong(d.dec);
      PyStructSequence_SetItem(oo, 2, v);

      v = PyLong_FromLong(d.unit);
      PyStructSequence_SetItem(oo, 3, v);

      v = PyLong_FromLong(d.flag);
      PyStructSequence_SetItem(oo, 4, v);

      v = PyLong_FromLong(d.reserve);
      PyStructSequence_SetItem(oo, 5, v);

      PyTuple_SetItem(o, j * num + i, oo);
    }
  }
  $result = SWIG_Python_AppendOutput($result, o);
%}

%typemap(freearg) (short* type, short num, short* len, ODBAXDT* axdata) %{
  if ($4) free($4);
%}


short cnc_allclibhndl3(const char *ip, unsigned short port, long timeout, unsigned short *OUTPUT);
short cnc_rdcncid(unsigned short libh, unsigned long *cncids);
short cnc_sysinfo(unsigned short libh, ODBSYS *odbsys);
short cnc_rdaxisname(unsigned short, short *axis_count, ODBAXISNAME *odbaxisname);
short cnc_rdaxisdata(unsigned short, short cls, short* type, short num, short* len, ODBAXDT* axdata);
short cnc_freelibhndl(unsigned short libh);
