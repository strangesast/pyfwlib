#define PY_SSIZE_T_CLEAN
#include <Python.h>
#include <stdbool.h>
#include <stdio.h>
#include "external/fwlib/fwlib32.h"

unsigned short libh;
char *AXIS_UNITH[] = {"mm",          "inch",   "degree",   "mm/minute",
                      "inch/minute", "rpm",    "mm/round", "inch/round",
                      "%",           "Ampere", "Second"};

static PyObject *allclibhndl3(PyObject *self, PyObject *args) {
  long timeout;  // 10
  char *device_ip;
  unsigned short device_port;  // 8193

  if (!PyArg_ParseTuple(args, "sHl", &device_ip, &device_port, &timeout))
    return NULL;

  // printf("Connecting to %s:%d\n", device_ip, device_port);
  if (cnc_allclibhndl3(device_ip, device_port, timeout, &libh) != EW_OK) {
    PyErr_SetString(PyExc_Exception, "Failed to connect to cnc!");
    return NULL;
  }

  Py_RETURN_NONE;
}

static PyObject *freelibhndl(PyObject *self, PyObject *args) {
  if (cnc_freelibhndl(libh) != EW_OK) {
    PyErr_SetString(PyExc_Exception, "Failed to free lib handle!");
    return NULL;
  }
  Py_RETURN_NONE;
}

static PyObject *rdcncid(PyObject *self, PyObject *args) {
  PyObject *m;
  unsigned long cncIDs[4] = {0, 0, 0, 0};
  char cncID[36];

  if (!PyArg_ParseTuple(args, "")) return NULL;

  if (cnc_rdcncid(libh, cncIDs) != EW_OK) {
    PyErr_SetString(PyExc_Exception, "Failed to get cnc id!");
    return NULL;
  }

  if (sizeof(long) == 4) {
    sprintf(cncID, "%08lx-%08lx-%08lx-%08lx", cncIDs[0] & 0xffffffff,
            cncIDs[1] & 0xffffffff, cncIDs[2] & 0xffffffff,
            cncIDs[3] & 0xffffffff);
  } else {
    sprintf(cncID, "%08lx-%08lx-%08lx-%08lx", cncIDs[0] & 0xffffffff,
            cncIDs[0] >> 32 & 0xffffffff, cncIDs[1] & 0xffffffff,
            cncIDs[1] >> 32 & 0xffffffff);
  }

  m = PyDict_New();
  PyObject *id = PyUnicode_FromString(cncID);
  PyDict_SetItemString(m, "id", id);

  return m;
}

static PyObject *rdaxisname(PyObject *self, PyObject *args) {
  PyObject *m;

  const int num = 1;
  short len = MAX_AXIS;
  short axisCount = MAX_AXIS;
  char axis_id[10];
  char axis_name[20];
  char axis_suffix[10];
  bool hasAxisData;
  short count;
  short inprec[MAX_AXIS];
  short outprec[MAX_AXIS];
  short types[] = {1};
  ODBAXISNAME axes[MAX_AXIS];
  ODBAXDT *axisData;

  if (!PyArg_ParseTuple(args, "")) return NULL;

  axisData = calloc(MAX_AXIS, sizeof(ODBAXDT));
  hasAxisData =
      cnc_rdaxisdata(libh, 1, (short *)types, num, &len, axisData) == EW_OK;

  if (cnc_getfigure(libh, 0, &count, inprec, outprec) != EW_OK ||
      cnc_rdaxisname(libh, &axisCount, axes) != EW_OK) {
    PyErr_SetString(PyExc_Exception, "Failed to get axis info\n");
    return NULL;
  }

  m = PyTuple_New(axisCount);
  for (int i = 0; i < axisCount; i++) {
    double divisor;
    PyObject *d_axis = PyDict_New();
    sprintf(axis_id, "%c", axes[i].name);
    PyObject *d_axis_id = PyUnicode_FromString(axis_id);
    PyDict_SetItemString(d_axis, "id", d_axis_id);

    divisor = pow((long double)10.0, (long double)inprec[i]);
    PyObject *d_axis_divisor = PyFloat_FromDouble(divisor);
    PyDict_SetItemString(d_axis, "divisor", d_axis_divisor);

    PyObject *d_axis_index = PyLong_FromLong(i);
    PyDict_SetItemString(d_axis, "index", d_axis_index);

    sprintf(axis_suffix, "%c", axes[i].suff);
    PyObject *d_axis_suffix = PyUnicode_FromString(axis_suffix);
    PyDict_SetItemString(d_axis, "suffix", d_axis_suffix);

    if (hasAxisData) {
      sprintf(axis_name, "%.4s", axisData[i].name);
      PyObject *d_axis_name = PyUnicode_FromString(axis_name);
      PyDict_SetItemString(d_axis, "name", d_axis_name);

      PyObject *d_axis_flag = PyLong_FromLong(axisData[i].flag);
      PyDict_SetItemString(d_axis, "flag", d_axis_flag);

      short unit = axisData[i].unit;
      PyObject *d_axis_unit = PyLong_FromLong(unit);
      PyDict_SetItemString(d_axis, "unit", d_axis_unit);

      PyObject *d_axis_unith = PyUnicode_FromString(
          (unit > -1 && unit < sizeof(AXIS_UNITH)) ? AXIS_UNITH[unit] : "");
      PyDict_SetItemString(d_axis, "unith", d_axis_unith);

      PyObject *d_axis_decimal = PyLong_FromLong(axisData[i].dec);
      PyDict_SetItemString(d_axis, "decimal", d_axis_decimal);
    }
    PyTuple_SetItem(m, i, d_axis);
  }
  free(axisData);

  return m;
}

