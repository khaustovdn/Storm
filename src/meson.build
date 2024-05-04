storm_sources = (
  [blueprints, resources] + files(
    'application.vala',
    'game-page.vala',
    'list-row.vala',
    'main.vala',
    'window.vala',
  )
)

storm_vala_args = [
  '--target-glib',
  '2.76',
  '--vapidir',
  meson.current_source_dir(),
  '--gresources',
  resource_files,
  '--gresourcesdir=data/',
]

executable(
  'storm',
  storm_sources,
  vala_args: storm_vala_args,
  dependencies: storm_deps,
  install: true,
)
