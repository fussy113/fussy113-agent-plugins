#!/bin/bash
#
# Codex 側のプラグイン検証。
#
# codex CLI には `codex plugin validate` のようなサブコマンドが無く、
# `codex plugin add` もマニフェストを検証しない(壊れたマニフェストでも
# インストールが成功してしまう)。本物の検証ロジックは codex バイナリに
# 埋め込まれたシステムスキル plugin-creator の validate_plugin.py にある。
# これは `codex debug prompt-input` を1回実行すると
# $CODEX_HOME/skills/.system/ 配下に展開される(認証・ネットワーク不要)。
#
set -euo pipefail
cd "$(dirname "$0")/.."

if ! command -v codex >/dev/null 2>&1; then
  echo "codex CLI が見つかりません。devDependencies の @openai/codex を確認してください。" >&2
  exit 1
fi

CODEX_HOME="$(mktemp -d)"
export CODEX_HOME
trap 'rm -rf "$CODEX_HOME"' EXIT

# 1) システムスキル(公式 validator 一式)を展開させる
codex debug prompt-input >/dev/null

VALIDATOR="$CODEX_HOME/skills/.system/plugin-creator/scripts/validate_plugin.py"
if [ ! -f "$VALIDATOR" ]; then
  echo "plugin-creator の validate_plugin.py が見つかりません(codex のバージョンで配置が変わった可能性があります): $VALIDATOR" >&2
  exit 1
fi

# 2) マーケットプレース定義とプラグインの取り込みを確認(スモークテスト)
codex plugin marketplace add "$PWD" --json
codex plugin list

# 3) 各プラグインをマニフェスト検証にかける(本番の検証)
status=0
for dir in plugins/*/; do
  [ -f "${dir}.codex-plugin/plugin.json" ] || continue
  echo "--- validating ${dir} ---"
  if ! uv run --quiet --with pyyaml python3 "$VALIDATOR" "$dir"; then
    status=1
  fi
done

exit "$status"
