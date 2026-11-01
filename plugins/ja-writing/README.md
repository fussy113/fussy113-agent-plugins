# ja-writing

対応: Claude Code / Codex

`tanteki` → `natural-japanese` → `yomiyasu` を決まった順序で通し、日本語文書を作成・推敲するスキル。3スキルは別途導入が必要です。

## 構成

| スキル | 役割 |
|---|---|
| `ja-writing` | 構成と簡潔さ(tanteki)、自然さ(natural-japanese)、最終推敲(yomiyasu)を順に適用する。原文があれば推敲、資料だけなら作成 |

## 使い方

```
ja-writing で docs/design.md を推敲して
ja-writing write この議事メモから報告書を作って
```
