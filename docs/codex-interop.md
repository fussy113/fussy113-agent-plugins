# Claude Code × Codex 併用のプラクティス

skill をどちらの流儀で書き・どこに置き・どう使い分けるかのルール。

## 前提: この2つは別物

| | Claude Code | Codex CLI |
|---|---|---|
| repo skill root | `.claude/skills` | `.agents/skills` |
| user skill root | `~/.claude/skills`, `~/.config/claude/skills` | `~/.codex/skills`（`$CODEX_HOME/skills`） |
| プラグイン | `.claude-plugin/plugin.json` + `marketplace.json` | `.codex-plugin/plugin.json` + `config.toml` の `[marketplaces.*]` |
| 指示ファイル | `CLAUDE.md`（`AGENTS.md` も認識） | `AGENTS.md` |
| hooks | `hooks/hooks.json` | `.codex/hooks`（`features.hooks`、形式が別） |

**skill 探索パスは1つも重ならない**。追加ルートを指定する設定・環境変数もどちらにも無い。skill を書いた場所は片方からしか見えない。共有の手段は symlink（または同期コピー）だけ。

SKILL.md 本体は概ね共用可能。frontmatter の `name` / `description` は共通で読まれる。CC 固有の `allowed-tools` / `argument-hint` は Codex 側で単に無視される（実害はないが、Codex 側では権限制御が効かない）。

CC → Codex のブリッジは `codex@openai-codex` プラグインで用意済み（`/codex:review`・`/codex:rescue`）。逆方向（Codex から CC を呼ぶ）の公式ブリッジは無い。

## SSOT は本リポジトリ

skill の原本は常に `plugins/*/skills/*/SKILL.md`。Codex 側に直接 skill を書かない。CI（`pnpm run validate`）とレビューが効くのはこちら側だけ。

## skill の3層分類

新しい skill を書くとき最初に決める。判定基準は1行:**本文が CC のホスト機能名(effort / plan mode / subagent 等)か `mcp__` ツール名を含むなら共有層ではない。**

- **共有層** — ツールとプロセスにしか依存せず、両方で使う価値がある。
  `dep-manager/*`(mise・renovate 全5つ)、`github/quick-pr`・`fix-pr`・`review-dependabot`、`dev-discipline/tdd-cycle`・`systematic-debug`
- **CC 固有層** — CC のホスト機能に依存し、Codex に置いても機能しない。
  `token-ops/effort-router`(effort・plan mode・fast・subagent は CC の概念)、`token-ops/ccusage`、`self-improve/retro`(CC のメモリディレクトリに書く)、`guardrail`・`self-improve` の hooks(形式が非互換)
- **要改稿層** — 共有したいが依存が混ざっている。分離してから共有層へ。
  `dev-discipline/spec-clarify`(Notion MCP 依存)、`dev-discipline/spec-implement`(`effort-router` 前提)

## 共有層を Codex から見せる

user レベルなら全プロジェクトで、repo レベルならそのプロジェクトだけで使える。

```bash
# user レベル
ln -s ~/Dev/fussy113-cc-plugin/plugins/dep-manager/skills/mise-sync ~/.codex/skills/mise-sync

# repo レベル
mkdir -p .agents/skills
ln -s ~/Dev/fussy113-cc-plugin/plugins/dep-manager/skills/mise-sync .agents/skills/mise-sync
```

検証済み(`~/.codex/skills/mise-sync` を symlink → `codex exec` で確認): Codex 側では `dep-manager:mise-sync`(親ディレクトリ名を含む形)で認識される。symlink 方式は機能する。

注意点:
- 新しい skill を共有するときはまず1本だけ張って `codex exec` で認識を確認する。全部張ってから気づくと戻すのが面倒。
- symlink は `.gitignore` に入れる。絶対パスなので他人のマシンでは壊れる。
- Codex は skill のメタデータをコンテキスト予算内に収めて truncate する。共有する skill を絞る理由になる。
- CC 側は本リポジトリを直接見ておらず、marketplace 経由で `~/.config/claude/plugins/cache/` のコピーを読む。**skill を編集したら CC 側は push + `/plugin` の更新が要る一方、Codex 側は symlink なので即時反映される。**

## 役割分担(推奨)

- **既定は「CC が主、Codex はセカンドオピニオン」**。実装・計画・リファクタは CC。実装が一段落したら `/codex:review`。CC が同じ場所で2回詰まったら `/codex:rescue` に診断を投げる。skill・hooks・メモリ・`CLAUDE.md` の資産が CC 側に集中しており、Codex を主にするとその全部が使えないため。
- **並行分担は当面やらない**。同一 worktree で両方に書かせると衝突する。どうしても並行させるなら `git worktree` で物理分離してから。
- **Codex を主にする局面**は限定する: CC が原因不明のまま堂々巡りしている診断、CC 自身が書いたコードのレビュー(同じモデルに自分の穴は見えにくい)。

## 指示ファイル

`AGENTS.md -> CLAUDE.md` の symlink(本リポジトリで既に採用)を標準にする。CC は `AGENTS.md` も認識するため片方向 symlink で足りる。CC 固有の記述(effort、plan mode、subagent、`/` コマンド名)を `CLAUDE.md` に足すときは、Codex もそれを読むことを意識し、混乱を避けたい記述は見出しで区切る。

## 新しい skill を書くときのチェックリスト

1. 3層分類のどれか判定する
2. 共有層なら本文から CC ホスト機能名・`mcp__` ツール名を排除する
3. 本リポジトリ(SSOT)に置く
4. 共有層なら symlink を1本張って `codex exec` で認識を確認する
5. `pnpm run validate` を通す
