# fussy113 agent plugins

Claude Code / Codex の両方から使えるプラグインマーケットプレース。

## 導入

### Claude Code

```
/plugin marketplace add fussy113/fussy113-agent-plugins
/plugin install github@fussy113-plugins
```

### Codex

```
codex plugin marketplace add fussy113/fussy113-agent-plugins --ref main
codex plugin add github@fussy113-plugins
```

Codex はプラグイン追加後、**新しいスレッド**を開始するとスキルを認識する。

## プラグイン一覧

| プラグイン | 対応 | 内容 |
|---|---|---|
| [github](plugins/github) | Claude Code / Codex | PR 作成・CI 失敗の修正・Dependabot PR レビュー |
| [dep-manager](plugins/dep-manager) | Claude Code / Codex | Renovate 設定・mise 環境整合 |
| [dev-discipline](plugins/dev-discipline) | Claude Code / Codex | 仕様駆動・TDD・体系的デバッグ |
| [guardrail](plugins/guardrail) | Claude Code / Codex | 危険コマンドのブロック・シークレット検出フック |
| [token-ops](plugins/token-ops) | Claude Code のみ | effort/モデル見積もり・トークン消費の可視化 |
| [self-improve](plugins/self-improve) | Claude Code のみ | セッションをまたいだ自己学習フィードバックループ |

各プラグインの詳細は個別の README を参照。

## 構成

両ホストで同じ `plugins/<name>/skills/` と `plugins/<name>/hooks/` を共有し、ホストごとのマニフェストだけを分けている(デュアルマニフェスト方式)。

```
plugins/<name>/
├── .claude-plugin/plugin.json   # Claude Code 用マニフェスト
├── .codex-plugin/plugin.json    # Codex 用マニフェスト(両対応プラグインのみ)
├── skills/                      # 共有
└── hooks/                       # 共有
```

- Claude Code のマーケットプレース定義: `.claude-plugin/marketplace.json`
- Codex のマーケットプレース定義: `.agents/plugins/marketplace.json`

新しいプラグインを両対応にするときは、`.codex-plugin/plugin.json` と `.agents/plugins/marketplace.json` のエントリを両方追加する。

## 検証

```
pnpm run validate        # Claude Code 側
pnpm run validate:codex  # Codex 側
```
