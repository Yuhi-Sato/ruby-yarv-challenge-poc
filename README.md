# Ruby YARV Challenge

ブラウザ上でも、ローカル環境でも動く Ruby VM (YARV) & コンパイラ実装ワークショップです。
RubyKaigi LT 参加者が Fibonacci 関数を独自実装した YARV VM で動かすことを最終目標とします。

## 最終目標

```ruby
def fib(n)
  if n < 2
    n
  else
    fib(n - 1) + fib(n - 2)
  end
end
fib(10)  # => 55
```

---

## クイックスタート

### ブラウザで動かす（推奨）

```bash
npm install
npm run dev   # http://localhost:5173 で起動
```

### ローカルで動かす（Ruby 環境）

```bash
gem install yruby   # yruby gem をインストール
ruby scripts/run_challenge.rb        # 全ステップのテストを実行
ruby scripts/run_challenge.rb 1      # ステップ 1 のみテスト
ruby scripts/run_challenge.rb 1 3    # ステップ 1〜3 をテスト
```

実装ファイルは `src/ruby/stubs/` にあります。ファイルを編集してテストを実行してください。

---

## チュートリアル

各ステップで **VM 命令** と **コンパイラメソッド** をセットで実装します。
ステップは積み上がる構造になっており、ステップ N を実行すると 1〜N のコードがまとめて使われます。

---

### Step 1: Integer Literals — スタックに値を積む

**VM 命令: `putobject`**

YARV はスタックマシンです。すべての値はスタックを経由して流れます。

- `putobject` はリテラル値をスタックに積みます
- `vm.push(value)` を使って積んでください

**コンパイラ: `compile_integer_node`**

- `Prism::IntegerNode` は整数リテラル（例: `42`）を表します
- `node.value` に整数が入っています — `iseq.emit(Putobject, node.value)` を emit してください

**期待するバイトコード（`42` の場合）:**

```
0000 putobject 42
0002 leave
```

**テストケース:**

| 入力 | 期待する結果 |
|------|-------------|
| `42` | `42` |
| `100` | `100` |
| `0` | `0` |

**ヒント:**
1. `vm.push(x)` で値をスタックに積む。`iseq.emit(InsnClass, *operands)` で命令を追加する。
2. Putobject: `vm.push(value)` — Compiler: `iseq.emit(YRuby::Insns::Putobject, node.value)`

---

### Step 2: Addition — 加算

**VM 命令: `opt_plus`**

- `opt_plus` はスタックから 2 値を pop して和を push します
- スタックの覗き方: `vm.topn(2)` = 左辺 (a)、`vm.topn(1)` = 右辺 (b)
- 両方 pop して `a + b` を push

**コンパイラ: `compile_binary_plus`**

- オペランドは `compile_call_node_dispatch` でコンパイル済み
- `iseq.emit(YRuby::Insns::OptPlus)` を emit するだけ

**期待するバイトコード（`1 + 2` の場合）:**

```
0000 putobject 1
0002 putobject 2
0004 opt_plus
0005 leave
```

**テストケース:**

| 入力 | 期待する結果 |
|------|-------------|
| `1 + 2` | `3` |
| `10 + 5` | `15` |
| `0 + 0` | `0` |

**ヒント:**
1. `1 + 2` の場合、`opt_plus` 実行前のスタックは `[1, 2]`。`topn(2)=1`（左）、`topn(1)=2`（右）。両方 pop して和を push。
2. OptPlus: `b = vm.pop; a = vm.pop; vm.push(a + b)` — Compiler: `iseq.emit(YRuby::Insns::OptPlus)`

---

### Step 3: Subtraction — 減算

**VM 命令: `opt_minus`**

- `opt_minus`: `topn(2)` = a（左辺）、`topn(1)` = b（右辺）、`a - b` を push
- **順番が重要！** `a - b`（左 - 右）であって `b - a` ではありません

**コンパイラ: `compile_binary_minus`**

- `compile_binary_plus` と同じパターン。`OptMinus` を emit するだけ

**期待するバイトコード（`10 - 3` の場合）:**

