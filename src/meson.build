storm_sources = (
  [blueprints, resources]
  + files(
    'application.vala',
    'cell.vala',
    'client-handler.vala',
    'game-board.vala',
    'game-page.vala',
    'game-setup-page.vala',
    'list-row.vala',
    'main.vala',
    'player.vala',
    'point.vala',
    'server.vala',
    'window.vala',
  )
)

storm_vala_args = [
  '--target-glib', '2.76',
  '--vapidir', meson.current_source_dir(),
  '--gresources', resource_files,
  '--gresourcesdir=data/',
]

executable(
  'storm',
  storm_sources,
  vala_args: storm_vala_args,
  dependencies: storm_deps,
  link_args: ['-lm'],
  install: true,
)