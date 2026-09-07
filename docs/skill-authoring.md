# スキル執筆リファレンス

`skill-new` / `skill-revise` から参照される事実情報。執筆スタイルの規約(結論先出し・長さ・宿主中立化など)は AGENTS.md / CLAUDE.md の「スキル執筆の方針」にあり、ここには再掲しない。

## 配置先の決め方

- **他プロジェクトにも配布する** → `plugins/<plugin>/skills/<skill>/SKILL.md`。既存プラグインに追加するか新規プラグインにするかを判断する。
- **このリポジトリの作業にしか使わない** → `.agents/skills/<skill>/SKILL.md` を実体とし、`.claude/skills/<skill>` から `../../.agents/skills/<skill>` への symlink を張る。マーケットプレースには登録しない。

## 推奨セクション構成

`frontmatter → 目的1〜2文 → (鉄則) → 完了条件/停止ルール → 実行手順 → 出力フォーマット → 注意 → 使用例 → 関連`

該当しないセクション(鉄則が無いスキル等)は省略する。

## frontmatter

- `name`: ディレクトリ名と一致させる。
- `description`: 何をするか + いつ使うかを1文で。既存スキルの description と役割が被ると誤ルーティングの原因になるので、`Grep` で他スキルの description を確認してから書く。
- 任意: `argument-hint`、`allowed-tools`。

### 両宿主での互換性(実測済み)

| 事項 | 結果 |
|---|---|
| Claude Code のスキル探索先 | `~/.claude/skills/`(個人)、`.claude/skills/`(プロジェクト)、プラグイン配下 |
| Codex のスキル探索先 | `$CODEX_HOME/skills/`、`.codex/skills/`、`.agents/skills/` |
| Codex は symlink されたスキルディレクトリを辿るか | 辿る |
| Claude Code は symlink されたスキルディレクトリを辿るか | 辿る(同一ターゲットが複数経路から見えても1回だけ読み込む) |
| Codex は `argument-hint` / `allowed-tools` を受けるか | 受ける(未知キーとして無視して読み込む) |

## 登録先の対応表

| 対応 | 追加/更新するファイル |
|---|---|
| Claude Code のみ配布 | `plugins/<plugin>/.claude-plugin/plugin.json`、`.claude-plugin/marketplace.json` |
| Claude Code / Codex 両対応 | 上記に加え `plugins/<plugin>/.codex-plugin/plugin.json`、`.agents/plugins/marketplace.json` |
| このリポジトリ専用ローカルスキル | `.claude/skills/<skill>` symlink のみ。マーケットプレースには登録しない |

各プラグインの README とルート README のスキル一覧表も忘れず更新する。

## バージョンの更新

配布スキル(プラグイン配下)の SKILL.md を追加・改訂したら、そのプラグインの `plugin.json` の `version` を semver で1段階上げる(例: `0.0.1` → `0.0.2`)。両対応プラグインは `.claude-plugin/plugin.json` と `.codex-plugin/plugin.json` の両方を上げる。加えて `.claude-plugin/marketplace.json` の `metadata.version` も1段階上げる。

`.agents/plugins/marketplace.json`(Codex 側マーケットプレース)は仕様上トップレベルに `version` フィールドを持たない。バージョンはプラグインごとの `.codex-plugin/plugin.json` で管理するため、このファイル自体は変更しない。

## 検証コマンド

- 配布スキル(プラグイン配下): `pnpm run validate`(Claude Code 側)、`pnpm run validate:codex`(Codex 側、`plugin.json` を持つプラグインのみ)。
- ローカルスキル(`.agents/skills/`): Codex 側の認識を実際に確認する。

  ```bash
  CODEX_HOME=$(mktemp -d) ./node_modules/.bin/codex debug prompt-input | grep -o "<skill-name>[^(]*(file: [^)]*)"
  ```

  Claude Code 側は新しいセッションを開いて `/<skill-name>` が候補に出ることで確認する(既存セッションでは再読込されない)。
