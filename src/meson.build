storm_sources = (
  [blueprints, resources]
  + files(
    'client/application.vala',
    'client/cell.vala',
    'client/entry-row.vala',
    'client/game-page.vala',
    'client/list-row.vala',
    'client/main-window.vala',
    'client/map.vala',
    'client/player.vala',
    'client/room-page.vala',
    'client/room.vala',
    'client/window.vala',
  )
)

server_sources = (
  files(
    'server/main-server.vala',
    'server/player-array-list.vala',
    'server/player-handler.vala',
    'server/room-handler.vala',
    'server/server.vala',
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