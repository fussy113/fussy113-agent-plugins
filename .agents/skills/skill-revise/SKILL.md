---
name: skill-revise
description: 既存のSKILL.mdを改訂する。執筆規約の適用・宿主中立性の確認・他スキルやREADMEへの波及確認・両宿主での再検証まで一貫して行う。新規スキルの作成には使わない(skill-newへ)
allowed-tools: Read Glob Grep Edit Bash(pnpm:*) Bash(git diff:*)
---

# skill-revise — 既存スキルの改訂

既存の SKILL.md を改訂します。**依頼された変更点だけ**を適用し、それ以外は触りません。新規スキルの作成は `skill-new` に委ねます。

## 実行手順

### 1. 対象の特定と現状把握

引数(スキル名またはパス)から対象の SKILL.md を Read する。引数がなければ候補(`plugins/*/skills/*/SKILL.md`、`.agents/skills/*/SKILL.md`)を提示してユーザーに確認する。

### 2. 改訂範囲の確定

依頼された変更点を列挙する。ついでの改善は「気づいたこと」として提示に留め、依頼されていない範囲は変更しない。

### 3. 改訂の適用

AGENTS.md / CLAUDE.md の「スキル執筆の方針」を適用する。既存の書式・語彙・見出し構成を維持する。[docs/skill-authoring.md](../../../docs/skill-authoring.md) の frontmatter ルールと互換性表(両宿主で通る記法か)も確認する。

### 4. 波及の確認

- 他スキルからの相互参照: `Grep` で `<plugin>:<skill-name>` や当該スキル名を検索し、参照側の記述が古くならないか確認する。
- プラグイン README・ルート README のスキル一覧表。
- `name` を変更する場合: 両方の `plugin.json`(`.claude-plugin/` / `.codex-plugin/`)、両方の `marketplace.json`、ディレクトリ名、ローカルスキルなら symlink 名も揃える。
- 配布スキルの場合: [docs/skill-authoring.md](../../../docs/skill-authoring.md) の「バージョンの更新」に従い、プラグインの `plugin.json` と `.claude-plugin/marketplace.json` のバージョンを上げる。

### 5. 検証(実際に実行する)

`pnpm run validate` / `pnpm run validate:codex`(プラグイン配下の場合)を実行する。`git diff` で変更が意図した範囲に収まっていることを確認し、結果を成否にかかわらず報告する。

## 注意

- リファクタリングの押し売りをしない。気づいた別スキルの問題は提示までに留める。
- スコープ外の書き換え(執筆スタイルの好みでの全面書き直しなど)は依頼がない限り行わない。

## 使用例

```
spec-clarify のNotionフォールバック手順を修正して
```

## 関連

- `skill-new` — 新しいスキルの追加。
- [docs/skill-authoring.md](../../../docs/skill-authoring.md) — frontmatter・登録・検証の詳細。
