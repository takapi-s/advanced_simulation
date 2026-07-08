# レポート用 結果テンプレート

測定後、`bash scripts/parse_output.sh results/raw/*.log` の出力を各表に転記してください。

---

## システム情報（全課題共通で記載）

| 項目 | 値 |
|------|-----|
| 計算ノード名 | （hostname の出力） |
| CPU | （lscpu の Model name） |
| メモリ量 | （free -h の total） |
| コンパイルコマンド | `icx -fopenmp -O2 -o bin/himeno_omp src/himenoBMTxpa.c` |

---

## 【1】グリッドサイズと性能（OMP_NUM_THREADS=1, -O2）

| Grid size | CPU time (sec.) | Loop executed | MFLOPS |
|-----------|-----------------|---------------|--------|
| S | | | |
| M | | | |
| L | | | |

ログ: `results/raw/task1_S_t1.log`, `task1_M_t1.log`, `task1_L_t1.log`

---

## 【2】最適化オプション（Grid=S, OMP_NUM_THREADS=1）

| Option | CPU time (sec.) | Loop executed | MFLOPS |
|--------|-----------------|---------------|--------|
| -O0 | | | |
| -O1 | | | |
| -O2 | | | |
| -O3 | | | |

ログ: `results/raw/task2_O0_t1.log` 〜 `task2_O3_t1.log`

---

## 【3】OpenMP スレッド数（Grid=S, -O2）

| Number of OpenMP threads | CPU time (sec.) | Loop executed | MFLOPS |
|--------------------------|-----------------|---------------|--------|
| 1 | | | |
| 2 | | | |
| 4 | | | |
| 8 | | | |

ログ: `results/raw/task3_t1.log` 〜 `task3_t8.log`

---

## 【発展課題】MPI プロセス数（Grid=S, 任意）

| Number of MPI processes | CPU time (sec.) | Loop executed | MFLOPS |
|-------------------------|-----------------|---------------|--------|
| 1 | | | |
| 2 | | | |
| 4 | | | |
| 8 | | | |

ログ: `results/raw/mpi_S_p*.log`

---

## 結果抽出コマンド

```bash
# 課題1
bash scripts/parse_output.sh results/raw/task1_*.log

# 課題2
bash scripts/parse_output.sh results/raw/task2_*.log

# 課題3
bash scripts/parse_output.sh results/raw/task3_*.log

# 発展課題
bash scripts/parse_output.sh results/raw/mpi_*.log
```
