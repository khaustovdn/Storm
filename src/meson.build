enum_sources = files(
  'client/enum/connection-flag.vala',
  'client/enum/field-flag.vala',
  'client/enum/player-flag.vala',
)

interface_sources = files(
  'client/interface/i-board-service.vala',
  'client/interface/i-navigation-service.vala',
)

model_sources = files(
  'client/model/board-model.vala',
  'client/model/client-model.vala',
  'client/model/game-model.vala',
  'client/model/main-menu-model.vala',
  'client/model/player-model.vala',
  'client/model/ship-placement-model.vala',
)

view_model_sources = files(
  'client/view-model/board-view-model.vala',
  'client/view-model/field-view-model.vala',
  'client/view-model/main-menu-view-model.vala',
  'client/view-model/ship-placement-view-model.vala',
)

view_sources = files(
  'client/view/battle-view.vala',
  'client/view/board-view.vala',
  'client/view/field-view.vala',
  'client/view/main-menu-view.vala',
  'client/view/ship-placement-view.vala',
  'client/view/window-view.vala',
)

storm_sources = (
  [
    blueprints,
    resources,
    enum_sources,
    interface_sources,
    model_sources,
    view_model_sources,
    view_sources,
  ]
  + files(
    'client/application.vala',
    'client/list-row.vala',
    'client/main-window.vala',
  )
)

server_sources = (
  [enum_sources]
  + files(
    'server/main-server.vala',
    'server/player.vala',
    'server/room.vala',
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