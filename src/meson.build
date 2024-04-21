quarry_sources = [
  'main.vala',
  'application.vala',
  'window.vala',
  'station.vala',
  'machine.vala',
  'excavator.vala',
  'crusher.vala',
  'dump-truck.vala',
  'chart.vala',
  'grid.vala',
  'series.vala',
  'point.vala',
  'color.vala',
]

quarry_deps = [
  dependency('gtk4'),
  dependency('libadwaita-1', version: '>= 1.4'),
  dependency('gee-0.8'),
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
  link_args: ['-lm'],
  install: true,
)
