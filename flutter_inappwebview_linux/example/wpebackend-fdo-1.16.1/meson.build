project('wpebackend-fdo', ['c', 'cpp'],
	meson_version: '>=0.52.1',
	default_options: [
		'b_ndebug=if-release',
		'c_std=c99',
		'cpp_eh=none',
		'cpp_rtti=false',
		'cpp_std=c++11',
	],
	license: 'BSD-2-Clause',
	version: run_command(join_paths('scripts', 'version.py'), check: true).stdout().strip(),
)

# This refers to the API level provided. This is modified only with major,
# breaking changes, which need modifications in programs using the library
# before they can be compiled again.
api_version = '1.0'

# Before making a release, the soversion array should be modified.
# The string is of the form [C, R, A].
# - If interfaces have been changed or added, but binary compatibility has
#   been preserved, change to [C+1, 0, A+1].
# - If binary compatibility has been broken (eg removed or changed interfaces)
#   change to [C+1, 0, 0]
# - If the interface is the same as the previous version, use [C, R+1, A].
soversion = [11, 2, 10]

# Mangle [C, R, A] into an actual usable *soversion*.
soversion_major = soversion[0] - soversion[2]  # Current-Age
soversion_minor = soversion[2]  # Age
soversion_micro = soversion[1]  # Revision
soversion = '@0@.@1@.@2@'.format(soversion_major, soversion_minor, soversion_micro)

sources = [
	'src/dmabuf-pool-entry.cpp',
	'src/egl-client-dmabuf-pool.cpp',
	'src/egl-client-wayland.cpp',
	'src/exported-buffer-shm.cpp',
	'src/exported-image-egl.cpp',
	'src/fdo.cpp',
	'src/initialize-dmabuf.cpp',
	'src/initialize-egl.cpp',
	'src/initialize-eglstream.cpp',
	'src/initialize-shm.cpp',
	'src/ipc.cpp',
	'src/renderer-backend-egl.cpp',
	'src/renderer-host.cpp',
	'src/version.c',
	'src/view-backend-dmabuf-pool-fdo.cpp',
	'src/view-backend-exportable-fdo.cpp',
	'src/view-backend-exportable-fdo-egl.cpp',
	'src/view-backend-exportable-fdo-eglstream.cpp',
	'src/view-backend-private.cpp',
	'src/ws.cpp',
	'src/ws-client.cpp',
	'src/ws-dmabuf-pool.cpp',
	'src/ws-egl.cpp',
	'src/ws-eglstream.cpp',
	'src/ws-shm.cpp',
	'src/extensions/audio.cpp',
	'src/extensions/audio-receiver.cpp',
	'src/extensions/video-plane-display-dmabuf.cpp',
	'src/extensions/video-plane-display-dmabuf-receiver.cpp',
	'src/linux-dmabuf/linux-dmabuf.cpp',
]

api_headers = [
	'include/wpe/exported-buffer-shm.h',
	'include/wpe/exported-image-egl.h',
	'include/wpe/fdo-egl.h',
	'include/wpe/fdo.h',
	'include/wpe/initialize-egl.h',
	'include/wpe/version.h',
	'include/wpe/view-backend-exportable-egl.h',
	'include/wpe/view-backend-exportable.h',
	'include/wpe/wpebackend-fdo-version.h',
]

extensions_api_headers = [
	'include/wpe/extensions/audio.h',
	'include/wpe/extensions/video-plane-display-dmabuf.h',
]

unstable_api_headers = [
	'include/wpe/unstable/dmabuf-pool-entry.h',
	'include/wpe/unstable/fdo-dmabuf.h',
	'include/wpe/unstable/fdo-eglstream.h',
	'include/wpe/unstable/fdo-shm.h',
	'include/wpe/unstable/initialize-dmabuf.h',
	'include/wpe/unstable/initialize-shm.h',
	'include/wpe/unstable/initialize-eglstream.h',
	'include/wpe/unstable/view-backend-dmabuf-pool-fdo.h',
	'include/wpe/unstable/view-backend-exportable-eglstream.h',
]

