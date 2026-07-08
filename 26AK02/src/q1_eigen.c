/*
 * 【1】(2) 固有値問題 A x = lambda x を LAPACK dsyev で解く
 * シミュレーション特論 第2回レポート課題 (26AK02)
 */
#include <math.h>
#include <mkl_lapacke.h>
#include <stdio.h>
#include <stdlib.h>

#define N 5

static const double A[N][N] = {
    {3.0, 1.0, 0.0, 0.0, 0.0},
    {1.0, 2.0, 1.0, 0.0, 0.0},
    {0.0, 1.0, 1.0, 1.0, 0.0},
    {0.0, 0.0, 1.0, 4.0, 1.0},
    {0.0, 0.0, 0.0, 1.0, 5.0},
};

static void to_lapack_colmajor(double *a, const double src[N][N])
{
    int i, j;
    for (j = 0; j < N; j++) {
        for (i = 0; i < N; i++) {
            a[i + j * N] = src[i][j];
        }
    }
}

static double vec_norm2(const double *v, int n)
{
    int i;
    double s = 0.0;
    for (i = 0; i < n; i++) {
        s += v[i] * v[i];
    }
    return sqrt(s);
}

int main(void)
{
    double a[N * N];
    double w[N];
    int info;
    int i, j;

    to_lapack_colmajor(a, A);

    info = LAPACKE_dsyev(LAPACK_COL_MAJOR, 'V', 'U', N, a, N, w);
    if (info != 0) {
        fprintf(stderr, "LAPACKE_dsyev failed with info = %d\n", info);
        return 1;
    }

    printf("=== Eigenvalue Problem (LAPACK dsyev) ===\n");
    printf("Matrix size: %d\n", N);
    printf("Eigenvectors are normalized to Euclidean norm 1.\n\n");

    for (i = 0; i < N; i++) {
        const double *vec = &a[i * N];
        const double norm = vec_norm2(vec, N);
        printf("Eigenvalue lambda[%d] = % .10e\n", i, w[i]);
        printf("Eigenvector x[%d]: ", i);
        for (j = 0; j < N; j++) {
            const double v = vec[j] / norm;
            printf("% .10e", v);
            if (j < N - 1) {
                printf(", ");
            }
        }
        printf("\n");
        printf("  ||x||_2 = % .10e\n\n", vec_norm2(vec, N) / norm);
    }

    return 0;
}
