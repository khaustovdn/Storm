desktop_file = i18n.merge_file(
  input: 'io.github.Storm.desktop.in',
  output: 'io.github.Storm.desktop',
  type: 'desktop',
  po_dir: '../po',
  install: true,
  install_dir: get_option('datadir') / 'applications',
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils, args: [desktop_file])
endif

appstream_file = i18n.merge_file(
  input: 'io.github.Storm.metainfo.xml.in',
  output: 'io.github.Storm.metainfo.xml',
  po_dir: '../po',
  install: true,
  install_dir: get_option('datadir') / 'metainfo',
)

appstreamcli = find_program('appstreamcli', required: false, disabler: true)
test(
  'Validate appstream file',
  appstreamcli,
  args: ['validate', '--no-net', '--explain', appstream_file],
)

install_data(
  'io.github.Storm.gschema.xml',
  install_dir: get_option('datadir') / 'glib-2.0' / 'schemas',
)

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  test(
    'Validate schema file',
    compile_schemas,
    args: ['--strict', '--dry-run', meson.current_source_dir()],
  )
endif

blueprints = custom_target(
  'blueprints',
  input: files(
    'gtk/help-overlay.blp',
    'ui/game-page.blp',
    'ui/list-row.blp',
    'ui/window.blp',
  ),
  output: '.',
  command: [
    find_program('blueprint-compiler'),
    'batch-compile',
    '@OUTPUT@',
    '@CURRENT_SOURCE_DIR@',
    '@INPUT@',
  ],
)

resource_files = files('io.github.Storm.gresource.xml')
resources = gnome.compile_resources(
  'storm-resources',
  resource_files,
  dependencies: blueprints,
  c_name: 'storm',
)

subdir('icons')
