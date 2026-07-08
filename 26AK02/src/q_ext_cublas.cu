/*
 * 【発展課題】n x n 行列 C の乱数生成と C*C を cuBLAS で計算
 * シミュレーション特論 第2回レポート課題 (26AK02)
 */
#include <cublas_v2.h>
#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define CUDA_CHECK(call)                                                       \
    do {                                                                       \
        cudaError_t err = (call);                                              \
        if (err != cudaSuccess) {                                              \
            fprintf(stderr, "CUDA error %s:%d: %s\n", __FILE__, __LINE__,     \
                    cudaGetErrorString(err));                                  \
            exit(1);                                                           \
        }                                                                      \
    } while (0)

#define CUBLAS_CHECK(call)                                                     \
    do {                                                                       \
        cublasStatus_t st = (call);                                            \
        if (st != CUBLAS_STATUS_SUCCESS) {                                     \
            fprintf(stderr, "cuBLAS error %s:%d: status=%d\n", __FILE__,     \
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

static void dgemm_gpu(cublasHandle_t handle, int n, const double *dA,
                      const double *dB, double *dC)
{
    const double alpha = 1.0;
    const double beta = 0.0;
    CUBLAS_CHECK(cublasDgemm(handle, CUBLAS_OP_N, CUBLAS_OP_N, n, n, n, &alpha,
                             dA, n, dB, n, &beta, dC, n));
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
    double *hB = (double *)malloc(nn * sizeof(double));
    double hC0;
    if (!hA || !hB) {
        fprintf(stderr, "Host allocation failed for n=%d\n", n);
        return 1;
    }

    double *dA = NULL;
    double *dB = NULL;
    double *dC = NULL;
    cublasHandle_t handle;

    CUDA_CHECK(cudaMalloc((void **)&dA, nn * sizeof(double)));
    CUDA_CHECK(cudaMalloc((void **)&dB, nn * sizeof(double)));
    CUDA_CHECK(cudaMalloc((void **)&dC, nn * sizeof(double)));
    CUBLAS_CHECK(cublasCreate(&handle));

    printf("=== Matrix multiplication C * C (cuBLAS) ===\n");
    printf("n = %d, trials = %d\n", n, ntrials);
    printf("Timing: wall clock time (CLOCK_MONOTONIC, includes H2D/D2H)\n\n");

    srand((unsigned int)time(NULL));
    fill_random(hA, n);
    fill_random(hB, n);
    CUDA_CHECK(cudaMemcpy(dA, hA, nn * sizeof(double), cudaMemcpyHostToDevice));
    CUDA_CHECK(cudaMemcpy(dB, hB, nn * sizeof(double), cudaMemcpyHostToDevice));
    dgemm_gpu(handle, n, dA, dB, dC);
    CUDA_CHECK(cudaDeviceSynchronize());

    double t_sum = 0.0;
    double t_min = 0.0;
    double t_max = 0.0;

    for (t = 0; t < ntrials; t++) {
        srand((unsigned int)(time(NULL) + t));
        fill_random(hA, n);

        const double t0 = now_seconds();
        CUDA_CHECK(cudaMemcpy(dA, hA, nn * sizeof(double), cudaMemcpyHostToDevice));
        dgemm_gpu(handle, n, dA, dA, dC);
        CUDA_CHECK(cudaDeviceSynchronize());
        CUDA_CHECK(cudaMemcpy(&hC0, dC, sizeof(double), cudaMemcpyDeviceToHost));
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

    cublasDestroy(handle);
    cudaFree(dA);
    cudaFree(dB);
    cudaFree(dC);
    free(hA);
    free(hB);
    return 0;
}
