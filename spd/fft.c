#include <float.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#include <fftw3.h>

struct cand {
    size_t index;
    double value;
};

/* cand.value is always positive */
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

int main(int argc, char **argv)
{
    fftw_complex *data;
    fftw_plan p;
    unsigned flags;
    size_t i, j, N, ndata;
    char line[256];
    const size_t ncands = 10;
    struct cand cands[ncands];
    double v;

    if (argc != 3) {
        exit(1);
    }
    N = atoi(argv[1]);
    ndata = atoi(argv[2]);

    data = fftw_malloc(N * sizeof *data);
    for (i = 0; i < N; i += 1) {
        data[i][0] = 0;
        data[i][1] = 0;
    }

    for (i = 0; i < ndata; i += 1) {
        fgets(line, sizeof line, stdin);
        sscanf(line, "%lu", &j);
        fgets(line, sizeof line, stdin);
        sscanf(line, "(%lf, %lf)", &data[j][0], &data[j][1]);
    }

    flags = FFTW_ESTIMATE | FFTW_DESTROY_INPUT;
    p = fftw_plan_dft_1d(N, data, data, FFTW_BACKWARD, flags);

    fprintf(stderr, "computing... ");
    fflush(stderr);
    fftw_execute(p);
    fprintf(stderr, "done\n");

    for (i = 0; i < ncands; i += 1) {
        cands[i].index = 0;
        cands[i].value = 0;
    }

    for (i = 0; i < N; i += 1) {
        v = data[i][0]*data[i][0] + data[i][1]*data[i][1];
        if (v > cands[0].value) {
            cands[0].index = i;
            cands[0].value = v;
            qsort(cands, ncands, sizeof cands[0], cmpcand);
        }
    }

    for (i = 0; i < ncands; i += 1) {
        printf("%lu\n", cands[i].index);
    }

    fftw_destroy_plan(p);
    fftw_free(data);

    return 0;
}
