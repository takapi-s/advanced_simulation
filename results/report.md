---
title: "2026 年度「シミュレーション特論」第 1 回レポート課題"
---

## システム情報

| 項目 | 値 |
|------|-----|
| 計算ノード名 | ysnd00.edu.tut.ac.jp |
| CPU | AMD EPYC 9254 24-Core Processor（2ソケット、48コア） |
| メモリ量 | 250 GiB |

## 【1】グリッドサイズと性能（OMP_NUM_THREADS=1, -O2）

コンパイルコマンド:

```bash
icx -fopenmp -std=gnu89 -O2 -o bin/himeno_omp src/himenoBMTxpa.c
```

実行コマンド（例）:

```bash
export OMP_NUM_THREADS=1
./bin/himeno_omp S   # M, L も同様
```

| Grid size | CPU time (sec.) | Loop executed | MFLOPS |
|-----------|-----------------|---------------|--------|
| S | 0.943088 | 115 | 2008.07 |
| M | 59.229043 | 858 | 1986.12 |
| L | 60.139006 | 101 | 1878.80 |

## 【2】最適化オプション（Grid=S, OMP_NUM_THREADS=1）

コンパイルコマンド（測定ごとに最適化オプションを変えて再コンパイル）:

```bash
icx -fopenmp -std=gnu89 -O0 -o bin/himeno_omp src/himenoBMTxpa.c
icx -fopenmp -std=gnu89 -O1 -o bin/himeno_omp src/himenoBMTxpa.c
icx -fopenmp -std=gnu89 -O2 -o bin/himeno_omp src/himenoBMTxpa.c
icx -fopenmp -std=gnu89 -O3 -o bin/himeno_omp src/himenoBMTxpa.c
```

実行コマンド:

```bash
export OMP_NUM_THREADS=1
./bin/himeno_omp S
```

| Option | CPU time (sec.) | Loop executed | MFLOPS |
|--------|-----------------|---------------|--------|
| -O0 | 57.237897 | 1461 | 420.34 |
| -O1 | 48.274247 | 6630 | 2261.68 |
| -O2 | 49.703904 | 6045 | 2002.80 |
| -O3 | 49.476148 | 6031 | 2007.36 |

## 【3】OpenMP スレッド数（Grid=S, -O2）

コンパイルコマンド:

```bash
icx -fopenmp -std=gnu89 -O2 -o bin/himeno_omp src/himenoBMTxpa.c
```

実行コマンド（例）:

```bash
export OMP_NUM_THREADS=1   # 2, 4, 8 も同様
./bin/himeno_omp S
```

| Number of OpenMP threads | CPU time (sec.) | Loop executed | MFLOPS |
|--------------------------|-----------------|---------------|--------|
| 1 | 49.915502 | 6075 | 2004.21 |
| 2 | 40.914857 | 10099 | 4064.72 |
| 4 | 31.634604 | 14898 | 7755.30 |
| 8 | 17.128982 | 14860 | 14286.31 |

## 【発展課題】MPI プロセス数（Grid=S）

コンパイル手順:

1. `Makefile.sample` を `Makefile` にコピーし、`CC = mpicc` を `CC = mpicc -cc=icx` に変更
2. `CFLAGS = -O3` を `CFLAGS = -O3 -std=gnu89` に変更
3. プロセス数に応じて `./paramset.sh S <x> <y> <z>` を実行
4. `make` でビルド

実行コマンド（例）:

```bash
module load intelmpi/2025
./paramset.sh S 2 2 2
make
mpirun -np 8 ./bmt
```

| Number of MPI processes | CPU time (sec.) | Loop executed | MFLOPS |
|-------------------------|-----------------|---------------|--------|
| 1 | 58.945497 | 77996 | 21789.86 |
| 2 | 53.178672 | 138258 | 42813.98 |
| 4 | 47.673682 | 250549 | 86545.96 |
| 8 | 37.696982 | 337259 | 147329.53 |

プロセス分割: 1→(1,1,1), 2→(2,1,1), 4→(2,2,1), 8→(2,2,2)
