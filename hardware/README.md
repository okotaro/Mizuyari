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
