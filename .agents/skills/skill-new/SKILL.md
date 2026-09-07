---
name: skill-new
description: このリポジトリに新しいスキル(SKILL.md)を追加する。配置先の決定・frontmatter作成・執筆規約の適用・マニフェスト/README登録・両宿主での検証まで一貫して行う。既存スキルの改訂には使わない(skill-reviseへ)
allowed-tools: Read Glob Grep Write Edit Bash(pnpm:*) Bash(ln:*) Bash(git status:*)
---

# skill-new — 新しいスキルの追加

このリポジトリに新しい SKILL.md を追加します。作業範囲は**当該スキルの新規追加とその登録・検証**だけです。既存スキルの改訂は `skill-revise` に委ねます。

## 実行手順

### 1. 目的とスコープの確認

何をするスキルか、どんなときに呼ばれてほしいかを確認する。`Grep` で `plugins/*/skills/*/SKILL.md` と `.agents/skills/*/SKILL.md` の `description` を見て、既存スキルと役割が重複していないか、誤ルーティングを招かないかを確認する。既存スキルの改訂で足りるなら、新規作成せず `skill-revise` の利用を提案して終える。

### 2. 配置先の決定

配布するプラグインの一部か、このリポジトリ専用のローカルスキルかを判断する。詳細は [docs/skill-authoring.md](../../../docs/skill-authoring.md) の「配置先の決め方」を参照。迷う場合はユーザーに確認する。

### 3. frontmatter と本文の執筆

[docs/skill-authoring.md](../../../docs/skill-authoring.md) の frontmatter ルールと互換性表に従う。本文は AGENTS.md / CLAUDE.md の「スキル執筆の方針」を適用する(結論先出し・長さを内容に見合わせる・自己再確認を指示しない・スコープ固定・宿主中立化など)。既存スキル(例: `plugins/dev-discipline/skills/spec-clarify`)の構成(frontmatter → 見出し → 実行手順 → 注意 → 使用例 → 関連)に揃える。

### 4. 登録

配置先に応じてマニフェスト・README を更新する。対応表は [docs/skill-authoring.md](../../../docs/skill-authoring.md) の「登録先の対応表」を参照。配布スキルの場合は同ドキュメントの「バージョンの更新」に従い、プラグインの `plugin.json` と `.claude-plugin/marketplace.json` のバージョンも上げる。ローカルスキルの場合は `.claude/skills/<skill-name>` から `.agents/skills/<skill-name>` への symlink を張る:

```bash
ln -s ../../.agents/skills/<skill-name> .claude/skills/<skill-name>
```

### 5. 検証(実際に実行する)

[docs/skill-authoring.md](../../../docs/skill-authoring.md) の「検証コマンド」に従い、`pnpm run validate` / `pnpm run validate:codex`(プラグイン配下の場合)またはローカルスキル向けの `codex debug prompt-input` 確認を実行し、成否にかかわらず結果を報告する。

## 注意

- 作業範囲は当該スキルの追加とその登録・検証だけ。既存スキルの手直しに気づいても提示に留め、適用は `skill-revise` に渡す。
- マーケットプレースには登録しないローカルスキルを、誤って配布用プラグインのマニフェストに混ぜない。

## 使用例

```
新しいスキルを作りたい。CIログを要約するスキル
```

## 関連

- `skill-revise` — 既存スキルの改訂。
- [docs/skill-authoring.md](../../../docs/skill-authoring.md) — 配置先・frontmatter・登録・検証の詳細。
