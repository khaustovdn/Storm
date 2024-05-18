storm_sources = (
  [blueprints, resources]
  + files(
    'client/application.vala',
    'client/cell.vala',
    'client/game-board.vala',
    'client/game-page.vala',
    'client/game-setup-page.vala',
    'client/game.vala',
    'client/list-row.vala',
    'client/main-window.vala',
    'client/player.vala',
    'client/point.vala',
    'client/window.vala',
    'player-parameters.vala',
  )
)

server_sources = (
  files(
    'server/client-handler.vala',
    'server/game-handler.vala',
    'server/main-server.vala',
    'server/server.vala',
    'player-parameters.vala',
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

executable(
  'server',
  server_sources,
  dependencies: storm_deps,
  link_args: ['-lm'],
  install: true,
)