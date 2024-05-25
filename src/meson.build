storm_sources = (
  [blueprints, resources]
  + files(
    'client/application.vala',
    'client/board.vala',
    'client/entry-row.vala',
    'client/field.vala',
    'client/game-page.vala',
    'client/list-row.vala',
    'client/main-window.vala',
    'client/player.vala',
    'client/room-page.vala',
    'client/window.vala',
    'player-role.vala',
  )
)

server_sources = (
  files(
    'server/main-server.vala',
    'server/player.vala',
    'server/room.vala',
    'server/server.vala',
    'player-role.vala',
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