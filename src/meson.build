quarry_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
  'excavator.vala',
  'crusher.vala',
  'dump-truck.vala',
]

quarry_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.4'),
]

quarry_sources += gnome.compile_resources(
  'quarry-resources',
  'quarry.gresource.xml',
  c_name: 'quarry',
)

executable(
  'quarry',
  quarry_sources,
  dependencies: quarry_deps,
  install: true,
)
