# hardware

KiCadプロジェクトを格納するディレクトリ。

プロジェクトごとにサブディレクトリを作成する想定:

```
hardware/
└── <project-name>/
    ├── <project-name>.kicad_pro
    ├── <project-name>.kicad_sch
    ├── <project-name>.kicad_pcb
    └── ...
```

ビルド生成物（`*.bak`, `fp-info-cache`, `*-backups/` 等）はコミットしない。

## 設計レビュー

回路図・基板は Claude Code に直接読ませてレビューできる。
スクリーンショットではなく設計データ（`.kicad_sch` / `.kicad_pcb` / ガーバー）を解析する。

```
hardware/daiso-clock/ の回路図と基板をレビューして
```

解析結果は `analysis/` に残る（再生成できるためコミットしない）。
仕組みと注意点は `.kiro/steering/tech.md` の「設計レビュー」を参照。
