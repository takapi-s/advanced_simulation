/*
 * 【1】(1) 連立一次方程式 A x = b を共役勾配法で解く
 * シミュレーション特論 第2回レポート課題 (26AK02)
 */
#include <math.h>
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

static const double b[N] = {7.0, 9.0, 9.0, 21.0, 23.0};

static void matvec(const double A_mat[N][N], const double x[N], double y[N])
{
    int i, j;
    for (i = 0; i < N; i++) {
        y[i] = 0.0;
        for (j = 0; j < N; j++) {
            y[i] += A_mat[i][j] * x[j];
        }
    }
}

static double dot(const double u[N], const double v[N])
{
    int i;
    double s = 0.0;
    for (i = 0; i < N; i++) {
        s += u[i] * v[i];
    }
    return s;
}

int main(void)
{
    const double tol = 1.0e-12;
    const int max_iter = 1000;

    double x[N] = {0.0, 0.0, 0.0, 0.0, 0.0};
    double r[N], p[N], Ap[N];
    int k, i;
    int converged_iter = -1;

    matvec(A, x, r);
    for (i = 0; i < N; i++) {
        r[i] = b[i] - r[i];
        p[i] = r[i];
    }

    printf("=== Conjugate Gradient Method ===\n");
    printf("Matrix size: %d\n", N);
    printf("Initial x: ");
    for (i = 0; i < N; i++) {
        printf("% .6e", x[i]);
    }
    printf("\n");
    printf("Convergence criterion: ||r||_2 < %.1e\n", tol);
    printf("\n");

    double rsold = dot(r, r);
    for (k = 0; k < max_iter; k++) {
        if (sqrt(rsold) < tol) {
            converged_iter = k;
            break;
        }

        matvec(A, p, Ap);
        const double alpha = rsold / dot(p, Ap);

        for (i = 0; i < N; i++) {
            x[i] += alpha * p[i];
            r[i] -= alpha * Ap[i];
        }

        const double rsnew = dot(r, r);
        const double beta = rsnew / rsold;
        rsold = rsnew;

        for (i = 0; i < N; i++) {
            p[i] = r[i] + beta * p[i];
        }
    }

    if (converged_iter >= 0) {
        printf("Converged at iteration %d (||r|| = %.6e)\n",
               converged_iter, sqrt(rsold));
    } else {
        printf("Warning: did not converge within %d iterations (||r|| = %.6e)\n",
               max_iter, sqrt(rsold));
        converged_iter = max_iter;
    }

    printf("\nSolution x:\n");
    for (i = 0; i < N; i++) {
        printf("  x[%d] = % .10e\n", i, x[i]);
    }

    printf("\nResidual check (b - A x):\n");
    matvec(A, x, Ap);
    for (i = 0; i < N; i++) {
        printf("  % .6e\n", b[i] - Ap[i]);
    }

    return 0;
}
