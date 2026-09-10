module webview

#flag linux -DWEBVIEW_GTK
#flag darwin -DWEBVIEW_COCOA -framework WebKit -framework Cocoa -framework AppKit -stdlib=libc++ -lstdc++
#flag windows -DWEBVIEW_EDGE -static -ladvapi32 -lole32 -lshell32 -lshlwapi -luser32 -lversion -lstdc++
#flag darwin @VMODROOT/webview/webview_darwin.o
#flag darwin @VMODROOT/webview/window_helper_darwin.o
#flag linux @VMODROOT/webview/webview_linux.o
#flag linux @VMODROOT/webview/window_helper_linux.o
#include "@VMODROOT/webview/webview.h"
#include "@VMODROOT/webview/window_helper.h"

$if linux {
	#pkgconfig gtk+-3.0
	#pkgconfig fontconfig
	$if $pkgconfig('webkit2gtk-4.1') {
		#pkgconfig webkit2gtk-4.1
	} $else {
		#pkgconfig webkit2gtk-4.0
	}
	#flag linux -lstdc++
}

@[typedef]
struct C.webview_t {}

fn C.webview_create(debug int, window voidptr) C.webview_t
fn C.webview_destroy(w C.webview_t)
fn C.webview_run(w C.webview_t)
fn C.webview_terminate(w C.webview_t)
fn C.webview_dispatch(w C.webview_t, func fn (w C.webview_t, ctx voidptr), ctx voidptr)
fn C.webview_get_window(w C.webview_t) voidptr
fn C.webview_set_title(w C.webview_t, title &char)
fn C.webview_set_size(w C.webview_t, width int, height int, hints int)
fn C.webview_navigate(w C.webview_t, url &char)
fn C.webview_set_html(w C.webview_t, html &char)
fn C.webview_init(w C.webview_t, code &char)
fn C.webview_eval(w C.webview_t, code &char)
fn C.webview_bind(w C.webview_t, func_name &char, func fn (event_id &char, args &char, ctx voidptr), ctx voidptr)
fn C.webview_unbind(w C.webview_t, func_name &char)
fn C.webview_return(w C.webview_t, event_id &char, status int, result &char)

fn C.rad_window_set_always_on_top(window_handle voidptr, on_top int)
fn C.rad_window_toggle_fullscreen(window_handle voidptr)
fn C.rad_window_set_fullscreen(window_handle voidptr, fullscreen int)
fn C.rad_window_minimize(window_handle voidptr)
fn C.rad_window_hide(window_handle voidptr)
fn C.rad_window_center(window_handle voidptr)
fn C.rad_window_set_position(window_handle voidptr, preset &char)
fn C.rad_window_get_screen_size(out_width &int, out_height &int)
fn C.rad_window_init_shortcuts()
fn C.rad_window_quit()