```
0000 putobject 10
0002 putobject 3
0004 opt_minus
0005 leave
```

**テストケース:**

| 入力 | 期待する結果 |
|------|-------------|
| `10 - 3` | `7` |
| `5 - 5` | `0` |
| `100 - 50` | `50` |

**ヒント:**
1. Step 2 と同じスタックパターンだが `a - b` を計算する。`topn(2)` が左辺。順番に注意！
2. OptMinus: `b = vm.pop; a = vm.pop; vm.push(a - b)` — Compiler: `iseq.emit(YRuby::Insns::OptMinus)`

---

### Step 4: Local Variables — ローカル変数

**EP 相対アドレッシング**

ローカル変数はスタック上に置かれ、**EP (Environment Pointer)** を基準にアドレスが決まります。

- `env_read(-idx)` → インデックス idx のローカル変数を読む
- `env_write(-idx, val)` → インデックス idx のローカル変数に書く
- 内部的には: `stack[ep + (-idx)]`

**VM 命令: `getlocal` / `setlocal`**

- **Getlocal(idx)**: `env_read(-idx)` を読んで push
- **Setlocal(idx)**: 値を pop して `env_write(-idx, val)` で書く

**コンパイラ: `compile_local_var_read` / `compile_local_var_write`**

- インデックス参照: `@index_lookup_table[node.name]`
- 書き込み: 値をコンパイルして `Dup` を emit、次に `Setlocal` を emit

**期待するバイトコード（`x = 5; x` の場合）:**

```
0000 putobject 5
0002 dup
0003 setlocal 0
0005 getlocal 0
0007 leave
```

**テストケース:**

| 入力 | 期待する結果 |
|------|-------------|
| `x = 5; x` | `5` |
| `a = 10; b = 20; a + b` | `30` |

**ヒント:**
1. Getlocal は `env_read(-idx)` をスタックに積む。Setlocal は pop して `env_write(-idx, val)` で格納。コンパイラでは `@index_lookup_table[node.name]` で変数インデックスを得る。
2. Getlocal: `vm.push(vm.env_read(-idx))` — Setlocal: `vm.env_write(-idx, vm.pop)` — compile_local_var_write: node.value をコンパイルして Dup → Setlocal の順で emit

---

### Step 5: Comparison — 比較

**VM 命令: `opt_lt`**

- `opt_lt`: `topn(2)` = a（左辺）、`topn(1)` = b（右辺）、`a < b` の結果を push
- `opt_plus` / `opt_minus` と同じスタックパターン

**コンパイラ: `compile_binary_lt`**

- `compile_binary_plus` と同じパターン。`OptLt` を emit するだけ

結果（`true` または `false`）は Step 6 の分岐命令が消費します。

**期待するバイトコード（`3 < 5` の場合）:**

```
0000 putobject 3
0002 putobject 5
0004 opt_lt
0005 leave
```

**テストケース:**

| 入力 | 期待する結果 |
|------|-------------|
| `3 < 5` | `true` |
| `10 < 5` | `false` |
| `5 < 5` | `false` |

**ヒント:**
1. `opt_plus` / `opt_minus` と同じスタックパターンだが、`a < b` のブール値を push。
2. OptLt: `b = vm.pop; a = vm.pop; vm.push(a < b)` — Compiler: `iseq.emit(YRuby::Insns::OptLt)`

---

### Step 6: Control Flow — 条件分岐

**重要な前提知識: PC とオフセット**

VM は命令を **実行する前に** PC を命令長だけ進めます:

```
insn = iseq.fetch(pc)
pc += insn::LEN    ← 先に進む
insn.call(vm, ...) ← その後実行
```

分岐命令は **相対オフセット** を使います: `vm.add_pc(dst)` で現在位置から dst だけ移動。

**VM 命令: `branchunless`**

- 条件を pop して、**偽**（nil または false）なら `vm.add_pc(dst)`

**VM 命令: `jump`**

- 無条件に `vm.add_pc(dst)`

**コンパイラ: `compile_conditional_node`**

**前方参照パッチング** を使います: 先にスペースを確保し、ジャンプ先が決まってからオフセットを書き込む。