add_project_arguments(
	'-DWPE_FDO_COMPILATION=1',
	'-DG_LOG_DOMAIN="WPE-FDO"',
	'-D_LARGEFILE64_SOURCE=1',
	language: ['c', 'cpp']
)

wayland_scanner_candidates = ['wayland-scanner']
wayland_scanner_dep = dependency('wayland-scanner', required: false, native: true)
if wayland_scanner_dep.found()
	wayland_scanner_candidates += wayland_scanner_dep.get_pkgconfig_variable('wayland_scanner')
endif

wayland_scanner = find_program(wayland_scanner_candidates, native: true)

r = run_command(wayland_scanner, '--version', check: true)
wayland_scanner_version = r.stderr().split()
if not (wayland_scanner_version.length() == 2)
	wayland_scanner_version = r.stdout().split()
endif
wayland_scanner_code = 'code'
if wayland_scanner_version.length() == 2
	wayland_scanner_version = wayland_scanner_version[1]
	if wayland_scanner_version.version_compare('>=1.15')
		wayland_scanner_code = 'private-code'
	endif
	message('wayland-scanner version: ' + wayland_scanner_version)
else
	wayland_scanner_version = ''
	message('wayland-scanner version: unknown')
endif
message('Using "' + wayland_scanner_code + '" as parameter to wayland-scanner')

# Wayland extension: WPE bridge.
wpe_bridge_client_proto_header = custom_target(
	'wpe-bridge-client-proto-header',
	input: 'src/bridge/wpe-bridge.xml',
	output: '@BASENAME@-client-protocol.h',
	command: [wayland_scanner, 'client-header', '@INPUT@', '@OUTPUT@'],
)
wpe_bridge_server_proto_header = custom_target(
	'wpe-bridge-server-proto-header',
	input: 'src/bridge/wpe-bridge.xml',
	output: '@BASENAME@-server-protocol.h',
	command: [wayland_scanner, 'server-header', '@INPUT@', '@OUTPUT@'],
)
wpe_bridge_proto_source = custom_target(
	'wpe-bridge-proto-source',
	input: 'src/bridge/wpe-bridge.xml',
	output: '@BASENAME@-protocol.c',
	command: [wayland_scanner, wayland_scanner_code, '@INPUT@', '@OUTPUT@'],
)

# Wayland extension: DMA-BUF video plane display.
wpe_video_plane_display_dmabuf_client_proto_header = custom_target(
	'video-plane-display-dmabuf-client-proto-header',
	input: 'src/extensions/wpe-video-plane-display-dmabuf.xml',
	output: '@BASENAME@-client-protocol.h',
	command: [wayland_scanner, 'client-header', '@INPUT@', '@OUTPUT@'],
)
wpe_video_plane_display_dmabuf_server_proto_header = custom_target(
	'video-plane-display-dmabuf-server-proto-header',
	input: 'src/extensions/wpe-video-plane-display-dmabuf.xml',
	output: '@BASENAME@-server-protocol.h',
	command: [wayland_scanner, 'server-header', '@INPUT@', '@OUTPUT@'],
)
wpe_video_plane_display_dmabuf_proto_source = custom_target(
	'video-plane-display-dmabuf-proto-source',
	input: 'src/extensions/wpe-video-plane-display-dmabuf.xml',
	output: '@BASENAME@-protocol.c',
	command: [wayland_scanner, wayland_scanner_code, '@INPUT@', '@OUTPUT@'],
)

# Wayland extension: Audio rendering protocol.
wpe_audio_client_proto_header = custom_target(
	'audio-client-proto-header',
	input: 'src/extensions/wpe-audio.xml',
	output: '@BASENAME@-client-protocol.h',
	command: [wayland_scanner, 'client-header', '@INPUT@', '@OUTPUT@'],
)
wpe_audio_server_proto_header = custom_target(
	'audio-server-proto-header',
	input: 'src/extensions/wpe-audio.xml',
	output: '@BASENAME@-server-protocol.h',
	command: [wayland_scanner, 'server-header', '@INPUT@', '@OUTPUT@'],
)
wpe_audio_proto_source = custom_target(
	'audio-proto-source',
	input: 'src/extensions/wpe-audio.xml',
	output: '@BASENAME@-protocol.c',
	command: [wayland_scanner, wayland_scanner_code, '@INPUT@', '@OUTPUT@'],
)

