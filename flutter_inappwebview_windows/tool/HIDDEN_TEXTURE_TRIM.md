# Hidden Windows composition textures

Refs [Otzaria/otzaria#4109](https://github.com/Otzaria/otzaria/issues/4109).

## Policy and displayed content

A composition view that remains hidden for **30 seconds** detaches unused render
resources. This is a conservative quiet interval; it is not a measured optimum.
Showing or stopping the view cancels the timer. A short tab switch performs no
surface allocation because of this policy. The existing immediate release of
comparison scratch textures is unchanged.

For the GPU bridge, the last published shared texture always remains available.
Only unpublished, unleased slots are detached. If an older `FrameLease` still
owns the spare, trim retries after another 30 seconds instead of waiting for
Flutter. The retry stops once the spare is detached. A never-published pool may
release both slots. No capture, JavaScript call or continuous polling is added.

The raw DXGI handle must remain valid until Flutter opens the resource. The
existing `FrameLease` retains the entire pool until its release callback; a
published slot also stays valid for the next descriptor request after an earlier
lease has ended. Detachment moves COM references out under the ownership lock,
then releases them after both the pool and capture locks have been released.
Legacy `GetSharedHandle` handles are not NT handles and are not closed with
`CloseHandle` ([Microsoft documentation](https://learn.microsoft.com/en-us/windows/win32/api/dxgi/nf-dxgi-idxgiresource-getsharedhandle)).

For the CPU fallback, only the readback staging texture is detached. The backing
pixel array, its descriptor and release callback remain available, including
while Flutter is uploading that array. Reallocation failure retains the previous
frame and retries on a later capture instead of mapping a null texture.

Before the first new frame arrives, Flutter continues to receive the last
published texture or pixel buffer. A viewport resize can therefore temporarily
scale the last image. The next captured frame recreates resources at its current
dimensions and is published normally. The policy does not clear the texture,
reload the document, or change HWND rendering.

The timer uses a weak operation state and a generation/deadline check. This also
handles a queued callback from an earlier hide or a reused Windows timer ID;
[`KillTimer`](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-killtimer)
does not remove already queued timer messages. Cancellation, visibility changes
and timer delivery run on the owning platform thread.

## Automated checks and their limits

```sh
sh flutter_inappwebview_windows/windows/test/run_delayed_texture_trim_tests.sh
python3 flutter_inappwebview_windows/tool/test_hidden_texture_trim.py
python3 flutter_inappwebview_windows/tool/test_hidden_texture_trim.py --sanitize
```

The first command uses a virtual clock: short hides, rehide deadlines, stale
callbacks, an outstanding consumer, disposal and timer-creation failure. The
second extracts production methods without modifying their bodies and compiles
them against narrow capture/D3D/Flutter doubles. It exercises the actual
`AcceptFrame`, `FrameLease` release, pool refill/resize, hidden scheduling and CPU
readback paths. It checks allocation failures, disposal with open consumers,
the retained pixels and release outside raster mutexes. Color conversion and
capture-session creation are doubles; this is not a live WebView test. ASan and
UBSan cover these same methods. Environments that run under ptrace may need
`ASAN_OPTIONS=detect_leaks=0`; that disables only LeakSanitizer, not ASan/UBSan.

Windows CI builds both GPU and CPU-fallback variants, then runs CTest. Four WARP
tests use the production pool with real D3D11 resources: a 4096×2048 pool, a spare
leased before its handle is opened, same-size refill and resize/dispose with an
open consumer. Test logs are saved as workflow artifacts for both variants.

The large-pool test records **two → one** retained textures, each 4096×2048
BGRA8: **64 MiB → 32 MiB of logical pixel storage owned by the bridge**. This
excludes alignment, driver allocations, capture buffers, comparison resources,
WebView2 processes and resources still owned independently by Flutter. These
numbers are not GPU-memory or RSS measurements. WARP correctness also does not
measure device resume latency or flashing.

## Remaining device measurements

Use a profile/release app on Windows with its actual creation result reporting
`composition`. An unset force-HWND switch alone does not establish the backend;
capture failures may select HWND automatically. Record GPU/driver, WebView2 and
Flutter versions, physical viewport dimensions and DPI. Repeat with
`FLUTTER_WEBVIEW_WINDOWS_USE_TEXTURE_FALLBACK=ON` for the CPU path. HWND is a
control and has no shared texture pool to trim.

For several large views, compare the base and this change with the same content:

1. Show each view until its first frame has been consumed. Record pool/staging
   resource dimensions and retained counts separately from process RSS/private
   bytes and GPU dedicated/shared memory, using the native debugger or GPU tools.
2. Switch away for less than 30 seconds and return. Verify no trim-induced
   allocation and record first-frame latency.
3. Keep the views hidden for over 30 seconds, then measure again. A pending spare
   lease can delay its release to the next quiet interval; record this explicitly.
4. Resize while hidden, return, and verify the first newly published frame uses
   the new dimensions while the previous frame remains available beforehand.
5. Repeat with a consumer held across resize/dispose, and inspect for stale
   handles, a stuck frame or flashing. Include minimize/restore and a failed
   capture restart as separate observations.

Representative hardware/GPU measurements and first-frame latency comparisons
are still required before treating the Windows acceptance criteria of #4109 as
complete. Linux WPEPlatform/FDO trimming and the application's dependency pin
are separate changes.
