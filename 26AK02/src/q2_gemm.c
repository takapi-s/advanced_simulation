/*
 * 【2】n x n 行列 B の乱数生成と B*B の計算（MKL/CBLAS DGEMM）
 * シミュレーション特論 第2回レポート課題 (26AK02)
 *
 * 使用例:
 *   ./q2_gemm 2000
 *   ./q2_gemm 2000 5          # 5 回測定
 */
#define _POSIX_C_SOURCE 200809L

#include <mkl_cblas.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static double now_seconds(void)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return (double)ts.tv_sec + (double)ts.tv_nsec * 1.0e-9;
}

static void fill_random(double *mat, int n)
{
    int i;
    const int total = n * n;
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

int main(int argc, char **argv)
{
    int n = 2000;
    int ntrials = 1;
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
    double *B = (double *)malloc(nn * sizeof(double));
    double *C = (double *)malloc(nn * sizeof(double));
    if (!B || !C) {
        fprintf(stderr, "Memory allocation failed for n = %d\n", n);
        free(B);
        free(C);
        return 1;
    }

    printf("=== Matrix multiplication B * B (DGEMM) ===\n");
    printf("n = %d, trials = %d\n", n, ntrials);
    printf("Timing: wall clock time (CLOCK_MONOTONIC)\n\n");

    /* MKL 初期化・ページフォルトの影響を除く */
    fill_random(B, n);
    cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans,
                n, n, n, 1.0, B, n, B, n, 0.0, C, n);

    double t_sum = 0.0;
    double t_min = 0.0;
    double t_max = 0.0;

    for (t = 0; t < ntrials; t++) {
        srand((unsigned int)(time(NULL) + t));

        fill_random(B, n);
        fill_random(C, n);

        const double t0 = now_seconds();
        cblas_dgemm(CblasRowMajor, CblasNoTrans, CblasNoTrans,
                    n, n, n, 1.0, B, n, B, n, 0.0, C, n);
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
    printf("  C[0][0] = %.10e (sanity check)\n", C[0]);

    free(B);
    free(C);
    return 0;
}
