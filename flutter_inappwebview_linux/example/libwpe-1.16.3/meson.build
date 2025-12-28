project('libwpe', 'cpp', 'c',
	meson_version: '>=0.55',
	default_options: [
		'b_ndebug=if-release',
		'c_std=c99',
		'cpp_std=c++11',
	],
	license: 'BSD-2-Clause',
	version: run_command(join_paths('scripts', 'version.py'), check: true).stdout().strip(),
)

# This refers to the API level provided. This is modified only with major,
# breaking changes, which need modifications in programs using the library
# before they can be compiled again.
api_version = '1.0'

# Before making a release, the LT_VERSION string should be modified.
# The string is of the form [C, R, A].
# - If interfaces have been changed or added, but binary compatibility has
#   been preserved, change to [C+1, 0, A+1].
# - If binary compatibility has been broken (eg removed or changed interfaces)
#   change to [C+1, 0, 0]
# - If the interface is the same as the previous version, use [C, R+1, A].
soversion = [10, 6, 9]

# Mangle [C, R, A] into an actual usable *soversion*.
soversion_major = soversion[0] - soversion[2]  # Current-Age
soversion_minor = soversion[2]  # Age
soversion_micro = soversion[1]  # Revision
soversion = '@0@.@1@.@2@'.format(soversion_major, soversion_minor, soversion_micro)

add_project_arguments('-DWPE_COMPILATION=1', language: ['c', 'cpp'])

# Switch to the 'cpp_rtti=false' default option when updating to Meson 0.53 or newer, see
# https://mesonbuild.com/FAQ.html#how-do-i-disable-exceptions-and-rtti-in-my-c-project
add_project_arguments(
	meson.get_compiler('cpp').get_supported_arguments(['-fno-rtti', '-fno-exceptions']),
	language: 'cpp'
)

default_backend = get_option('default-backend').strip()
if default_backend != ''
	add_project_arguments('-DWPE_BACKEND="@0@"'.format(default_backend), language: ['c', 'cpp'])
endif

dependencies = []
pkg_cflags = []

if get_option('enable-xkb')
	pkg_cflags += ['-DWPE_ENABLE_XKB=1']
	dependencies += dependency('xkbcommon',
		fallback: ['libxkbcommon', 'libxkbcommon_dep'],
	)
endif

cc = meson.get_compiler('c')
egl_dep = dependency('egl', required: false)
if egl_dep.found()
	dependencies += egl_dep.partial_dependency(
		compile_args: true,
		includes: true,
	)
elif target_machine.system() != 'windows'
	assert(cc.has_header('EGL/eglplatform.h'),
		'Required header <EGL/eglplatform.h> not found'
	)
endif

if not cc.has_function('dlopen')
	dl_dep = cc.find_library('dl', required: false)
	if not dl_dep.found()
		dl_dep = dependency('dl',
			allow_fallback: target_machine.system() == 'windows',
		)
	endif
	dependencies += dl_dep
endif

android_log_lib = cc.find_library('log', has_headers: ['android/log.h'], required: false)
if android_log_lib.found()
	add_project_arguments('-DWPE_ENABLE_ANDROID=1', language: ['c', 'cpp'])
	dependencies += [android_log_lib]
endif

if pkg_cflags.length() > 0
	add_project_arguments(pkg_cflags, language: ['c', 'cpp'])
endif

libwpe = library('wpe-' + api_version,
	'src/alloc.c',
	'src/gamepad.c',
	'src/input-xkb.c',
	'src/key-unicode.c',
	'src/pasteboard.c',
	'src/pasteboard-generic.cpp',
	'src/pasteboard-noop.cpp',
	'src/process.c',
	'src/renderer-backend-egl.c',
	'src/renderer-host.c',
	'src/version.c',
	'src/view-backend.c',
	get_option('default_library') == 'shared' ? 'src/loader.c' : 'src/loader-static.c',
	install: true,
	dependencies: dependencies,
	version: soversion,
	soversion: soversion_major,
	gnu_symbol_visibility: 'hidden',
	include_directories: include_directories('include'),
)

subdir('include')
import('pkgconfig').generate(
	description: 'The wpe library',
	name: 'wpe-' + api_version,
	subdirs: 'wpe-' + api_version,
	libraries: libwpe,
	version: meson.project_version(),
	extra_cflags: pkg_cflags,
)

if get_option('build-docs')
	hotdoc = import('hotdoc')
	assert(hotdoc.has_extensions('c-extension'),
		'The HotDoc C extension is required.'
	)
	libwpe_doc = hotdoc.generate_doc(meson.project_name(),
		project_version: api_version,
		dependencies: dependencies,
		index: 'docs/index.md',
		sitemap: 'docs/sitemap.txt',
		console: true,
		install: true,
		build_by_default: true,
		c_smart_index: true,
		c_sources: api_headers,
		c_include_directories: [
			include_directories('include'),
			meson.current_build_dir()
		],
		# The space here is relevant, see
		# https://github.com/mesonbuild/meson/issues/5800#issuecomment-552198354
		extra_c_flags: [' -DWPE_COMPILATION=1'],
	)
endif

libwpe_dep = declare_dependency(link_with : libwpe,
  include_directories : include_directories('include'),
  dependencies : dependencies,
)