# Wayland extension: EGLStream controller
wayland_eglstream_controller_server_proto_header = custom_target(
	'wayland-eglstream-controller-server-proto-header',
	input: 'src/wayland-eglstream/wayland-eglstream-controller.xml',
	output: '@BASENAME@-server-protocol.h',
	command: [wayland_scanner, 'server-header', '@INPUT@', '@OUTPUT@'],
)

wayland_eglstream_controller_proto_source = custom_target(
	'wayland-eglstream-controller-proto-source',
	input: 'src/wayland-eglstream/wayland-eglstream-controller.xml',
	output: '@BASENAME@-protocol.c',
	command: [wayland_scanner, wayland_scanner_code, '@INPUT@', '@OUTPUT@'],
)

# Wayland extension: dmabuf pool
wpe_dmabuf_pool_client_proto_header = custom_target(
	'dmabuf-pool-client-proto-header',
	input: 'src/dmabuf-pool/wpe-dmabuf-pool.xml',
	output: '@BASENAME@-client-protocol.h',
	command: [wayland_scanner, 'client-header', '@INPUT@', '@OUTPUT@'],
)
wpe_dmabuf_pool_server_proto_header = custom_target(
	'dmabuf-pool-server-proto-header',
	input: 'src/dmabuf-pool/wpe-dmabuf-pool.xml',
	output: '@BASENAME@-server-protocol.h',
	command: [wayland_scanner, 'server-header', '@INPUT@', '@OUTPUT@'],
)
wpe_dmabuf_pool_proto_source = custom_target(
	'dmabuf-pool-proto-source',
	input: 'src/dmabuf-pool/wpe-dmabuf-pool.xml',
	output: '@BASENAME@-protocol.c',
	command: [wayland_scanner, wayland_scanner_code, '@INPUT@', '@OUTPUT@'],
)

# Wayland extension: linux-dmabuf
wpe_linux_dmabuf_server_proto_header = custom_target(
        'linux-dmabuf-server-proto-header',
        input: 'src/linux-dmabuf/linux-dmabuf-unstable-v1.xml',
        output: '@BASENAME@-server-protocol.h',
        command: [wayland_scanner, 'server-header', '@INPUT@', '@OUTPUT@'],
)
wpe_linux_dmabuf_proto_source = custom_target(
       'linux-dmabuf-proto-source',
       input: 'src/linux-dmabuf/linux-dmabuf-unstable-v1.xml',
       output: '@BASENAME@-protocol.c',
       command: [wayland_scanner, wayland_scanner_code, '@INPUT@', '@OUTPUT@'],
)

cxx = meson.get_compiler('cpp')

# Switch to the 'cpp_eh=none' default option when updating to Meson 0.51 or newer, see
# https://mesonbuild.com/Builtin-options.html
if meson.version().version_compare('<0.51')
	add_project_arguments(
		cxx.get_supported_arguments(['-fno-exceptions']),
		language: 'cpp'
	)
endif

# The 'cpp_rtti=false' default option is only recognized by Meson 0.53 or newer, see
# https://mesonbuild.com/FAQ.html#how-do-i-disable-exceptions-and-rtti-in-my-c-project
if meson.version().version_compare('<0.53')
	add_project_arguments(
		cxx.get_supported_arguments(['-fno-rtti']),
		language: 'cpp'
	)
endif

add_project_arguments(
	cxx.get_supported_arguments(['-fvisibility=hidden']),
	language: 'cpp'
)
add_project_arguments(
	meson.get_compiler('c').get_supported_arguments(['-fvisibility=hidden']),
	language: 'c'
)

wpe_dep = dependency('wpe-1.0', version: '>=1.6.0', fallback: ['libwpe', 'libwpe_dep'])

