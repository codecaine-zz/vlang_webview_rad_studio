module webview

@[heap]
pub struct Webview {
mut:
	w             C.webview_t
	always_on_top bool
	is_fullscreen bool
}

pub struct Event {
pub:
	instance C.webview_t
	event_id &char
	args     &char
}

struct EvalContext {
mut:
	webview C.webview_t
	code    &char
}

@[params]
pub struct CreateOptions {
pub:
	debug  ?bool
	window voidptr
}

pub enum Hint {
	@none = 0
	fixed = 1
	min   = 2
	max   = 3
}

pub const no_result = unsafe { nil }
const debug = $if webview_debug ? { true } $else { false }

pub fn create(opts CreateOptions) &Webview {
	dbg := if opt := opts.debug {
		opt
	} else {
		debug
	}
	return &Webview{
		w: C.webview_create(int(dbg), opts.window)
		always_on_top: false
		is_fullscreen: false
	}
}

pub fn (w Webview) destroy() {
	C.webview_destroy(w.w)
}

pub fn (w &Webview) run() {
	C.webview_run(w.w)
}

pub fn (w &Webview) terminate() {
	C.webview_terminate(w.w)
}

pub fn (w &Webview) dispatch(func fn ()) {
	C.webview_dispatch(w.w, fn [func] (w C.webview_t, ctx voidptr) {
		func()
	}, 0)
}

pub fn (w &Webview) get_window() voidptr {
	return C.webview_get_window(w.w)
}

pub fn (w &Webview) set_title(title string) {
	C.webview_set_title(w.w, &char(title.str))
}

pub fn (w &Webview) set_size(width int, height int, hint Hint) {
	C.webview_set_size(w.w, width, height, int(hint))
}

pub fn (w &Webview) navigate(url string) {
	C.webview_navigate(w.w, &char(url.str))
}

pub fn (w &Webview) set_html(html string) {
	C.webview_set_html(w.w, &char(html.str))
}

pub fn (w &Webview) init(code string) {
	C.webview_init(w.w, &char(code.str))
}

pub fn (w &Webview) eval(code string) {
	mut context := unsafe { &EvalContext(malloc(sizeof(EvalContext))) }
	context.webview = w.w
	context.code = C.strdup(&char(code.str))
	C.webview_dispatch(w.w, eval_on_ui_thread, context)
}

fn eval_on_ui_thread(_ C.webview_t, raw_context voidptr) {
	context := unsafe { &EvalContext(raw_context) }
	C.webview_eval(context.webview, context.code)
	C.free(context.code)
	unsafe {
		free(context)
	}
}

pub fn (w &Webview) bind[T](name string, func fn (&Event) T) {
	C.webview_bind(w.w, &char(name.str), fn [w, func] [T](event_id &char, args &char, ctx voidptr) {
		e := unsafe { &Event{w.w, event_id, args} }.async()
		spawn fn [func, e] [T]() {
			result := func(e)
			e.return(result, .value)
		}()
	}, 0)
}

pub fn (w &Webview) bind_opt[T](name string, func fn (&Event) !T) {
	C.webview_bind(w.w, &char(name.str), fn [w, func] [T](event_id &char, args &char, ctx voidptr) {
		e := unsafe { &Event{w.w, event_id, args} }.async()
		spawn fn [func, e] [T]() {
			if result := func(e) {
				e.return(result, .value)
			} else {
				e.return(err.str(), .error)
			}
		}()
	}, 0)
}

// Native Window Management Methods

pub fn (mut w Webview) set_always_on_top(on_top bool) {
	w.always_on_top = on_top
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_set_always_on_top(handle, if on_top { 1 } else { 0 })
	}
}

pub fn (mut w Webview) toggle_always_on_top() bool {
	w.set_always_on_top(!w.always_on_top)
	return w.always_on_top
}

pub fn (mut w Webview) toggle_fullscreen() {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_toggle_fullscreen(handle)
		w.is_fullscreen = !w.is_fullscreen
	}
}

pub fn (mut w Webview) set_fullscreen(fullscreen bool) {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_set_fullscreen(handle, if fullscreen { 1 } else { 0 })
		w.is_fullscreen = fullscreen
	}
}

pub fn (w &Webview) minimize() {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_minimize(handle)
	}
}

pub fn (w &Webview) hide() {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_hide(handle)
	}
}

pub fn (w &Webview) center() {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_center(handle)
	}
}

pub fn (w &Webview) set_position(preset string) {
	handle := w.get_window()
	if !isnil(handle) {
		C.rad_window_set_position(handle, &char(preset.str))
	}
}

pub fn get_screen_size() (int, int) {
	mut width := 0
	mut height := 0
	C.rad_window_get_screen_size(&width, &height)
	if width <= 0 || height <= 0 {
		return 1920, 1080
	}
	return width, height
}