```ruby
# 1. 条件式をコンパイル
compile_node(iseq, node.predicate)

# 2. Branchunless のプレースホルダーを確保
br_pc = iseq.size
iseq.emit_placeholder(YRuby::Insns::Branchunless::LEN)

# 3. then ブロックをコンパイル
compile_node(iseq, node.statements)

# 4. Jump のプレースホルダーを確保（else をスキップ）
then_end_pc = iseq.size
iseq.emit_placeholder(YRuby::Insns::Jump::LEN)

# 5. Branchunless を else ラベルにパッチ
else_label = iseq.size
br_offset = else_label - (br_pc + Branchunless::LEN)
iseq.patch_at!(br_pc, Branchunless, br_offset)

# 6. else ブロックをコンパイル
# node.consequent が ElseNode → compile_node(iseq, node.consequent.statements)
# node.consequent が IfNode  → compile_conditional_node(iseq, node.consequent)

# 7. Jump を end ラベルにパッチ
end_label = iseq.size
jump_offset = end_label - (then_end_pc + Jump::LEN)
iseq.patch_at!(then_end_pc, Jump, jump_offset)
```

**期待するバイトコード（`if 3 < 5; 10; else; 20; end` の場合）:**

```
0000 putobject 3
0002 putobject 5
0004 opt_lt
0005 branchunless 2
0007 putobject 10
0009 jump 2
0011 putobject 20
0013 leave
```

**テストケース:**

| 入力 | 期待する結果 |
|------|-------------|
| `if 3 < 5; 10; else; 20; end` | `10` |
| `if 10 < 5; 10; else; 20; end` | `20` |

**ヒント:**
1. Branchunless: 条件を pop して偽なら `vm.add_pc(dst)`。Jump: 常に `vm.add_pc(dst)`。コンパイラのアルゴリズムはチュートリアルの 7 ステップに従う。
2. Branchunless: `val = vm.pop; vm.add_pc(dst) unless val` — Jump: `vm.add_pc(dst)` — Compiler: 上の 7 ステップのパッチングアルゴリズムをそのまま実装

---

### Step 7: Methods & Fibonacci — メソッドと再帰！

**VM 命令: `definemethod`**

- メソッドの iseq を現在のクラスに登録します
- `vm.define_method(mid, iseq)` を使います

**VM 命令: `opt_send_without_block`**

- `vm.sendish(cd)` でメソッド呼び出しをディスパッチします
- レシーバ + 引数で新しいフレームをセットアップ
- メソッドの `leave` 命令が戻り値を push します

**コンパイラ: `compile_def_node`**

- `YRuby::Iseq.iseq_new_method(node)` でメソッド用 iseq をコンパイル
- `Definemethod` + `Putobject(name)` を emit

**コンパイラ: `compile_general_call`**

- `Putself` を emit（レシーバなし呼び出しの暗黙のレシーバ）
- 引数をコンパイルして `CallData` を作り、`OptSendWithoutBlock` を emit

**最終目標: `fib(10) = 55`**

```ruby
def fib(n)
  if n < 2
    n
  else
    fib(n - 1) + fib(n - 2)
  end
end
fib(10)  # => 55
```

**テストケース:**

| 入力 | 期待する結果 |
|------|-------------|
| `def identity(x); x; end; identity(42)` | `42` |
| `def fib(n); if n < 2; n; else; fib(n-1) + fib(n-2); end; end; fib(5)` | `5` |
| `def fib(n); if n < 2; n; else; fib(n-1) + fib(n-2); end; end; fib(10)` | `55` |

**ヒント:**
1. Definemethod: `vm.define_method(mid, iseq)` — OptSendWithoutBlock: `vm.sendish(cd)` — compile_def_node: `YRuby::Iseq.iseq_new_method(node)` でメソッド iseq を作り、Definemethod と `Putobject(node.name)` を emit。
2. compile_general_call: Putself を emit し、引数を `compile_node` でコンパイルして、`YRuby::CallData.new(mid: node.name, argc: node.arguments.arguments.length)` で OptSendWithoutBlock を emit

---

## VM API リファレンス