static PyObject *sysinfo(PyObject *self, PyObject *args) {
  PyObject *m;
  ODBSYS sysinfo;

  char cnc_type[3]; /* cnc type <ascii char> */
  PyObject *d_cnc_type;

  char mt_type[3]; /* M/T/TT <ascii char> */
  PyObject *d_mt_type;

  char series[5]; /* series NO. <ascii char> */
  PyObject *d_series;

  char version[5]; /* version NO.<ascii char> */
  PyObject *d_version;

  char axes[3]; /* axis number<ascii char> */
  PyObject *d_axes;

  PyObject *d_addinfo;
  PyObject *d_max_axis;

  if (!PyArg_ParseTuple(args, "")) return NULL;

  // library handle.  needs to be closed when finished.
  if (cnc_sysinfo(libh, &sysinfo) != EW_OK) {
    PyErr_SetString(PyExc_Exception, "Failed to get cnc info!");
    return NULL;
  }

  // short   addinfo ;       /* additional information  */
  // short   max_axis ;      /* maximum axis number */
  m = PyDict_New();

  d_addinfo = PyLong_FromLong(sysinfo.addinfo);
  PyDict_SetItemString(m, "addinfo", d_addinfo);

  d_max_axis = PyLong_FromLong(sysinfo.max_axis);
  PyDict_SetItemString(m, "max_axis", d_max_axis);

  sprintf(cnc_type, "%.2s", sysinfo.cnc_type);
  d_cnc_type = PyUnicode_FromString(cnc_type);
  PyDict_SetItemString(m, "cnc_type", d_cnc_type);

  sprintf(mt_type, "%.2s", sysinfo.mt_type);
  d_mt_type = PyUnicode_FromString(mt_type);
  PyDict_SetItemString(m, "mt_type", d_mt_type);

  sprintf(series, "%.4s", sysinfo.series);
  d_series = PyUnicode_FromString(series);
  PyDict_SetItemString(m, "series", d_series);

  sprintf(version, "%.4s", sysinfo.version);
  d_version = PyUnicode_FromString(version);
  PyDict_SetItemString(m, "version", d_version);

  sprintf(axes, "%.2s", sysinfo.axes);
  d_axes = PyUnicode_FromString(axes);
  PyDict_SetItemString(m, "axes", d_axes);

  return m;
}

static PyMethodDef methods[] = {
    {"allclibhndl3", allclibhndl3, METH_VARARGS,
     "Allocates the library handle and connects to CNC that has the specified "
     "IP address or the Host Name."},
    {"freelibhndl", freelibhndl, METH_VARARGS,
     "Frees the library handle which was used by the Data window library."},
    {"rdcncid", rdcncid, METH_VARARGS, "Reads the CNC ID number."},
    {"rdaxisname", rdaxisname, METH_VARARGS,
     "Reads various data relating to servo axis/spindle."},
    {"sysinfo", sysinfo, METH_VARARGS,
     "Reads system information such as kind of CNC system, Machining(M) or "
     "Turning(T), series and version of CNC system software and number of the "
     "controlled axes."},
    {NULL, NULL, 0, NULL}};

void cleanup() {
  // clean up fwlib stuff
  cnc_freelibhndl(libh);
  cnc_exitprocess();
}

static struct PyModuleDef fwlibmodule = {
    PyModuleDef_HEAD_INIT,
    "fwlib", /* name of module */
    "",      /* module documentation, may be NULL */
    -1,      /* size of per-interpreter state of the module, or -1 if the module
                keeps state in global variables. */
    methods, /* a pointer to a table of module-level functions */
    NULL,    /* An array of slot definitions for multi-phase initialization */
    NULL,    /* A traversal function to call during GC traversal of the module
                object */
    NULL, /* A clear function to call during GC clearing of the module object */
    cleanup};

PyMODINIT_FUNC PyInit_fwlib(void) {
  PyObject *m;

  m = PyModule_Create(&fwlibmodule);
  if (m == NULL) {
    return NULL;
  }

  if (cnc_startupprocess(0, "focas.log") != EW_OK) {
    PyErr_SetString(PyExc_Exception, "Failed to create required log file!\n");
    return NULL;
  }

  return m;
}
