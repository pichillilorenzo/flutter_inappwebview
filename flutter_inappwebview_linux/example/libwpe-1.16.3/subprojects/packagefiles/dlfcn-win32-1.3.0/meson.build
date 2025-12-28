project(
	'dlfcn-win32',
	'c',
	version: '1.3.0',
)

dlfcn_win32_lib = static_library('dl', 'src/dlfcn.c', pic: true)

dlfcn_win32_dep = declare_dependency(
	link_with: dlfcn_win32_lib,
	include_directories: include_directories('src'),
)
