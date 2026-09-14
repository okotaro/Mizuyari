#!/bin/bash
# devcontainer 作成後のセットアップ。
#
# - cc-sdd      : Kiro式Spec-Driven Development のスキル一式を配置
# - kicad-happy : KiCad の設計データ（.kicad_sch / .kicad_pcb / ガーバー）を
#                 Claude Code から直接解析するプラグイン
#
# .claude/settings.json が marketplace を宣言しているが、外部ソース（GitHub）の
# プラグイン本体は宣言だけでは導入されないため、ここで明示的に install する。
#
# Invoked from postCreateCommand in each devcontainer.json.
set -eu

cc-sdd --claude-skills --lang ja

install_kicad_happy() {
    # 既に登録済みなら add が失敗するので、その場合は update に切り替える。
    # 関数は `if !` の中で呼ばれ set -e が効かないため、明示的に return する。
    claude plugin marketplace add aklofas/kicad-happy \
        || claude plugin marketplace update kicad-happy \
        || return 1
    claude plugin install kicad-happy@kicad-happy --scope user --yes
}

if ! install_kicad_happy; then
    echo "警告: kicad-happy の導入に失敗しました。" >&2
    echo "      Claude Code 起動後に /plugin install kicad-happy@kicad-happy を実行してください。" >&2
fi