// Automatically binds standard RAD Studio window actions to JavaScript
pub fn (mut w Webview) attach_window_management_bindings() {
	C.rad_window_init_shortcuts()

	w.bind('quitApp', fn (e &Event) string {
		C.rad_window_quit()
		return 'ok'
	})

	w.bind('closeWindow', fn (e &Event) string {
		C.rad_window_quit()
		return 'ok'
	})

	w.bind('exitApp', fn (e &Event) string {
		C.rad_window_quit()
		return 'ok'
	})

	w.bind('minimizeWindow', fn [w] (e &Event) string {
		w.minimize()
		return 'ok'
	})

	w.bind('hideApp', fn [w] (e &Event) string {
		w.hide()
		return 'ok'
	})

	w.bind('toggleFullscreen', fn [mut w] (e &Event) string {
		w.toggle_fullscreen()
		return 'ok'
	})

	w.bind('toggleNativeFullscreen', fn [mut w] (e &Event) string {
		w.toggle_fullscreen()
		return 'ok'
	})

	w.bind('setAlwaysOnTop', fn [mut w] (e &Event) string {
		on_top_val := e.get_arg[bool](0) or { true }
		w.set_always_on_top(on_top_val)
		return if on_top_val { 'true' } else { 'false' }
	})

	w.bind('toggleAlwaysOnTop', fn [mut w] (e &Event) string {
		res := w.toggle_always_on_top()
		return if res { 'true' } else { 'false' }
	})

	w.bind('centerWindow', fn [w] (e &Event) string {
		w.center()
		return 'ok'
	})

	w.bind('setWindowPosition', fn [w] (e &Event) string {
		preset := e.get_arg[string](0) or { 'center' }
		w.set_position(preset)
		return preset
	})

	// Universal client-side desktop helpers: disables default browser contextmenu (reload/inspect),
	// blocks accidental reload keys (F5, Cmd+R, Ctrl+R), and binds standard desktop shortcuts:
	// Cmd+F/Ctrl+F/F11 (Fullscreen), Cmd+M/Ctrl+M (Minimize), Cmd+Shift+T (Always on Top), Cmd+Shift+C (Center), Cmd+Q/Cmd+W/Alt+F4 (Quit/Close)
	w.init('(function() {
	if (window.__radDesktopShortcutsInstalled) return;
	window.__radDesktopShortcutsInstalled = true;

	// 1. Prevent default browser context menu globally to prevent Reload & Inspect Element
	window.addEventListener("contextmenu", function(e) {
		e.preventDefault();
	}, true);

	// 2. Prevent accidental browser reload & bind desktop shortcuts
	window.addEventListener("keydown", function(e) {
		var isCmdOrCtrl = e.metaKey || e.ctrlKey;
		var key = (e.key || "").toLowerCase();
		var code = e.code || "";

		// Prevent F5 and Cmd+R / Ctrl+R reload
		if (e.key === "F5" || code === "F5" || (isCmdOrCtrl && (key === "r" || code === "KeyR"))) {
			e.preventDefault();
			e.stopPropagation();
			return false;
		}

		// Fullscreen: Cmd+F / Ctrl+F / F11
		if ((isCmdOrCtrl && (key === "f" || code === "KeyF")) || key === "f11" || code === "F11") {
			e.preventDefault();
			e.stopPropagation();
			if (window.toggleNativeFullscreen) {
				window.toggleNativeFullscreen();
			} else if (window.toggleFullscreen) {
				window.toggleFullscreen();
			}
			return false;
		}

		// Minimize: Cmd+M / Ctrl+M / Alt+M
		if ((isCmdOrCtrl || e.altKey) && (key === "m" || code === "KeyM")) {
			e.preventDefault();
			e.stopPropagation();
			if (window.minimizeWindow) {
				window.minimizeWindow();
			}
			return false;
		}

		// Always-On-Top Toggle: Cmd+Shift+T / Ctrl+Shift+T / Alt+T
		if ((isCmdOrCtrl && e.shiftKey && (key === "t" || code === "KeyT")) || (e.altKey && !isCmdOrCtrl && (key === "t" || code === "KeyT"))) {
			e.preventDefault();
			e.stopPropagation();
			if (window.toggleAlwaysOnTop) {
				window.toggleAlwaysOnTop();
			}
			return false;
		}

		// Center Window: Cmd+Shift+C / Ctrl+Shift+C
		if (isCmdOrCtrl && e.shiftKey && (key === "c" || code === "KeyC")) {
			e.preventDefault();
			e.stopPropagation();
			if (window.centerWindow) {
				window.centerWindow();
			}
			return false;
		}

		// Close / Quit: Cmd+Q / Cmd+W / Ctrl+Q / Ctrl+W / Alt+F4
		if ((isCmdOrCtrl && (key === "q" || key === "w" || code === "KeyQ" || code === "KeyW")) || (e.altKey && (key === "f4" || code === "F4"))) {
			e.preventDefault();
			e.stopPropagation();
			if (window.quitApp) {
				window.quitApp();
			} else if (window.closeWindow) {
				window.closeWindow();
			}
			return false;
		}
	}, true);
})();')
}
