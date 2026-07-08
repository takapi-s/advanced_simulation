/*
 * 【発展課題】n x n 行列 C の乱数生成と C*C を rocBLAS で計算
 * シミュレーション特論 第2回レポート課題 (26AK02)
 */
#include <hip/hip_runtime.h>
#include <rocblas/rocblas.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define HIP_CHECK(call)                                                        \
    do {                                                                       \
        hipError_t err = (call);                                               \
        if (err != hipSuccess) {                                               \
            fprintf(stderr, "HIP error %s:%d: %s\n", __FILE__, __LINE__,     \
                    hipGetErrorString(err));                                   \
            exit(1);                                                           \
        }                                                                      \
    } while (0)

#define ROCBLAS_CHECK(call)                                                    \
    do {                                                                       \
        rocblas_status st = (call);                                            \
        if (st != rocblas_status_success) {                                    \
            fprintf(stderr, "rocBLAS error %s:%d: status=%d\n", __FILE__,    \
                    __LINE__, (int)st);                                        \
            exit(1);                                                           \
        }                                                                      \
    } while (0)

static double now_seconds(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec + (double)ts.tv_nsec * 1.0e-9;
}

static void fill_random(double *mat, int n)
{
    const int total = n * n;
    int i;
    for (i = 0; i < total; i++) {
        mat[i] = (double)rand() / (double)RAND_MAX;
    }
}

static int parse_int(const char *s, int *out)
{
    char *end = NULL;
    const long v = strtol(s, &end, 10);
    if (end == s || *end != '\0' || v <= 0) {
        return -1;
    }
    *out = (int)v;
    return 0;
}

static void dgemm_gpu(rocblas_handle handle, int n, const double *dA,
                      const double *dB, double *dC)
{
    const double alpha = 1.0;
    const double beta = 0.0;
    ROCBLAS_CHECK(rocblas_dgemm(handle, rocblas_operation_none,
                                rocblas_operation_none, n, n, n, &alpha, dA, n,
                                dB, n, &beta, dC, n));
}

int main(int argc, char **argv)
{
    int n = 4000;
    int ntrials = 5;
    int t;

    if (argc >= 2 && parse_int(argv[1], &n) != 0) {
        fprintf(stderr, "Usage: %s [n] [ntrials]\n", argv[0]);
        return 1;
    }
    if (argc >= 3 && parse_int(argv[2], &ntrials) != 0) {
        fprintf(stderr, "Usage: %s [n] [ntrials]\n", argv[0]);
        return 1;
    }

    const size_t nn = (size_t)n * (size_t)n;
    double *hA = (double *)malloc(nn * sizeof(double));
    double hC0;
    if (!hA) {
        fprintf(stderr, "Host allocation failed for n=%d\n", n);
        return 1;
    }

    double *dA = NULL;
    double *dC = NULL;
    rocblas_handle handle;

    HIP_CHECK(hipMalloc((void **)&dA, nn * sizeof(double)));
    HIP_CHECK(hipMalloc((void **)&dC, nn * sizeof(double)));
    ROCBLAS_CHECK(rocblas_create_handle(&handle));

    printf("=== Matrix multiplication C * C (rocBLAS) ===\n");
    printf("n = %d, trials = %d\n", n, ntrials);
    printf("Timing: wall clock time (CLOCK_MONOTONIC, includes H2D/D2H)\n\n");

    srand((unsigned int)time(NULL));
    fill_random(hA, n);
    HIP_CHECK(hipMemcpy(dA, hA, nn * sizeof(double), hipMemcpyHostToDevice));
    dgemm_gpu(handle, n, dA, dA, dC);
    HIP_CHECK(hipDeviceSynchronize());

    double t_sum = 0.0;
    double t_min = 0.0;
    double t_max = 0.0;

    for (t = 0; t < ntrials; t++) {
        srand((unsigned int)(time(NULL) + t));
        fill_random(hA, n);

        const double t0 = now_seconds();
        HIP_CHECK(hipMemcpy(dA, hA, nn * sizeof(double), hipMemcpyHostToDevice));
        dgemm_gpu(handle, n, dA, dA, dC);
        HIP_CHECK(hipDeviceSynchronize());
        HIP_CHECK(hipMemcpy(&hC0, dC, sizeof(double), hipMemcpyDeviceToHost));
        const double t1 = now_seconds();
        const double elapsed = t1 - t0;

        if (t == 0) {
            t_min = t_max = elapsed;
        } else {
            if (elapsed < t_min) {
                t_min = elapsed;
            }
            if (elapsed > t_max) {
                t_max = elapsed;
            }
        }
        t_sum += elapsed;
        printf("trial %d: %.6f sec\n", t + 1, elapsed);
    }

    printf("\nSummary:\n");
    printf("  average = %.6f sec\n", t_sum / (double)ntrials);
    printf("  min     = %.6f sec\n", t_min);
    printf("  max     = %.6f sec\n", t_max);
    printf("  C[0][0] = %.10e (sanity check)\n", hC0);

    rocblas_destroy_handle(handle);
    hipFree(dA);
    hipFree(dC);
    free(hA);
    return 0;
}