```ruby
vm.push(x)              # スタックに値を積む
vm.pop                  # スタックから値を取り出す
vm.topn(n)              # 上から n 番目の値を覗く（1 = 一番上）
vm.env_read(-idx)       # ローカル変数を読む
vm.env_write(-idx, v)   # ローカル変数に書く
vm.add_pc(offset)       # PC を相対オフセットだけ移動（分岐用）
vm.define_method(m, iseq)   # メソッドを登録
vm.sendish(cd)          # メソッド呼び出しをディスパッチ
```

## Iseq API リファレンス

```ruby
iseq.emit(InsnClass, *operands)           # 命令を追加
iseq.emit_placeholder(InsnClass::LEN)     # 前方参照用プレースホルダーを確保
iseq.patch_at!(pc, InsnClass, offset)     # プレースホルダーに実際の命令を書き込む
iseq.size                                 # 現在の iseq のサイズ（ジャンプオフセット計算用）

YRuby::Iseq.iseq_new_method(node)         # DefNode からメソッド用 iseq を生成
```

---

## プロジェクト構成

```
src/
├── ruby/
│   ├── system/
│   │   ├── challenge_patch.rb    # YRuby::Compile に Patch モジュールを prepend
│   │   ├── challenge_reset.rb    # 実装メソッドを NotImplementedError で上書き
│   │   └── test_runner.rb        # ChallengeTestRunner クラス
│   └── stubs/                    # 参加者が実装するファイル
│       ├── step1.rb              # Putobject + compile_integer_node
│       ├── step2.rb              # OptPlus + compile_binary_plus
│       ├── step3.rb              # OptMinus + compile_binary_minus
│       ├── step4.rb              # Getlocal/Setlocal + compile_local_var_read/write
│       ├── step5.rb              # OptLt + compile_binary_lt
│       ├── step6.rb              # Branchunless/Jump + compile_conditional_node
│       └── step7.rb              # Definemethod/OptSendWithoutBlock + compile_def_node/compile_general_call
└── ...

scripts/
└── run_challenge.rb              # ローカルテストランナー
```

---

## ローカル開発のセットアップ詳細

### 必要環境

- Ruby 3.3 以上（Prism が組み込み済み）
- `yruby` gem

### セットアップ

```bash
# リポジトリをクローン
git clone https://github.com/Yuhi-Sato/ruby-yarv-challenge-poc
cd ruby-yarv-challenge-poc

# yruby gem をインストール
gem install yruby
```

### テストの実行方法

```bash
# ステップ 1 のテストを実行
ruby scripts/run_challenge.rb 1

# 複数ステップ（1〜3）を実行
ruby scripts/run_challenge.rb 1 3

# 全ステップを実行
ruby scripts/run_challenge.rb
```

### 実装の流れ

1. `src/ruby/stubs/step1.rb` を開く
2. `TODO` コメントを実装に置き換える
3. `ruby scripts/run_challenge.rb 1` でテストを実行
4. 全テストが通ったら次のステップへ

---

## ブラウザ版のセットアップ

```bash
npm install
npm run dev      # http://localhost:5173 で起動
npm run build    # 本番ビルド → ./dist/
npm run preview  # ビルド結果をローカルでプレビュー
```

静的ホスティング（Vercel、GitHub Pages、Cloudflare Pages 等）に `./dist/` をデプロイするだけで公開できます。

---

## アーキテクチャ

### コード積み上げモデル（Accumulation Model）

ステップ N のテストを実行すると、ステップ 1〜N の実装がすべて結合されて実行されます。

```
challenge_patch.rb      # Patch モジュールを YRuby::Compile に prepend
    ↓
challenge_reset.rb      # 実装メソッドを NotImplementedError で上書き
    ↓
step1.rb                # 参加者の Step 1 実装（再上書き）
step2.rb                # 参加者の Step 2 実装
...
stepN.rb                # 参加者の現在ステップ実装
    ↓
テスト実行
```

### 参考リンク

- **yruby gem**: https://github.com/Yuhi-Sato/yruby
- **Ruby WASM**: https://github.com/ruby/ruby.wasm
