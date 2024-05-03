storm_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
]

storm_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.4'),
]

storm_sources += gnome.compile_resources('storm-resources',
  'storm.gresource.xml',
  c_name: 'storm'
)

executable('storm', storm_sources,
  dependencies: storm_deps,
       install: true,
)
