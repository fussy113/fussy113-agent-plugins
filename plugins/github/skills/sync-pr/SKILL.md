---
name: sync-pr
description: PRがbaseブランチとconflictしたときに、baseブランチへrebaseしてコンフリクトを解消し、force pushする。GitHub CLIが必要
argument-hint: "[PR番号 (optional)]"
allowed-tools: Bash(gh *) Bash(git *) Read Grep Glob Edit
---

# PR の base 追従 (rebase + force push)

PRがbaseブランチとconflictしているとき、baseブランチへrebaseしてコンフリクトを解消し、force pushします。作業範囲は**rebaseとコンフリクト解消、push だけ**です。CI失敗やレビューコメントへの対応は `fix-pr` に渡し、気づいた改善点は提示に留めます。

## 完了条件

rebaseが完了し、プロジェクトの lint/test を実行済みで、手順6のサマリーが出力されていれば完了とする。force push は履歴を書き換える外部への書き込みのため、ユーザーの承認を得てから実行する。承認が得られない場合は push 前の状態で止めてサマリーを出す。

## 進め方の伝え方

- 最初のツール呼び出し前に、これから何をするかを1文で述べる。
- 作業中は、コンフリクトの発生や解消方針の変更など重要なときだけ短く報告する。
- 完了時は結論から始める。

## 前提条件の確認

```bash
gh auth status
git status --porcelain
```

未認証なら `gh auth login` を案内して中断する。作業ツリーに未コミットの変更がある場合も、rebase で失われないよう中断してユーザーに対処を求める。

## 実行手順

### 1. PRの特定と情報取得

`$ARGUMENTS` があればPR番号として使い、なければ現在のブランチのPRを検出する。

```bash
gh pr view <PR番号> --json number,baseRefName,headRefName,mergeable,isCrossRepository
```

- baseブランチは `main` に決め打ちせず、取得した `baseRefName` を使う。
- `isCrossRepository` が true(forkからのPR)の場合は、pushできるとは限らないため中断して報告する。
- `mergeable` が `MERGEABLE` でコンフリクトが無い場合も、rebaseの要否をユーザーに確認してから進める。

### 2. rebase

```bash
gh pr checkout <PR番号>
git fetch origin <baseRefName>
git rebase origin/<baseRefName>
```

### 3. コンフリクトの解消

コンフリクトが出たら、`git status` で対象ファイルを特定し、双方の意図を把握してから解消する。base側の変更は `git log origin/<baseRefName> -- <file>`、PR側の意図は `gh pr diff` とコミットメッセージで確認する。解消後は `git add` して `git rebase --continue` で進める。

どちらを採用すべきか意図から判断できない箇所がある場合は、推測で解消せず `git rebase --abort` してコンフリクトの内容をユーザーに報告する。

### 4. ローカル検証

プロジェクト設定(`package.json` の `scripts`、`Makefile`、`pyproject.toml` 等)から lint・test コマンドを検出して実行する。失敗した場合は、rebaseに起因するものかを切り分けて報告する。

### 5. force push

ここから先は履歴を書き換える外部への書き込みです。ファイルごとの解消方針と `git range-diff origin/<baseRefName>...HEAD` で見たPR差分の変化を提示し、確認を得てから実行してください。

```bash
git push --force-with-lease
```

`--force` は使わず、`--force-with-lease` で他者の更新を上書きしないようにする。リモートが更新されていて拒否された場合は、状況を報告して指示を仰ぐ。

### 6. 結果サマリーの出力

```markdown
# sync-pr 実行結果サマリー

**結論**: [1行。例: origin/main へ rebase、2ファイルのコンフリクトを解消して push 済み]

## コンフリクト解消

| ファイル | 採用方針 |
|---|---|
| [path/to/file] | [解消内容] |

## 検証

[実行したコマンドと結果]

## push

[push 済み / 承認待ちで未実行 / 中断した理由]
```

コンフリクトが無かった場合は「コンフリクト解消」セクションを省略する。

## 使用例

```
/github:sync-pr 42
```

## 関連

- `fix-pr` — CI失敗・レビューコメントへの対応。
