# シミュレーション特論 第2回レポート課題 (26AK02)

連立一次方程式・固有値問題・行列積 (BLAS/LAPACK) の数値計算課題です。

## 課題概要

| 課題 | 内容 |
|------|------|
| 【1】(1) | 5×5 連立一次方程式を共役勾配法で求解 |
| 【1】(2) | 固有値問題を LAPACK `dsyev` で求解 |
| 【2】(1) | n×n 乱数行列の B×B を DGEMM で計算 |
| 【2】(2) | n = 2000〜10000 で計算時間を測定しスケーリングを解析 |
| 発展（任意） | GPU (cuBLAS / rocBLAS) による行列積 |

## プロジェクト構成

```
26AK02/
├── README.md
├── Makefile
├── src/
│   ├── q1_cg.c           # 【1】(1) 共役勾配法
│   ├── q1_eigen.c        # 【1】(2) 固有値問題
│   ├── q2_gemm.c         # 【2】行列積 (DGEMM)
│   ├── q_ext_cublas.cu   # 発展課題 (cuBLAS)
│   └── q_ext_rocblas.cpp # 発展課題 (rocBLAS)
├── scripts/
│   ├── compile.sh
│   ├── run_q1.sh
│   └── run_q2_benchmark.sh
├── jobs/
│   ├── run_q1.pbs
│   ├── run_q2.pbs
│   ├── run_ext_cublas.pbs
│   └── run_ext_rocblas.pbs
└── results/
    ├── raw/              # 実行ログ
    └── report_templates.md
```

## 使い方（HPC クラスタ）

```bash
cd ~/advanced_simulation_26AK01/26AK02
module load intel/2025
bash scripts/compile.sh
```

### 【1】実行（軽量・窓口サーバでも可）

```bash
bash scripts/run_q1.sh
# または
make run_q1
```

### 【2】ベンチマーク（計算ノードで測定）

課題の指示どおり、計算時間は `qsub` で計算サーバ上で測定してください。

```bash
qsub jobs/run_q1.pbs
qsub jobs/run_q2.pbs
qsub jobs/run_ext_rocblas.pbs   # AMD GPU (Eduq)
qsub jobs/run_ext_cublas.pbs    # NVIDIA GPU (iEduq)
qstat
```

結果は `results/raw/` に保存されます。

### 手動で単一サイズを試す場合

```bash
./bin/q2_gemm 2000 5    # n=2000, 5 回測定
```

## コンパイルコマンド（レポート記載用）

```bash
module load intel/2025
icx -O2 -std=c11 -o bin/q1_cg src/q1_cg.c -lm
icx -O2 -std=c11 -o bin/q1_eigen src/q1_eigen.c -mkl
icx -O2 -std=c11 -I$MKLROOT/include -o bin/q2_gemm src/q2_gemm.c -mkl -lm
```

## レポートに記載する情報

- 計算ノード名 (`hostname`)
- CPU 型番 (`lscpu`)
- メモリ量 (`free -h`)
- CPU time / wall clock time のどちらを使ったか
- 各問の数値結果

テンプレート: `results/report_templates.md`

## 参考リンク

- [DGEMM チュートリアル](https://github.com/nakatamaho/dgemm_tutorial/blob/main/03_pre_dgemm.md)
- [TUT HPC コンパイル方法](https://hpcportal.imc.tut.ac.jp/wiki/HowToCompile)
- [TUT HPC ジョブ投入](https://hpcportal.imc.tut.ac.jp/wiki/HowToSubmitJob)
