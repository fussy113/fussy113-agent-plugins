# github

対応: Claude Code / Codex

`gh` CLI を使って、PR まわりの定型作業(作成・CI 失敗の修正・依存関係更新 PR のレビュー)を支援するスキル集。

## 構成

| スキル | 役割 |
|---|---|
| `/github:quick-pr` | 現在の変更からブランチ作成・コミット・push・Draft PR 作成までを一括実行する |
| `/github:fix-pr` | PR の CI 失敗やレビューコメントを調査し、修正・コミット・返信・スレッド解決を行う |
| `/github:review-dep-pr` | 依存関係更新 PR(Dependabot・Renovate・手動更新のいずれも)を依存関係更新の観点からレビューする |

## 使い方

```bash
# 変更を Draft PR にする
/github:quick-pr

# PR の CI 失敗・レビューコメントに対応する
/github:fix-pr 42

# 依存関係更新 PR をレビューする
/github:review-dep-pr 42
```

## 設計思想

- **`gh` CLI 前提**。インストール・認証済みであることを各スキルが前提条件として確認する。
- **外部への書き込みは承認境界を挟む**。push・PR 作成・コメント返信・スレッド解決のような他者に見える操作は、ローカルな修正・コミットとは分けて確認を取る。
- **レビューと修正を分離**。`review-dep-pr` はレビューのみを行い、修正が必要なら `fix-pr` に渡す。

## 関連

- `dep-manager` の `/dep-manager:migrate-dependabot` / `/dep-manager:tune-renovate` — 依存更新の設定自体(Dependabot→Renovate 移行、cooldown/automerge 等)を調整したい場合。