deps = [
	dependency('epoxy'),
	dependency('gio-2.0'),
	dependency('gobject-2.0'),
	dependency('wayland-client'),
	dependency('wayland-server'),
        wpe_dep,
]

# Will be set to the library dependency which provides the wl_egl_* functions.
wl_egl_dep = disabler()

# Some EGL drivers provide the wl_egl_* symbols directly (e.g. old versions
# of the Vivante driver), instead of a wayland-egl library. Try both and use
# the first one found.
wl_egl_try_deps = ['wayland-egl', 'egl']
foreach dep_name : wl_egl_try_deps
	dep = dependency(dep_name, required: false)
	if dep.found() and cxx.has_function('wl_egl_window_create', dependencies: dep)
		wl_egl_dep = dep
		break
	endif
endforeach

# As a fall back for systems which have an EGL library without a corresponding
# pkg-config module, try findind the library directly.
if not wl_egl_dep.found()
	dep = cxx.find_library('EGL', required: false)
	if dep.found() and cxx.has_function('wl_egl_window_create', dependencies: dep)
		wl_egl_dep = dep
	endif
endif

if wl_egl_dep.found()
	deps += [wl_egl_dep]
else
	warning('''
	Could not check availability of the wl_egl_* functions (tried wayland-client,
	egl, and libEGL). Continuing anyway, but your build will likely be broken.''')
endif

xkbcommon_dep = dependency('xkbcommon', required: false)
if xkbcommon_dep.found()
	deps += [xkbcommon_dep]
elif not cxx.has_header('xkbcommon/xkbcommon-keysyms.h')
	error('The <xkbcommon/xkbcommon-keysyms.h> header is missing')
endif

generated_sources = [
	wpe_bridge_proto_source,
	wpe_bridge_client_proto_header,
	wpe_bridge_server_proto_header,
	wpe_audio_proto_source,
	wpe_audio_client_proto_header,
	wpe_audio_server_proto_header,
	wpe_video_plane_display_dmabuf_proto_source,
	wpe_video_plane_display_dmabuf_client_proto_header,
	wpe_video_plane_display_dmabuf_server_proto_header,
	wayland_eglstream_controller_proto_source,
	wayland_eglstream_controller_server_proto_header,
	wpe_dmabuf_pool_client_proto_header,
	wpe_dmabuf_pool_server_proto_header,
	wpe_dmabuf_pool_proto_source,
        wpe_linux_dmabuf_server_proto_header,
        wpe_linux_dmabuf_proto_source,
]

lib = shared_library('WPEBackend-fdo-' + api_version,
	sources, generated_sources,
	install: true,
	dependencies: deps,
	version: soversion,
	soversion: soversion_major,
	include_directories: include_directories('include'),
)

wpebackend_fdo_dep = declare_dependency(link_with : lib,
  include_directories : include_directories('include'),
  dependencies : deps,
  sources : generated_sources,
)

install_headers(api_headers,
	subdir: join_paths('wpe-fdo-' + api_version, 'wpe'),
)
install_headers(extensions_api_headers,
	subdir: join_paths('wpe-fdo-' + api_version, 'wpe', 'extensions'),
)
install_headers(unstable_api_headers,
	subdir: join_paths('wpe-fdo-' + api_version, 'wpe', 'unstable'),
)

import('pkgconfig').generate(
	description: 'The WPEBackend-fdo library',
	name: 'wpebackend-fdo-' + api_version,
	subdirs: 'wpe-fdo-' + api_version,
	libraries: [lib, wpe_dep],
)

if get_option('build_docs')
	hotdoc = import('hotdoc')
	assert(hotdoc.has_extensions('c-extension'),
		'The HotDoc C extension is required.'
	)
	libwpe_doc = hotdoc.generate_doc('WPEBackend-fdo',
		project_version: api_version,
		index: 'docs/index.markdown',
		sitemap: 'docs/sitemap.txt',
		console: true,
		install: true,
		build_by_default: true,
		c_smart_index: true,
		c_sources: api_headers,
		c_include_directories: ['include', meson.current_build_dir()],
		extra_c_flags: ['-DWPE_FDO_COMPILATION=1'],
	)
endif
