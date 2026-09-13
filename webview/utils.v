module webview

import json2

pub enum ReturnKind {
	value = 0
	error = 1
}

fn copy_char(s &char) &char {
	if isnil(s) {
		return &char(''.str)
	}
	return unsafe { &char(cstring_to_vstring(s).str) }
}

pub fn (e &Event) @return[T](result T, kind ReturnKind) {
	$if result is voidptr {
		C.webview_return(e.instance, e.event_id, int(kind), &char(''.str))
	} $else $if result is string {
		encoded := json2.encode[string](result)
		C.webview_return(e.instance, e.event_id, int(kind), &char(encoded.str))
	} $else {
		encoded := json2.encode[T](result)
		C.webview_return(e.instance, e.event_id, int(kind), &char(encoded.str))
	}
}

pub fn (e &Event) async() &Event {
	return &Event{e.instance, copy_char(e.event_id), copy_char(e.args)}
}

pub fn (e &Event) get_raw_args() string {
	if isnil(e.args) {
		return ''
	}
	return unsafe { e.args.vstring() }
}

pub fn (e &Event) get_arg[T](idx int) !T {
	raw := e.get_raw_args()
	if raw.len == 0 {
		return error('no arguments provided')
	}
	args := json2.decode[[]T](raw) or {
		return error('Failed decoding argument of type `${T.name}` at index `${idx}`: ${err}')
	}
	i := if idx < 0 { args.len + idx } else { idx }
	if i >= 0 && i < args.len {
		return args[i]
	}
	return error('Argument index ${idx} out of range (length: ${args.len})')
}
