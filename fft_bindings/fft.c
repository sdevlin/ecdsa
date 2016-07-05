#include <Python.h>
#include "structmember.h"
#include <fftw3.h>
#include <float.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

typedef struct {
    PyObject_HEAD
    fftw_complex *data;
    unsigned long size;
} FFT;

struct cand {
    size_t index;
    double value;
};

typedef struct cand cand;

int cmpcand(const void *p1, const void *p2)
{
    const struct cand *c1 = p1;
    const struct cand *c2 = p2;
    double v1 = c1->value;
    double v2 = c2->value;
    if (v2 > v1) {
        return -1;
    } else if (v1 > v2) {
        return 1;
    } else {
        return 0;
    }
}

static void
FFT_dealloc(FFT* self)
{
    fftw_free(self->data);
    self->ob_type->tp_free((PyObject*)self);
}

static int
FFT_init(FFT *self, PyObject *args, PyObject *kwds)
{
    int i;
    if (!PyArg_ParseTuple(args, "l", &self->size))
        return -1; 
    self->data = fftw_malloc(self->size * sizeof *self->data);
    for (i = 0; i < self->size; i += 1) {
        self->data[i][0] = 0;
        self->data[i][1] = 0;
    }
    return 0;
}

static PyObject*
FFT_setitem(FFT* self, PyObject *args)
{
    int pos;
    double a, b;

    if (!PyArg_ParseTuple(args, "idd", &pos, &a, &b))
        return NULL;
    self->data[pos][0] = a;
    self->data[pos][1] = b;
    return Py_BuildValue("");
}

static PyObject*
FFT_getitem(FFT*self, PyObject *args)
{
    int pos;
    if (!PyArg_ParseTuple(args, "i", &pos))
        return NULL;
    int meow;
    PyObject *tmp = PyTuple_New(2);
    PyTuple_SetItem(tmp, 0, PyFloat_FromDouble(self->data[pos][0]));
    PyTuple_SetItem(tmp, 1, PyFloat_FromDouble(self->data[pos][0]));
    return tmp;
}

static PyObject*
FFT_inversefft(FFT* self)
{
    fftw_plan p;
    unsigned flags = FFTW_ESTIMATE | FFTW_DESTROY_INPUT;

    p = fftw_plan_dft_1d(self->size, self->data, self->data, FFTW_BACKWARD, flags);
    fftw_execute(p);

    return Py_BuildValue("");
}

static PyObject*
FFT_best_candidates(FFT* self, PyObject *args)
{
    int ncands = 10;
    int i;
    double v;
    struct cand cands[ncands];
    
    if (!PyArg_ParseTuple(args, "|i", &ncands))
        return NULL;

    /*
    if (ncands > self->size)
        ncands = self->size;

    cands = malloc(ncands * sizeof(cand));
    */
    for (i = 0; i < self->size; i += 1) {
        v = self->data[i][0]*self->data[i][0] + self->data[i][1]*self->data[i][1];
        if (v > cands[0].value) {
            cands[0].index = i;
            cands[0].value = v;
            qsort(cands, ncands, sizeof cands[0], cmpcand);
        }
    }
    PyObject *toreturn = PyList_New(ncands);
    if (!toreturn)
        return NULL;

    for (i = 0; i < ncands; i += 1) {
        PyObject *tmp = PyTuple_New(2);
        PyTuple_SetItem(tmp, 0, PyLong_FromSsize_t(cands[i].index));
        PyTuple_SetItem(tmp, 1, PyFloat_FromDouble(cands[i].value));
        PyList_SetItem(toreturn, i, tmp);
    }
    return toreturn;
}

static PyMethodDef FFT_methods[] = {
    {"inversefft", (PyCFunction)FFT_inversefft, METH_NOARGS, "Compute the inverse FFT"},
    {"best_candidates", (PyCFunction)FFT_best_candidates, METH_VARARGS, "Get the best supplied number of candidates (default 10)"},
    {"setitem", (PyCFunction)FFT_setitem, METH_VARARGS, "Set an item in the array"},
    {"getitem", (PyCFunction)FFT_getitem, METH_VARARGS, "Get an item from the data array"},
    {NULL, NULL},
};

static PyMemberDef FFT_members[] = {
    {"size", T_LONG, offsetof(FFT, size), READONLY, PyDoc_STR("size of the fft")},
    {0}
};


static PyTypeObject FFT_Type = {
    PyObject_HEAD_INIT(NULL)
    0,                         /*ob_size*/
    "fft.FFT",             /*tp_name*/
    sizeof(FFT), /*tp_basicsize*/
    0,                         /*tp_itemsize*/
    (destructor)FFT_dealloc,                         /*tp_dealloc*/
    0,                         /*tp_print*/
    0,                         /*tp_getattr*/
    0,                         /*tp_setattr*/
    0,                         /*tp_compare*/
    0,                         /*tp_repr*/
    0,                         /*tp_as_number*/
    0,                         /*tp_as_sequence*/
    0,                         /*tp_as_mapping*/
    0,                         /*tp_hash */
    0,                         /*tp_call*/
    0,                         /*tp_str*/
    0,                         /*tp_getattro*/
    0,                         /*tp_setattro*/
    0,                         /*tp_as_buffer*/
    Py_TPFLAGS_DEFAULT | Py_TPFLAGS_BASETYPE, /*tp_flags*/
    "FFT objects",           /* tp_doc */
    0,                     /* tp_traverse */
    0,                     /* tp_clear */
    0,                     /* tp_richcompare */
    0,                     /* tp_weaklistoffset */
    0,                     /* tp_iter */
    0,                     /* tp_iternext */
    FFT_methods,             /* tp_methods */
    FFT_members,             /* tp_members */
    0,                         /* tp_getset */
    0,                         /* tp_base */
    0,                         /* tp_dict */
    0,                         /* tp_descr_get */
    0,                         /* tp_descr_set */
    0,                         /* tp_dictoffset */
    (initproc)FFT_init,      /* tp_init */
    0,                         /* tp_alloc */
    0,                 /* tp_new */
};

static PyMethodDef module_methods[] = {
    {NULL}  /* Sentinel */
};

#ifndef PyMODINIT_FUNC  /* declarations for DLL import/export */
#define PyMODINIT_FUNC void
#endif
PyMODINIT_FUNC
initfft(void) 
{
    PyObject* m;

    FFT_Type.tp_new = PyType_GenericNew;
    if (PyType_Ready(&FFT_Type) < 0)
        return;

    m = Py_InitModule3("fft", module_methods,
                       "Example module that creates an extension type.");

    Py_INCREF(&FFT_Type);
    PyModule_AddObject(m, "FFT", (PyObject *)&FFT_Type);
}