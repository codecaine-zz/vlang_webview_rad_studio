module simplegui

import webview
import system
import os
import sync

pub type EventCallback = fn (win &SimpleWindow, val string)

@[params]
pub struct SimpleWindowOptions {
pub:
	title         string = 'SimpleGUI Desktop Application'
	width         int = 1000
	height        int = 700
	theme         string = 'monokai_pro'
	fullscreen    bool = true
	always_on_top bool
	padding       int = 24
	spacing       int = 16
}

@[heap]
pub struct SimpleWindow {
pub mut:
	title                   string
	width                   int
	height                  int
	theme_name              string
	fullscreen              bool
	always_on_top           bool
	padding                 int
	spacing                 int
	controls                []ControlSpec
	values                  map[string]string
	event_handlers          map[string]EventCallback
	menubar                 []MenuCategory
	menubar_handler_id      string
	context_menu_items      []MenuItem
	context_menu_handler_id string
	wv                      &webview.Webview = unsafe { nil }
	control_seq             int
	input_seq               int
	name_to_ctrl            map[string]int
	last_ctrl_id            string
	is_debug_mode           bool
	min_width               int
	min_height              int
	max_width               int
	max_height              int
	opacity                 f64 = 1.0
	cursor_name             string = 'arrow'
	is_resizable            bool = true
	is_minimizable          bool = true
	is_maximizable          bool = true
	responsive_layout       bool = true
	status_text             string
	x_pos                   int = 100
	y_pos                   int = 100
	action_lock             sync.Mutex
	action_active           bool
	state_lock              sync.Mutex
}

pub fn new_window(opts SimpleWindowOptions) &SimpleWindow {
	return &SimpleWindow{
		title: opts.title
		width: opts.width
		height: opts.height
		theme_name: opts.theme
		fullscreen: opts.fullscreen
		always_on_top: opts.always_on_top
		padding: opts.padding
		spacing: opts.spacing
		controls: []ControlSpec{}
		values: map[string]string{}
		event_handlers: map[string]EventCallback{}
		menubar: []MenuCategory{}
		menubar_handler_id: ''
		context_menu_items: []MenuItem{}
		context_menu_handler_id: ''
		control_seq: 0
		input_seq: 0
		name_to_ctrl: map[string]int{}
		last_ctrl_id: ''
		is_debug_mode: false
		min_width: 200
		min_height: 150
		max_width: 3840
		max_height: 2160
		opacity: 1.0
		cursor_name: 'arrow'
		is_resizable: true
		is_minimizable: true
		is_maximizable: true
		responsive_layout: true
		status_text: ''
		x_pos: 100
		y_pos: 100
		action_active: false
	}
}

fn (mut win SimpleWindow) try_begin_action() bool {
	win.action_lock.lock()
	defer {
		win.action_lock.unlock()
	}
	if win.action_active {
		return false
	}
	win.action_active = true
	return true
}

fn (mut win SimpleWindow) end_action() {
	win.action_lock.lock()
	win.action_active = false
	win.action_lock.unlock()
}

pub fn new_simple_window(title string, width int, height int) &SimpleWindow {
	return new_window(
		title: title
		width: width
		height: height
	)
}

// Fluent Control Registration & Identification

fn (mut win SimpleWindow) next_id(prefix string) string {
	win.control_seq++
	return '${prefix}_${win.control_seq}'
}

fn (mut win SimpleWindow) register_control(name string, spec ControlSpec) string {
	id := if name != '' { name } else { win.next_id('ctrl') }
	mut final_spec := spec
	final_spec.id = id
	if final_spec.click_id == '' {
		final_spec.click_id = 'click_${id}'
	}
	if final_spec.change_id == '' {
		final_spec.change_id = 'change_${id}'
	}
	idx := win.controls.len
	win.controls << final_spec
	win.name_to_ctrl[id] = idx
	win.last_ctrl_id = id
	if spec.typ in [.input, .password, .textarea, .search_field] {
		win.input_seq++
		inp_alias := 'inp_${win.input_seq}'
		win.name_to_ctrl[inp_alias] = idx
		if spec.value != '' {
			win.values[inp_alias] = spec.value
		}
	}
	return id
}

// ---------------------------------------------------------
// Named Control Builders (Parity with vlang_simplegui API)
// ---------------------------------------------------------

pub fn (mut win SimpleWindow) add_input(name string, value string) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .input
		value: value
	})
	win.values[id] = value
	return win
}

pub fn (mut win SimpleWindow) add_password(name string, value string) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .password
		value: value
	})
	win.values[id] = value
	return win
}

pub fn (mut win SimpleWindow) add_textarea(name string, value string) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .textarea
		value: value
	})
	win.values[id] = value
	return win
}

pub fn (mut win SimpleWindow) add_search_field(name string, placeholder string) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .search_field
		placeholder: placeholder
	})
	win.values[id] = ''
	return win
}

pub fn (mut win SimpleWindow) add_label(name string, text string) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .label
		text: text
	})
	return win
}

pub fn (mut win SimpleWindow) add_heading(title string) &SimpleWindow {
	win.register_control('', ControlSpec{
		typ: .heading
		text: title
	})
	return win
}

pub fn (mut win SimpleWindow) add_subheading(title string) &SimpleWindow {
	win.register_control('', ControlSpec{
		typ: .subheading
		text: title
	})
	return win
}

pub fn (mut win SimpleWindow) add_section_header(name string, title string, subtitle string) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .section_header
		text: title
		secondary_text: subtitle
	})
	return win
}

pub fn (mut win SimpleWindow) add_hotkey_badge(name string, shortcut_str string, description string) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .hotkey_badge
		text: shortcut_str
		secondary_text: description
	})
	return win
}

pub fn (mut win SimpleWindow) add_button(name string, title string) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .button
		text: title
	})
	return win
}

pub fn (mut win SimpleWindow) add_image_button(name string, symbol string, title string) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .button
		text: if title != '' { '${symbol} ${title}' } else { symbol }
	})
	return win
}

pub fn (mut win SimpleWindow) add_help_button(name string) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .button
		text: '?'
		css_class: 'sg-btn-help'
	})
	return win
}

pub fn (mut win SimpleWindow) add_split_button(name string, title string, menu_items []string) &SimpleWindow {
	mut opts := [title]
	opts << menu_items
	id := win.register_control(name, ControlSpec{
		typ: .dropdown
		options: opts
		value: title
	})
	win.values[id] = title
	return win
}

pub fn (mut win SimpleWindow) add_badge_button(name string, title string, count int, badge_color string) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .button
		text: '${title} (${count})'
		background_color: badge_color
	})
	return win
}

pub fn (mut win SimpleWindow) add_link(name string, text string, url string) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .button
		text: text
		value: url
		css_class: 'sg-link'
	})
	win.event_handlers['click_${id}'] = fn [url] (_ &SimpleWindow, _ string) {
		system.open_url(url)
	}
	return win
}

pub fn (mut win SimpleWindow) add_checkbox(name string, label string, checked bool) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .checkbox
		text: label
		checked: checked
	})
	win.values[id] = checked.str()
	return win
}

pub fn (mut win SimpleWindow) add_switch(name string, label string, checked bool) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .toggle
		text: label
		checked: checked
	})
	win.values[id] = checked.str()
	return win
}

pub fn (mut win SimpleWindow) add_toggle(name string, label string, checked bool) &SimpleWindow {
	return win.add_switch(name, label, checked)
}

pub fn (mut win SimpleWindow) add_radio(name string, label string, checked bool) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .radio
		text: label
		checked: checked
		secondary_text: 'sg_default_radio_group'
	})
	win.values[id] = checked.str()
	return win
}

pub fn (mut win SimpleWindow) add_radio_group(name string, items []string, selected string) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .radio
		options: items
		value: selected
		secondary_text: name
	})
	win.values[id] = selected
	return win
}

pub fn (mut win SimpleWindow) add_dropdown(name string, items []string, selected string) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .dropdown
		options: items
		value: selected
	})
	win.values[id] = selected
	return win
}

pub fn (mut win SimpleWindow) add_pull_down(name string, title string, items []string) &SimpleWindow {
	mut opts := [title]
	opts << items
	id := win.register_control(name, ControlSpec{
		typ: .dropdown
		options: opts
		value: title
		text: title
	})
	win.values[id] = title
	return win
}

pub fn (mut win SimpleWindow) add_combo_box(name string, items []string, selected string) &SimpleWindow {
	return win.add_dropdown(name, items, selected)
}

pub fn (mut win SimpleWindow) add_theme_menu(name string, selected string) &SimpleWindow {
	return win.add_dropdown(name, list_themes(), selected)
}

pub fn (mut win SimpleWindow) add_segmented_control(name string, items []string, selected string) &SimpleWindow {
	return win.add_dropdown(name, items, selected)
}

pub fn (mut win SimpleWindow) add_mode_control(name string, selected string) &SimpleWindow {
	return win.add_dropdown(name, ['Simple', 'Advanced', 'Expert'], selected)
}

pub fn (mut win SimpleWindow) add_slider(name string, min int, max int, value int) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .slider
		min_val: min
		max_val: max
		value: value.str()
	})
	win.values[id] = value.str()
	return win
}

pub fn (mut win SimpleWindow) add_stepper(name string, min int, max int, value int) &SimpleWindow {
	return win.add_slider(name, min, max, value)
}

pub fn (mut win SimpleWindow) add_number_input(name string, min int, max int, value int) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .input
		min_val: min
		max_val: max
		value: value.str()
	})
	win.values[id] = value.str()
	return win
}

pub fn (mut win SimpleWindow) add_progress_indicator(name string, value int) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .progress
		value: value.str()
		max_val: 100
	})
	win.values[id] = value.str()
	return win
}

pub fn (mut win SimpleWindow) add_progress_bar(name string, value int) &SimpleWindow {
	return win.add_progress_indicator(name, value)
}

pub fn (mut win SimpleWindow) add_progress(name string, value int, max int) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .progress
		value: value.str()
		max_val: max
	})
	win.values[id] = value.str()
	return win
}

pub fn (mut win SimpleWindow) add_circular_progress(name string, value int) &SimpleWindow {
	return win.add_progress_indicator(name, value)
}

pub fn (mut win SimpleWindow) add_kpi_card(name string, title string, value string, subtitle string) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .kpi_card
		text: title
		value: value
		secondary_text: subtitle
	})
	return win
}

pub fn (mut win SimpleWindow) add_badge(name string, text string, color string) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .badge
		text: text
		background_color: color
		font_color: '#ffffff'
	})
	return win
}

pub fn (mut win SimpleWindow) add_divider(name string) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .divider
	})
	return win
}

pub fn (mut win SimpleWindow) add_divider_line() &SimpleWindow {
	return win.add_divider('')
}

pub fn (mut win SimpleWindow) add_spacer(name string, height int) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .raw_html
		text: '<div style="height: ${height}px;"></div>'
		height: height
	})
	return win
}

pub fn (mut win SimpleWindow) add_space(height int) &SimpleWindow {
	return win.add_spacer('', height)
}

pub fn (mut win SimpleWindow) add_status_bar(name string, text string) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .status_bar
		text: text
	})
	return win
}

pub fn (mut win SimpleWindow) add_date_picker(name string, date string) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .date_picker
		value: date
	})
	win.values[id] = date
	return win
}

pub fn (mut win SimpleWindow) add_color_picker(name string, default_color string) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .color_picker
		value: default_color
		text: default_color
	})
	win.values[id] = default_color
	return win
}

pub fn (mut win SimpleWindow) add_table(name string, headers []string, rows [][]string) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .table
		headers: headers
		rows: rows
	})
	return win
}

pub fn (mut win SimpleWindow) add_image(name string, src string, width int, height int) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .image
		value: src
		width: width
		height: height
	})
	return win
}

pub fn (mut win SimpleWindow) add_markdown(name string, md_text string) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .markdown
		text: md_text
	})
	return win
}

pub fn (mut win SimpleWindow) add_code_view(name string, code string, language string) &SimpleWindow {
	win.register_control(name, ControlSpec{
		typ: .code_view
		text: code
		secondary_text: language
	})
	return win
}

pub fn (mut win SimpleWindow) add_alert_banner(name string, title string, message string, level string) &SimpleWindow {
	bg := match level {
		'success' { '#1b4332' }
		'warning' { '#7f4f24' }
		'error' { '#590d22' }
		else { '#2b2d42' }
	}
	win.register_control(name, ControlSpec{
		typ: .raw_html
		text: '<div id="${name}" class="sg-kpi-card" style="background-color: ${bg}; margin-bottom: 8px;"><div style="font-weight:700; font-size:15px; margin-bottom:4px;">${title}</div><div style="font-size:13px; opacity:0.9;">${message}</div></div>'
	})
	return win
}

pub fn (mut win SimpleWindow) add_group_box(name string, title string) &SimpleWindow {
	return win.box_start(title)
}

pub fn (mut win SimpleWindow) add_tabs(name string, titles []string) &SimpleWindow {
	return win.add_dropdown(name, titles, titles[0] or { '' })
}

pub fn (mut win SimpleWindow) add_scroll_view(name string, height int) &SimpleWindow {
	return win.raw_html('<div id="${name}" style="max-height: ${height}px; overflow-y: auto; padding-right: 8px;">')
}

// ---------------------------------------------------------
// Layout Containers & Structure Helpers
// ---------------------------------------------------------

pub fn (mut win SimpleWindow) begin_row(name string) &SimpleWindow {
	return win.raw_html('<div id="${name}" class="sg-row">')
}

pub fn (mut win SimpleWindow) end_row() &SimpleWindow {
	return win.raw_html('</div>')
}

pub fn (mut win SimpleWindow) row(name string, callback fn (win &SimpleWindow)) &SimpleWindow {
	win.begin_row(name)
	callback(win)
	win.end_row()
	return win
}

pub fn (mut win SimpleWindow) begin_grid(name string, columns int, spacing int) &SimpleWindow {
	cols := if columns > 0 { columns } else { 2 }
	return win.raw_html('<div id="${name}" style="display: grid; grid-template-columns: repeat(${cols}, 1fr); gap: ${spacing}px; width: 100%;">')
}

pub fn (mut win SimpleWindow) end_grid() &SimpleWindow {
	return win.raw_html('</div>')
}

pub fn (mut win SimpleWindow) begin_flex_box(name string, direction string, justify string, align string) &SimpleWindow {
	dir := if direction == 'column' { 'column' } else { 'row' }
	mut j_val := 'flex-start'
	match justify {
		'center' {
			j_val = 'center'
		}
		'end' {
			j_val = 'flex-end'
		}
		'space_between' {
			j_val = 'space-between'
		}
		'space_around' {
			j_val = 'space-around'
		}
		else {}
	}
	mut a_val := 'center'
	match align {
		'start' {
			a_val = 'flex-start'
		}
		'end' {
			a_val = 'flex-end'
		}
		'stretch' {
			a_val = 'stretch'
		}
		else {}
	}
	return win.raw_html('<div id="${name}" style="display: flex; flex-direction: ${dir}; justify-content: ${j_val}; align-items: ${a_val}; gap: 12px; width: 100%;">')
}

pub fn (mut win SimpleWindow) end_flex_box() &SimpleWindow {
	return win.raw_html('</div>')
}

pub fn (mut win SimpleWindow) card(name string, callback fn (win &SimpleWindow)) &SimpleWindow {
	win.raw_html('<div id="${name}" class="sg-kpi-card" style="margin-bottom:8px;">')
	callback(win)
	win.raw_html('</div>')
	return win
}

pub fn (mut win SimpleWindow) card_with_title(name string, title string, callback fn (win &SimpleWindow)) &SimpleWindow {
	win.raw_html('<div id="${name}" class="sg-kpi-card" style="margin-bottom:8px;"><div class="sg-kpi-title" style="margin-bottom:8px;font-weight:700;">${title}</div>')
	callback(win)
	win.raw_html('</div>')
	return win
}

pub fn (mut win SimpleWindow) group(name string, title string, callback fn (win &SimpleWindow)) &SimpleWindow {
	return win.card_with_title(name, title, callback)
}

// ---------------------------------------------------------
// Event Handlers & Chained Wiring
// ---------------------------------------------------------

pub fn (win &SimpleWindow) on_click(name string, cb EventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.event_handlers['click_${name}'] = cb
	}
	return win
}

pub fn (win &SimpleWindow) on_change(name string, cb EventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.event_handlers['change_${name}'] = cb
	}
	return win
}

pub fn (win &SimpleWindow) on_enter(name string, cb EventCallback) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.event_handlers['enter_${name}'] = cb
	}
	return win
}

pub fn (win &SimpleWindow) on_select_item(name string, cb EventCallback) &SimpleWindow {
	return win.on_change(name, cb)
}

pub fn (win &SimpleWindow) onclick(cb EventCallback) &SimpleWindow {
	if win.last_ctrl_id != '' {
		return win.on_click(win.last_ctrl_id, cb)
	}
	return win
}

pub fn (win &SimpleWindow) onchange(cb EventCallback) &SimpleWindow {
	if win.last_ctrl_id != '' {
		return win.on_change(win.last_ctrl_id, cb)
	}
	return win
}

pub fn (win &SimpleWindow) onenter(cb EventCallback) &SimpleWindow {
	if win.last_ctrl_id != '' {
		return win.on_enter(win.last_ctrl_id, cb)
	}
	return win
}

// ---------------------------------------------------------
// Fluent Control Modifiers (Operate on last created control)
// ---------------------------------------------------------

pub fn (mut win SimpleWindow) width(w int) &SimpleWindow {
	if win.last_ctrl_id != '' {
		if idx := win.name_to_ctrl[win.last_ctrl_id] {
			win.controls[idx].width = w
		}
	}
	return win
}

pub fn (mut win SimpleWindow) height(h int) &SimpleWindow {
	if win.last_ctrl_id != '' {
		if idx := win.name_to_ctrl[win.last_ctrl_id] {
			win.controls[idx].height = h
		}
	}
	return win
}

pub fn (mut win SimpleWindow) placeholder(p string) &SimpleWindow {
	if win.last_ctrl_id != '' {
		if idx := win.name_to_ctrl[win.last_ctrl_id] {
			win.controls[idx].placeholder = p
		}
	}
	return win
}

pub fn (mut win SimpleWindow) tooltip(t string) &SimpleWindow {
	if win.last_ctrl_id != '' {
		if idx := win.name_to_ctrl[win.last_ctrl_id] {
			win.controls[idx].tooltip = t
		}
	}
	return win
}

pub fn (mut win SimpleWindow) font_size(sz int) &SimpleWindow {
	if win.last_ctrl_id != '' {
		if idx := win.name_to_ctrl[win.last_ctrl_id] {
			win.controls[idx].font_size = sz
		}
	}
	return win
}

pub fn (mut win SimpleWindow) bold(b bool) &SimpleWindow {
	if win.last_ctrl_id != '' {
		if idx := win.name_to_ctrl[win.last_ctrl_id] {
			win.controls[idx].is_bold = b
		}
	}
	return win
}

pub fn (mut win SimpleWindow) font_color(color string) &SimpleWindow {
	if win.last_ctrl_id != '' {
		if idx := win.name_to_ctrl[win.last_ctrl_id] {
			win.controls[idx].font_color = color
		}
	}
	return win
}

pub fn (mut win SimpleWindow) background_color(color string) &SimpleWindow {
	if win.last_ctrl_id != '' {
		if idx := win.name_to_ctrl[win.last_ctrl_id] {
			win.controls[idx].background_color = color
		}
	}
	return win
}

pub fn (mut win SimpleWindow) expand_fill() &SimpleWindow {
	if win.last_ctrl_id != '' {
		if idx := win.name_to_ctrl[win.last_ctrl_id] {
			win.controls[idx].expand_fill = true
		}
	}
	return win
}

pub fn (win &SimpleWindow) set_control_enabled(name string, enabled bool) &SimpleWindow {
	mut actual_id := name
	unsafe {
		mut mut_win := &SimpleWindow(voidptr(win))
		mut_win.state_lock.lock()
		defer {
			mut_win.state_lock.unlock()
		}
		if idx := mut_win.name_to_ctrl[name] {
			actual_id = mut_win.controls[idx].id
			mut_win.controls[idx].enabled = enabled
		}
	}
	if !isnil(win.wv) {
		control_id := system.json_escape(actual_id)
		disabled := if !enabled { 'true' } else { 'false' }
		win.wv.eval('
			const control = document.getElementById(${control_id});
			if (control) {
				if (control.dataset.sgPreviousDisabled !== undefined) {
					control.dataset.sgPreviousDisabled = "${disabled}";
				} else {
					control.disabled = ${disabled};
				}
			}
		')
	}
	return win
}

fn (win &SimpleWindow) set_action_controls_enabled(enabled bool) {
	if !isnil(win.wv) {
		if enabled {
			win.wv.eval('
				document.querySelectorAll("button, input, textarea, select").forEach((control) => {
					if (control.dataset.sgPreviousDisabled !== undefined) {
						control.disabled = control.dataset.sgPreviousDisabled === "true";
						delete control.dataset.sgPreviousDisabled;
					}
				});
				document.querySelectorAll(".sg-table tbody, .sg-menu-item, .sg-context-item").forEach((control) => {
					control.style.pointerEvents = control.dataset.sgPreviousPointerEvents || "";
					delete control.dataset.sgPreviousPointerEvents;
				});
			')
		} else {
			win.wv.eval('
				document.querySelectorAll("button, input, textarea, select").forEach((control) => {
					if (control.dataset.sgPreviousDisabled === undefined) {
						control.dataset.sgPreviousDisabled = String(control.disabled);
						control.disabled = true;
					}
				});
				document.querySelectorAll(".sg-table tbody, .sg-menu-item, .sg-context-item").forEach((control) => {
					if (control.dataset.sgPreviousPointerEvents === undefined) {
						control.dataset.sgPreviousPointerEvents = control.style.pointerEvents;
						control.style.pointerEvents = "none";
					}
				});
			')
		}
	}
}

pub fn (win &SimpleWindow) set_control_visible(name string, visible bool) &SimpleWindow {
	if !isnil(win.wv) {
		disp := if visible { '' } else { 'none' }
		win.wv.eval('if (document.getElementById("${name}")) { document.getElementById("${name}").style.display = "${disp}"; }')
	}
	return win
}

pub fn (mut win SimpleWindow) set_control_alignment(name string, alignment string) &SimpleWindow {
	if idx := win.name_to_ctrl[name] {
		win.controls[idx].alignment = alignment
	}
	return win
}

pub fn (win &SimpleWindow) get_control_alignment(name string) string {
	if idx := win.name_to_ctrl[name] {
		return win.controls[idx].alignment
	}
	return 'left'
}

pub fn (mut win SimpleWindow) set_control_expand_fill(name string, expand bool) &SimpleWindow {
	if idx := win.name_to_ctrl[name] {
		win.controls[idx].expand_fill = expand
	}
	return win
}

pub fn (win &SimpleWindow) get_control_expand_fill(name string) bool {
	if idx := win.name_to_ctrl[name] {
		return win.controls[idx].expand_fill
	}
	return false
}

pub fn (mut win SimpleWindow) set_default_button(name string) &SimpleWindow {
	return win
}

// ---------------------------------------------------------
// Control Inspection, Querying & Developer Diagnostics
// ---------------------------------------------------------

pub fn (win &SimpleWindow) has_control(name string) bool {
	return name in win.name_to_ctrl || win.controls.any(it.id == name)
}

pub fn (win &SimpleWindow) list_controls() []string {
	mut list := []string{}
	for ctrl in win.controls {
		if ctrl.id != '' && !ctrl.id.starts_with('ctrl_') {
			list << ctrl.id
		}
	}
	return list
}

pub fn (win &SimpleWindow) get_control_kind(name string) string {
	if idx := win.name_to_ctrl[name] {
		return '${win.controls[idx].typ}'
	}
	for ctrl in win.controls {
		if ctrl.id == name {
			return '${ctrl.typ}'
		}
	}
	return ''
}

pub fn (win &SimpleWindow) require_control(name string) string {
	if !win.has_control(name) {
		panic('SimpleGUI error: required control not found: "${name}"')
	}
	return name
}

// ---------------------------------------------------------
// Backward-Compatible Anonymous Fluent Builders
// ---------------------------------------------------------

pub fn (mut win SimpleWindow) button(text string, on_click EventCallback) &SimpleWindow {
	id := win.register_control('', ControlSpec{
		typ: .button
		text: text
	})
	win.event_handlers['click_${id}'] = on_click
	return win
}

pub fn (mut win SimpleWindow) label(text string) &SimpleWindow {
	win.register_control('', ControlSpec{
		typ: .label
		text: text
	})
	return win
}

pub fn (mut win SimpleWindow) heading(text string) &SimpleWindow {
	win.register_control('', ControlSpec{
		typ: .heading
		text: text
	})
	return win
}

pub fn (mut win SimpleWindow) subheading(text string) &SimpleWindow {
	win.register_control('', ControlSpec{
		typ: .subheading
		text: text
	})
	return win
}

pub fn (mut win SimpleWindow) input(placeholder string, default_val string, on_change EventCallback) &SimpleWindow {
	id := win.register_control('', ControlSpec{
		typ: .input
		placeholder: placeholder
		value: default_val
	})
	win.values[id] = default_val
	win.event_handlers['change_${id}'] = on_change
	return win
}

pub fn (mut win SimpleWindow) input_named(name string, placeholder string, default_val string, on_change EventCallback) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .input
		placeholder: placeholder
		value: default_val
	})
	win.values[id] = default_val
	win.event_handlers['change_${id}'] = on_change
	return win
}

pub fn (mut win SimpleWindow) password(placeholder string, default_val string, on_change EventCallback) &SimpleWindow {
	id := win.register_control('', ControlSpec{
		typ: .password
		placeholder: placeholder
		value: default_val
	})
	win.values[id] = default_val
	win.event_handlers['change_${id}'] = on_change
	return win
}

pub fn (mut win SimpleWindow) textarea(placeholder string, default_val string, on_change EventCallback) &SimpleWindow {
	id := win.register_control('', ControlSpec{
		typ: .textarea
		placeholder: placeholder
		value: default_val
	})
	win.values[id] = default_val
	win.event_handlers['change_${id}'] = on_change
	return win
}

pub fn (mut win SimpleWindow) textarea_named(name string, placeholder string, default_val string, on_change EventCallback) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .textarea
		placeholder: placeholder
		value: default_val
	})
	win.values[id] = default_val
	win.event_handlers['change_${id}'] = on_change
	return win
}

pub fn (mut win SimpleWindow) checkbox(label string, checked bool, on_change EventCallback) &SimpleWindow {
	id := win.register_control('', ControlSpec{
		typ: .checkbox
		text: label
		checked: checked
	})
	win.values[id] = if checked { 'true' } else { 'false' }
	win.event_handlers['change_${id}'] = on_change
	return win
}

pub fn (mut win SimpleWindow) radio(group_name string, label string, checked bool, on_change EventCallback) &SimpleWindow {
	id := win.register_control('', ControlSpec{
		typ: .radio
		text: label
		secondary_text: group_name
		value: label
		checked: checked
	})
	win.values[id] = if checked { label } else { '' }
	win.event_handlers['change_${id}'] = on_change
	return win
}

pub fn (mut win SimpleWindow) toggle(label string, checked bool, on_change EventCallback) &SimpleWindow {
	id := win.register_control('', ControlSpec{
		typ: .toggle
		text: label
		checked: checked
	})
	win.values[id] = if checked { 'true' } else { 'false' }
	win.event_handlers['change_${id}'] = on_change
	return win
}

pub fn (mut win SimpleWindow) slider(min_val int, max_val int, default_val int, on_change EventCallback) &SimpleWindow {
	id := win.register_control('', ControlSpec{
		typ: .slider
		min_val: min_val
		max_val: max_val
		value: default_val.str()
	})
	win.values[id] = default_val.str()
	win.event_handlers['change_${id}'] = on_change
	return win
}

pub fn (mut win SimpleWindow) dropdown(options []string, selected string, on_change EventCallback) &SimpleWindow {
	id := win.register_control('', ControlSpec{
		typ: .dropdown
		options: options
		value: selected
	})
	win.values[id] = selected
	win.event_handlers['change_${id}'] = on_change
	return win
}

pub fn (mut win SimpleWindow) table(headers []string, rows [][]string, on_select EventCallback) &SimpleWindow {
	id := win.register_control('', ControlSpec{
		typ: .table
		headers: headers
		rows: rows
	})
	win.event_handlers['click_${id}'] = on_select
	return win
}

pub fn (mut win SimpleWindow) table_named(name string, headers []string, rows [][]string, on_select EventCallback) &SimpleWindow {
	id := win.register_control(name, ControlSpec{
		typ: .table
		headers: headers
		rows: rows
	})
	win.event_handlers['click_${id}'] = on_select
	return win
}

pub fn (mut win SimpleWindow) progress(value int, max_val int) &SimpleWindow {
	win.register_control('', ControlSpec{
		typ: .progress
		value: value.str()
		max_val: max_val
	})
	return win
}

pub fn (mut win SimpleWindow) kpi_card(title string, value string, change string) &SimpleWindow {
	win.register_control('', ControlSpec{
		typ: .kpi_card
		text: title
		value: value
		secondary_text: change
	})
	return win
}

pub fn (mut win SimpleWindow) divider() &SimpleWindow {
	win.register_control('', ControlSpec{
		typ: .divider
	})
	return win
}

pub fn (mut win SimpleWindow) status_bar(text string) &SimpleWindow {
	win.register_control('', ControlSpec{
		typ: .status_bar
		text: text
	})
	return win
}

pub fn (mut win SimpleWindow) raw_html(html_str string) &SimpleWindow {
	win.register_control('', ControlSpec{
		typ: .raw_html
		text: html_str
	})
	return win
}

pub fn (mut win SimpleWindow) row_start() &SimpleWindow {
	return win.raw_html('<div class="sg-row">')
}

pub fn (mut win SimpleWindow) row_end() &SimpleWindow {
	return win.raw_html('</div>')
}

pub fn (mut win SimpleWindow) box_start(title string) &SimpleWindow {
	return win.raw_html('<div class="sg-kpi-card" style="margin-bottom:8px;"><div class="sg-kpi-title" style="margin-bottom:8px;font-weight:700;">${title}</div>')
}

pub fn (mut win SimpleWindow) box_end() &SimpleWindow {
	return win.raw_html('</div>')
}

// ---------------------------------------------------------
// Value Accessors & State Synchronization
// ---------------------------------------------------------

pub fn (win &SimpleWindow) get_value(id string) string {
	unsafe {
		mut mut_win := &SimpleWindow(voidptr(win))
		mut_win.state_lock.lock()
		defer {
			mut_win.state_lock.unlock()
		}
		if val := mut_win.values[id] {
			return val
		}
		if idx := mut_win.name_to_ctrl[id] {
			actual_id := mut_win.controls[idx].id
			if val := mut_win.values[actual_id] {
				return val
			}
			return mut_win.controls[idx].value
		}
	}
	return ''
}

pub fn (win &SimpleWindow) set_value(id string, val string) {
	mut actual_id := id
	unsafe {
		mut mut_win := &SimpleWindow(voidptr(win))
		mut_win.state_lock.lock()
		defer {
			mut_win.state_lock.unlock()
		}
		mut_win.values[id] = val
		if idx := mut_win.name_to_ctrl[id] {
			actual_id = mut_win.controls[idx].id
			mut_win.values[actual_id] = val
			mut_win.controls[idx].value = val
			for k, v in mut_win.name_to_ctrl {
				if v == idx {
					mut_win.values[k] = val
				}
			}
		}
	}
	if !isnil(win.wv) {
		esc := system.json_escape(val)
		win.wv.eval('if (document.getElementById("${actual_id}")) { const el = document.getElementById("${actual_id}"); if (el.type === "checkbox" || el.type === "radio") { el.checked = (${val} === "true" || ${val} === true || el.value === ${esc}); } else { el.value = ${esc}; } }')
	}
}

fn table_rows_json(rows [][]string) string {
	mut encoded_rows := []string{}
	for row in rows {
		mut encoded_cells := []string{}
		for cell in row {
			encoded_cells << system.json_escape(cell)
		}
		encoded_rows << '[' + encoded_cells.join(',') + ']'
	}
	return '[' + encoded_rows.join(',') + ']'
}

fn (win &SimpleWindow) render_table_rows(name string, click_id string, rows [][]string) {
	if isnil(win.wv) {
		return
	}
	table_id := system.json_escape(name)
	click_handler_id := system.json_escape(click_id)
	rows_data := table_rows_json(rows)
	win.wv.eval('(function() {
		const table = document.getElementById(${table_id});
		if (!table) return;
		const body = table.querySelector("tbody");
		if (!body) return;
		const rows = ${rows_data};
		body.replaceChildren();
		rows.forEach((row, rowIndex) => {
			const tr = document.createElement("tr");
			tr.dataset.sgRowIndex = String(rowIndex);
			tr.addEventListener("click", () => window.vlangTriggerClick(${click_handler_id}, String(rowIndex)));
			row.forEach((cell, cellIndex) => {
				const td = document.createElement("td");
				td.textContent = cell;
				if (cellIndex === 1) {
					td.style.fontFamily = "monospace";
					td.style.wordBreak = "break-all";
				}
				tr.appendChild(td);
			});
			body.appendChild(tr);
		});
	})();')
}

pub fn (win &SimpleWindow) set_table_headers(name string, headers []string) &SimpleWindow {
	unsafe {
		mut mut_win := &SimpleWindow(voidptr(win))
		mut_win.state_lock.lock()
		defer {
			mut_win.state_lock.unlock()
		}
		if idx := mut_win.name_to_ctrl[name] {
			if mut_win.controls[idx].typ != .table {
				return win
			}
			mut_win.controls[idx].headers = headers.clone()
		} else {
			return win
		}
	}
	if !isnil(win.wv) {
		table_id := system.json_escape(name)
		headers_data := table_rows_json([headers])
		win.wv.eval('(function() {
			const table = document.getElementById(${table_id});
			if (!table) return;
			const head = table.querySelector("thead");
			if (!head) return;
			const headers = ${headers_data}[0];
			const row = document.createElement("tr");
			headers.forEach((header) => {
				const th = document.createElement("th");
				th.textContent = header;
				row.appendChild(th);
			});
			head.replaceChildren(row);
		})();')
	}
	return win
}

pub fn (win &SimpleWindow) set_table_rows(name string, rows [][]string) &SimpleWindow {
	mut target_name := name
	mut click_id := ''
	unsafe {
		mut mut_win := &SimpleWindow(voidptr(win))
		mut_win.state_lock.lock()
		defer {
			mut_win.state_lock.unlock()
		}
		if target_name == '' {
			for ctrl in mut_win.controls {
				if ctrl.typ == .table {
					target_name = ctrl.id
					break
				}
			}
		}
		if idx := mut_win.name_to_ctrl[target_name] {
			if mut_win.controls[idx].typ != .table {
				return win
			}
			mut_win.controls[idx].rows = rows.clone()
			click_id = mut_win.controls[idx].click_id
		} else {
			return win
		}
	}
	win.render_table_rows(target_name, click_id, rows)
	return win
}

pub fn (win &SimpleWindow) add_table_row(name string, row []string) &SimpleWindow {
	mut rows := [][]string{}
	mut click_id := ''
	unsafe {
		mut mut_win := &SimpleWindow(voidptr(win))
		mut_win.state_lock.lock()
		defer {
			mut_win.state_lock.unlock()
		}
		if idx := mut_win.name_to_ctrl[name] {
			if mut_win.controls[idx].typ != .table {
				return win
			}
			mut_win.controls[idx].rows << row.clone()
			rows = mut_win.controls[idx].rows.clone()
			click_id = mut_win.controls[idx].click_id
		} else {
			return win
		}
	}
	win.render_table_rows(name, click_id, rows)
	return win
}

pub fn (win &SimpleWindow) remove_table_row(name string, row_index int) &SimpleWindow {
	mut rows := [][]string{}
	mut click_id := ''
	unsafe {
		mut mut_win := &SimpleWindow(voidptr(win))
		mut_win.state_lock.lock()
		defer {
			mut_win.state_lock.unlock()
		}
		if idx := mut_win.name_to_ctrl[name] {
			if mut_win.controls[idx].typ != .table {
				return win
			}
			if row_index < 0 || row_index >= mut_win.controls[idx].rows.len {
				return win
			}
			mut_win.controls[idx].rows.delete(row_index)
			rows = mut_win.controls[idx].rows.clone()
			click_id = mut_win.controls[idx].click_id
		} else {
			return win
		}
	}
	win.render_table_rows(name, click_id, rows)
	return win
}

pub fn (win &SimpleWindow) table_row_count(name string) int {
	unsafe {
		mut mut_win := &SimpleWindow(voidptr(win))
		mut_win.state_lock.lock()
		defer {
			mut_win.state_lock.unlock()
		}
		if idx := mut_win.name_to_ctrl[name] {
			if mut_win.controls[idx].typ == .table {
				return mut_win.controls[idx].rows.len
			}
		}
	}
	return 0
}

pub fn (win &SimpleWindow) select_table_row(name string, row_index int) &SimpleWindow {
	if !isnil(win.wv) {
		table_id := system.json_escape(name)
		win.wv.eval('const table = document.getElementById(${table_id}); if (table) { table.querySelectorAll("tbody tr").forEach((row, index) => row.classList.toggle("sg-table-selected", index === ${row_index})); }')
	}
	return win
}

pub fn (win &SimpleWindow) get_text(name string) string {
	return win.get_value(name)
}

pub fn (win &SimpleWindow) set_text(name string, val string) &SimpleWindow {
	win.set_value(name, val)
	return win
}

pub fn (win &SimpleWindow) get(name string) string {
	return win.get_text(name)
}

pub fn (win &SimpleWindow) set(name string, val string) &SimpleWindow {
	return win.set_text(name, val)
}

pub fn (win &SimpleWindow) get_int(name string) int {
	return win.get_value(name).int()
}

pub fn (win &SimpleWindow) get_value_int(name string) int {
	return win.get_value(name).int()
}

pub fn (win &SimpleWindow) set_int(name string, val int) &SimpleWindow {
	win.set_value(name, val.str())
	return win
}

pub fn (win &SimpleWindow) get_bool(name string) bool {
	return win.get_value(name) == 'true'
}

pub fn (win &SimpleWindow) get_checked(name string) bool {
	return win.get_bool(name)
}

pub fn (win &SimpleWindow) set_bool(name string, val bool) &SimpleWindow {
	win.set_value(name, val.str())
	return win
}

pub fn (win &SimpleWindow) set_checked(name string, val bool) &SimpleWindow {
	return win.set_bool(name, val)
}

pub fn (win &SimpleWindow) set_status(msg string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.status_text = msg
	}
	if !isnil(win.wv) {
		esc := system.json_escape(msg)
		win.wv.eval('const el = document.querySelector(".sg-statusbar"); if (el) { el.textContent = ${esc}; }')
	}
	return win
}

pub fn (win &SimpleWindow) set_progress(name string, val int) &SimpleWindow {
	win.set_value(name, val.str())
	if !isnil(win.wv) {
		win.wv.eval('const el = document.querySelector(".sg-progress-fill"); if (el) { el.style.width = "${val}%"; }')
	}
	return win
}

// ---------------------------------------------------------
// Theming Operations
// ---------------------------------------------------------

pub fn (win &SimpleWindow) set_theme(theme_name string) &SimpleWindow {
	theme := get_theme(theme_name)
	btn_txt := hex_to_contrast_color(theme.accent_color)
	unsafe {
		mut mut_win := &SimpleWindow(voidptr(win))
		mut_win.theme_name = theme_name
	}
	if !isnil(win.wv) {
		js := '
			(function() {
				const r = document.documentElement;
				r.style.setProperty("--bg-main", "${theme.background_color}");
				r.style.setProperty("--text-main", "${theme.font_color}");
				r.style.setProperty("--accent", "${theme.accent_color}");
				r.style.setProperty("--secondary", "${theme.secondary_accent}");
				r.style.setProperty("--bg-card", "${theme.card_background}");
				r.style.setProperty("--border-card", "${theme.card_border}");
				r.style.setProperty("--btn-text", "${btn_txt}");
				r.style.setProperty("--color-scheme", "${if theme.is_dark { 'dark' } else { 'light' }}");
				document.body.style.backgroundColor = "${theme.background_color}";
				document.body.style.color = "${theme.font_color}";
			})();
		'
		win.wv.eval(js)
	}
	return win
}

pub fn (win &SimpleWindow) apply_theme(t Theme) &SimpleWindow {
	return win.set_theme(t.name)
}

pub fn (win &SimpleWindow) apply_theme_by_name(name string) &SimpleWindow {
	return win.set_theme(name)
}

pub fn (win &SimpleWindow) set_background_color(hex_color string) &SimpleWindow {
	if !isnil(win.wv) {
		win.wv.eval('document.body.style.backgroundColor = "${hex_color}";')
	}
	return win
}

pub fn (win &SimpleWindow) set_font_color(color string) &SimpleWindow {
	if !isnil(win.wv) {
		win.wv.eval('document.body.style.color = "${color}";')
	}
	return win
}

pub fn (win &SimpleWindow) set_dark_theme(dark bool) &SimpleWindow {
	if dark {
		win.set_theme('tokyo_night')
	} else {
		win.set_theme('gruvbox_light')
	}
	return win
}

pub fn (win &SimpleWindow) toggle_window_theme() &SimpleWindow {
	return win.set_dark_theme(!win.is_dark_theme())
}

pub fn (win &SimpleWindow) is_dark_theme() bool {
	t := get_theme(win.theme_name)
	return t.is_dark
}

pub fn (win &SimpleWindow) save_theme(theme_name string) &SimpleWindow {
	save_theme(theme_name)
	return win
}

pub fn (win &SimpleWindow) restore_saved_theme() string {
	saved := get_saved_theme()
	win.set_theme(saved)
	return saved
}

pub fn (win &SimpleWindow) get_html() string {
	return win.generate_html()
}

// ---------------------------------------------------------
// Dialogs & System Integration
// ---------------------------------------------------------

pub fn (win &SimpleWindow) alert(title string, message string) {
	if !isnil(win.wv) {
		win.modal_alert(title, message)
	} else {
		system.show_alert(title, message)
	}
}

pub fn (win &SimpleWindow) confirm(title string, message string) bool {
	return system.show_confirm(title, message)
}

pub fn (win &SimpleWindow) notification(title string, message string) {
	system.show_notification(title, message)
}

pub fn (win &SimpleWindow) open_file_dialog(prompt string, file_types string) string {
	return system.open_file_dialog(prompt, file_types)
}

pub fn (win &SimpleWindow) save_file_dialog(prompt string, default_name string) string {
	return system.save_file_dialog(prompt, default_name)
}

pub fn (win &SimpleWindow) select_folder_dialog(prompt string) string {
	return system.select_folder_dialog(prompt)
}

pub fn (win &SimpleWindow) exec(cmd string) (string, int) {
	return system.exec(cmd)
}

pub fn (win &SimpleWindow) exec_or(cmd string, fallback string) string {
	return system.exec_or(cmd, fallback)
}

pub fn (win &SimpleWindow) exec_bg(cmd string) {
	system.exec_bg(cmd)
}

// ---------------------------------------------------------
// Window Operations, Sizing & Desktop Alignment
// ---------------------------------------------------------

pub fn (win &SimpleWindow) get_title() string {
	return win.title
}

pub fn (win &SimpleWindow) set_title(title string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.title = title
	}
	if !isnil(win.wv) {
		win.wv.set_title(title)
	}
	return win
}

pub fn (win &SimpleWindow) set_window_title(title string) &SimpleWindow {
	return win.set_title(title)
}

pub fn (win &SimpleWindow) get_width() int {
	return win.width
}

pub fn (win &SimpleWindow) get_height() int {
	return win.height
}

pub fn (win &SimpleWindow) get_size() (int, int) {
	return win.width, win.height
}

pub fn (win &SimpleWindow) set_size(w int, h int) &SimpleWindow {
	unsafe {
		mut win_mut := &SimpleWindow(win)
		win_mut.width = w
		win_mut.height = h
	}
	if !isnil(win.wv) {
		win.wv.set_size(w, h, .@none)
	}
	return win
}

pub fn (win &SimpleWindow) resize(w int, h int) &SimpleWindow {
	return win.set_size(w, h)
}

pub fn (win &SimpleWindow) set_fixed_size(w int, h int) &SimpleWindow {
	win.set_size(w, h)
	win.set_min_size(w, h)
	win.set_max_size(w, h)
	win.set_resizable(false)
	return win
}

pub fn (win &SimpleWindow) set_size_preset(preset string) &SimpleWindow {
	match preset.to_lower() {
		'small', 'compact' {
			return win.set_size(400, 300)
		}
		'medium', 'standard' {
			return win.set_size(640, 480)
		}
		'large' {
			return win.set_size(800, 600)
		}
		'xlarge', 'xl' {
			return win.set_size(1024, 768)
		}
		'hd', '720p' {
			return win.set_size(1280, 720)
		}
		'full_hd', '1080p' {
			return win.set_size(1920, 1080)
		}
		'dialog', 'alert' {
			return win.set_size(420, 220)
		}
		'login', 'auth' {
			return win.set_size(380, 450)
		}
		'settings', 'preferences' {
			return win.set_size(550, 400)
		}
		'sidebar', 'panel' {
			return win.set_size(300, 600)
		}
		'splash', 'square' {
			return win.set_size(500, 500)
		}
		else {
			return win.set_size(800, 600)
		}
	}
}

pub fn (win &SimpleWindow) get_padding() int {
	return win.padding
}

pub fn (win &SimpleWindow) set_padding(p int) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.padding = p
	}
	return win
}

pub fn (win &SimpleWindow) get_spacing() int {
	return win.spacing
}

pub fn (win &SimpleWindow) set_spacing(s int) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.spacing = s
	}
	return win
}

pub fn (win &SimpleWindow) set_always_on_top(on_top bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.always_on_top = on_top
	}
	if !isnil(win.wv) {
		win.wv.set_always_on_top(on_top)
	}
	return win
}

pub fn (win &SimpleWindow) get_always_on_top() bool {
	return win.always_on_top
}

pub fn (win &SimpleWindow) set_topmost(enabled bool) &SimpleWindow {
	return win.set_always_on_top(enabled)
}

pub fn (win &SimpleWindow) is_topmost() bool {
	return win.always_on_top
}

pub fn (win &SimpleWindow) set_min_size(w int, h int) &SimpleWindow {
	unsafe {
		mut win_mut := &SimpleWindow(win)
		win_mut.min_width = w
		win_mut.min_height = h
	}
	if !isnil(win.wv) {
		win.wv.set_size(w, h, .min)
	}
	return win
}

pub fn (win &SimpleWindow) set_max_size(w int, h int) &SimpleWindow {
	unsafe {
		mut win_mut := &SimpleWindow(win)
		win_mut.max_width = w
		win_mut.max_height = h
	}
	if !isnil(win.wv) {
		win.wv.set_size(w, h, .max)
	}
	return win
}

pub fn (win &SimpleWindow) get_min_size() (int, int) {
	return win.min_width, win.min_height
}

pub fn (win &SimpleWindow) get_max_size() (int, int) {
	return win.max_width, win.max_height
}

pub fn (win &SimpleWindow) set_minimum_size(w int, h int) &SimpleWindow {
	return win.set_min_size(w, h)
}

pub fn (win &SimpleWindow) set_maximum_size(w int, h int) &SimpleWindow {
	return win.set_max_size(w, h)
}

pub fn (win &SimpleWindow) get_minimum_size() (int, int) {
	return win.get_min_size()
}

pub fn (win &SimpleWindow) get_maximum_size() (int, int) {
	return win.get_max_size()
}

pub fn (win &SimpleWindow) set_resizable(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.is_resizable = enabled
	}
	if !enabled {
		win.set_min_size(win.width, win.height)
		win.set_max_size(win.width, win.height)
	}
	return win
}

pub fn (win &SimpleWindow) get_resizable() bool {
	return win.is_resizable
}

pub fn (win &SimpleWindow) set_minimizable(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.is_minimizable = enabled
	}
	return win
}

pub fn (win &SimpleWindow) get_minimizable() bool {
	return win.is_minimizable
}

pub fn (win &SimpleWindow) set_maximizable(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.is_maximizable = enabled
	}
	return win
}

pub fn (win &SimpleWindow) get_maximizable() bool {
	return win.is_maximizable
}

pub fn (win &SimpleWindow) set_opacity(alpha f64) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.opacity = alpha
	}
	if !isnil(win.wv) {
		win.wv.eval('document.body.style.opacity = "${alpha}";')
	}
	return win
}

pub fn (win &SimpleWindow) get_opacity() f64 {
	return win.opacity
}

pub fn (win &SimpleWindow) set_alpha(alpha f64) &SimpleWindow {
	return win.set_opacity(alpha)
}

pub fn (win &SimpleWindow) get_alpha() f64 {
	return win.get_opacity()
}

pub fn (win &SimpleWindow) set_cursor(name string) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.cursor_name = name
	}
	if !isnil(win.wv) {
		css_cursor := match name {
			'pointing_hand' { 'pointer' }
			'ibeam' { 'text' }
			'crosshair' { 'crosshair' }
			'open_hand' { 'grab' }
			'closed_hand' { 'grabbing' }
			else { 'default' }
		}
		win.wv.eval('document.body.style.cursor = "${css_cursor}";')
	}
	return win
}

pub fn (win &SimpleWindow) get_cursor() string {
	return win.cursor_name
}

pub fn (win &SimpleWindow) reset_cursor() &SimpleWindow {
	return win.set_cursor('arrow')
}

pub fn (win &SimpleWindow) set_debug_mode(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.is_debug_mode = enabled
	}
	return win
}

pub fn (win &SimpleWindow) get_debug_mode() bool {
	return win.is_debug_mode
}

pub fn (win &SimpleWindow) is_minimized() bool {
	return false
}

pub fn (win &SimpleWindow) is_maximized() bool {
	return win.fullscreen
}

pub fn (win &SimpleWindow) is_fullscreen() bool {
	return win.fullscreen
}

pub fn (win &SimpleWindow) is_visible() bool {
	return true
}

pub fn (win &SimpleWindow) is_active() bool {
	return true
}

pub fn (win &SimpleWindow) toggle_fullscreen() &SimpleWindow {
	if !isnil(win.wv) {
		win.wv.toggle_fullscreen()
	}
	return win
}

pub fn (win &SimpleWindow) set_fullscreen(fullscreen bool) &SimpleWindow {
	if !isnil(win.wv) {
		win.wv.set_fullscreen(fullscreen)
	}
	return win
}

pub fn (win &SimpleWindow) quit() {
	C.rad_window_quit()
	if !isnil(win.wv) {
		win.wv.terminate()
	}
	exit(0)
}

pub fn (win &SimpleWindow) close() &SimpleWindow {
	win.quit()
	return win
}

pub fn (win &SimpleWindow) close_window() &SimpleWindow {
	return win.close()
}

pub fn (win &SimpleWindow) minimize() &SimpleWindow {
	if !isnil(win.wv) {
		win.wv.minimize()
	}
	return win
}

pub fn (win &SimpleWindow) hide() &SimpleWindow {
	if !isnil(win.wv) {
		win.wv.hide()
	}
	return win
}

pub fn (win &SimpleWindow) hide_window() &SimpleWindow {
	return win.hide()
}

pub fn (win &SimpleWindow) show() &SimpleWindow {
	return win
}

pub fn (win &SimpleWindow) show_window() &SimpleWindow {
	return win.show()
}

pub fn (win &SimpleWindow) restore() &SimpleWindow {
	return win
}

pub fn (win &SimpleWindow) restore_window() &SimpleWindow {
	return win.restore()
}

pub fn (win &SimpleWindow) maximize() &SimpleWindow {
	return win.toggle_fullscreen()
}

pub fn (win &SimpleWindow) zoom() &SimpleWindow {
	return win.maximize()
}

pub fn (win &SimpleWindow) center() &SimpleWindow {
	if !isnil(win.wv) {
		win.wv.center()
	}
	return win
}

pub fn (win &SimpleWindow) center_window() &SimpleWindow {
	return win.center()
}

pub fn (win &SimpleWindow) recenter() &SimpleWindow {
	return win.center()
}

pub fn (win &SimpleWindow) center_on_screen() &SimpleWindow {
	return win.center()
}

pub fn (win &SimpleWindow) center_on_active_screen() &SimpleWindow {
	return win.center()
}

pub fn (win &SimpleWindow) set_position(preset string) &SimpleWindow {
	if !isnil(win.wv) {
		win.wv.set_position(preset)
	}
	return win
}

pub fn (win &SimpleWindow) set_position_xy(x int, y int) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.x_pos = x
		w.y_pos = y
	}
	return win
}

pub fn (win &SimpleWindow) get_position() (int, int) {
	return win.x_pos, win.y_pos
}

pub fn (win &SimpleWindow) get_x() int {
	return win.x_pos
}

pub fn (win &SimpleWindow) get_y() int {
	return win.y_pos
}

pub fn (win &SimpleWindow) set_position_preset(preset string) &SimpleWindow {
	return win.set_position(preset)
}

pub fn (win &SimpleWindow) set_corner_position(corner string) &SimpleWindow {
	return win.set_position(corner)
}

pub fn (win &SimpleWindow) align(pos string) &SimpleWindow {
	return win.set_position(pos)
}

pub fn (win &SimpleWindow) align_window(pos string) &SimpleWindow {
	return win.align(pos)
}

pub fn (win &SimpleWindow) set_responsive_layout(enabled bool) &SimpleWindow {
	unsafe {
		mut w := &SimpleWindow(win)
		w.responsive_layout = enabled
	}
	return win
}

pub fn (win &SimpleWindow) get_responsive_layout() bool {
	return win.responsive_layout
}

pub fn (win &SimpleWindow) shake_window() &SimpleWindow {
	if !isnil(win.wv) {
		win.wv.eval('
			document.body.style.transition = "transform 0.05s ease";
			let count = 0;
			const interval = setInterval(() => {
				document.body.style.transform = (count % 2 === 0) ? "translateX(-10px)" : "translateX(10px)";
				count++;
				if (count > 6) {
					clearInterval(interval);
					document.body.style.transform = "none";
				}
			}, 50);
		')
	}
	return win
}

pub fn (win &SimpleWindow) trigger_shake() &SimpleWindow {
	return win.shake_window()
}

pub fn (win &SimpleWindow) flash_and_shake() &SimpleWindow {
	return win.shake_window()
}

pub fn (win &SimpleWindow) attention() &SimpleWindow {
	return win
}

pub fn (win &SimpleWindow) bounce_dock(critical bool) &SimpleWindow {
	return win
}

pub fn (win &SimpleWindow) request_attention(critical bool) &SimpleWindow {
	return win
}

pub fn (win &SimpleWindow) make_fixed_dialog(title string, w int, h int) &SimpleWindow {
	win.set_title(title)
	win.set_fixed_size(w, h)
	win.center()
	return win
}

pub fn (win &SimpleWindow) make_splash_screen(w int, h int) &SimpleWindow {
	win.set_fixed_size(w, h)
	win.center()
	win.set_always_on_top(true)
	return win
}

pub fn (win &SimpleWindow) make_utility_panel() &SimpleWindow {
	win.set_always_on_top(true)
	return win
}

pub fn (win &SimpleWindow) make_frameless() &SimpleWindow {
	return win
}

pub fn (win &SimpleWindow) make_translucent(alpha f64) &SimpleWindow {
	return win.set_opacity(alpha)
}

pub fn (win &SimpleWindow) make_always_on_top(enabled bool) &SimpleWindow {
	return win.set_always_on_top(enabled)
}

pub fn (win &SimpleWindow) make_modal() &SimpleWindow {
	return win.set_always_on_top(true)
}

pub fn (win &SimpleWindow) center_and_focus() &SimpleWindow {
	return win.center()
}

pub fn (win &SimpleWindow) eval(js string) &SimpleWindow {
	if !isnil(win.wv) {
		win.wv.eval(js)
	}
	return win
}

pub fn (win &SimpleWindow) toast(msg string) &SimpleWindow {
	if !isnil(win.wv) {
		esc := system.json_escape(msg)
		win.wv.eval('
			(function() {
				const t = document.createElement("div");
				t.textContent = ${esc};
				t.style.position = "fixed";
				t.style.top = "20px";
				t.style.left = "50%";
				t.style.transform = "translateX(-50%) translateY(-10px)";
				t.style.backgroundColor = "rgba(15, 23, 42, 0.94)";
				t.style.color = "#f8fafc";
				t.style.padding = "10px 22px";
				t.style.borderRadius = "8px";
				t.style.border = "1px solid rgba(255,255,255,0.2)";
				t.style.zIndex = "9999999";
				t.style.fontSize = "13px";
				t.style.fontWeight = "600";
				t.style.boxShadow = "0 10px 30px rgba(0,0,0,0.5)";
				t.style.opacity = "0";
				t.style.transition = "all 0.25s cubic-bezier(0.16, 1, 0.3, 1)";
				t.style.pointerEvents = "none";
				document.body.appendChild(t);
				requestAnimationFrame(() => {
					t.style.opacity = "1";
					t.style.transform = "translateX(-50%) translateY(0)";
				});
				setTimeout(() => {
					t.style.opacity = "0";
					t.style.transform = "translateX(-50%) translateY(-10px)";
					setTimeout(() => { t.remove(); }, 300);
				}, 2600);
			})();
		')
	}
	return win
}

pub fn (win &SimpleWindow) toast_success(msg string) &SimpleWindow {
	return win.toast('✅ ' + msg)
}

pub fn (win &SimpleWindow) toast_info(msg string) &SimpleWindow {
	return win.toast('ℹ️ ' + msg)
}

pub fn (win &SimpleWindow) toast_warning(msg string) &SimpleWindow {
	return win.toast('⚠️ ' + msg)
}

pub fn (win &SimpleWindow) toast_error(msg string) &SimpleWindow {
	return win.toast('❌ ' + msg)
}

pub fn (win &SimpleWindow) modal_alert(title string, message string) &SimpleWindow {
	if !isnil(win.wv) {
		esc_title := system.json_escape(title)
		esc_msg := system.json_escape(message)
		win.wv.eval('
			(function() {
				const old = document.getElementById("sgModalAlert");
				if (old) old.remove();
				const overlay = document.createElement("div");
				overlay.id = "sgModalAlert";
				overlay.style.position = "fixed";
				overlay.style.inset = "0";
				overlay.style.backgroundColor = "rgba(0,0,0,0.65)";
				overlay.style.display = "flex";
				overlay.style.alignItems = "center";
				overlay.style.justifyContent = "center";
				overlay.style.zIndex = "99999999";
				overlay.style.backdropFilter = "blur(4px)";
				
				const box = document.createElement("div");
				box.style.background = "var(--bg-card, #1e293b)";
				box.style.border = "1px solid var(--accent, #38bdf8)";
				box.style.borderRadius = "12px";
				box.style.padding = "24px 28px";
				box.style.maxWidth = "560px";
				box.style.width = "90%";
				box.style.boxSizing = "border-box";
				box.style.boxShadow = "0 16px 48px rgba(0,0,0,0.7)";
				box.style.color = "var(--text-main, #f8fafc)";
				box.style.fontFamily = "system-ui,-apple-system,sans-serif";
				box.style.wordBreak = "break-all";
				box.style.overflowWrap = "anywhere";
				
				const h = document.createElement("h3");
				h.style.marginTop = "0";
				h.style.marginBottom = "12px";
				h.style.fontSize = "17px";
				h.style.color = "var(--accent, #38bdf8)";
				h.textContent = ${esc_title};
				box.appendChild(h);
				
				const p = document.createElement("div");
				p.style.fontSize = "13px";
				p.style.lineHeight = "1.6";
				p.style.opacity = "0.95";
				p.style.marginBottom = "20px";
				p.style.whiteSpace = "pre-wrap";
				p.style.wordBreak = "break-all";
				p.style.overflowWrap = "anywhere";
				p.style.wordWrap = "break-word";
				p.style.maxHeight = "50vh";
				p.style.overflowY = "auto";
				p.style.background = "rgba(0, 0, 0, 0.25)";
				p.style.padding = "14px";
				p.style.borderRadius = "8px";
				p.style.border = "1px solid rgba(255, 255, 255, 0.1)";
				p.style.fontFamily = "ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace";
				p.style.boxSizing = "border-box";
				p.textContent = ${esc_msg};
				box.appendChild(p);
				
				const btnRow = document.createElement("div");
				btnRow.style.display = "flex";
				btnRow.style.justifyContent = "flex-end";
				
				const okBtn = document.createElement("button");
				okBtn.textContent = "OK";
				okBtn.style.padding = "8px 22px";
				okBtn.style.background = "var(--accent, #38bdf8)";
				okBtn.style.color = "var(--btn-text, #000)";
				okBtn.style.fontWeight = "700";
				okBtn.style.border = "none";
				okBtn.style.borderRadius = "6px";
				okBtn.style.cursor = "pointer";
				okBtn.style.fontSize = "13px";
				okBtn.onclick = function() { overlay.remove(); };
				btnRow.appendChild(okBtn);
				box.appendChild(btnRow);
				
				overlay.appendChild(box);
				document.body.appendChild(overlay);
				okBtn.focus();
			})();
		')
	}
	return win
}

pub fn (win &SimpleWindow) clear_form() &SimpleWindow {
	unsafe {
		mut mut_win := &SimpleWindow(voidptr(win))
		for k in mut_win.values.keys() {
			mut_win.values[k] = ''
		}
	}
	if !isnil(win.wv) {
		win.wv.eval('
			(function() {
				document.querySelectorAll("input:not([type=button]):not([type=submit]), textarea").forEach(el => {
					if (el.type === "checkbox" || el.type === "radio") {
						el.checked = false;
						el.dispatchEvent(new Event("change", { bubbles: true }));
					} else if (el.type === "range") {
						el.value = el.min || "0";
						el.dispatchEvent(new Event("input", { bubbles: true }));
					} else {
						el.value = "";
						el.dispatchEvent(new Event("input", { bubbles: true }));
					}
				});
				document.querySelectorAll("select").forEach(el => {
					el.selectedIndex = 0;
					el.dispatchEvent(new Event("change", { bubbles: true }));
				});
			})();
		')
	}
	return win
}

pub fn (win &SimpleWindow) simulate_form_submit(success_title string) &SimpleWindow {
	if !isnil(win.wv) {
		esc_title := system.json_escape(success_title)
		win.wv.eval('
			(function() {
				const fieldSummaries = [];
				let hasNonEmpty = false;

				const textInputs = document.querySelectorAll("input[type=text], input[type=search], input[type=password], input:not([type])");
				textInputs.forEach(input => {
					const label = input.placeholder || input.name || input.id || "Field";
					const val = input.value.trim();
					if (input.type === "password") {
						if (val.length > 0) {
							hasNonEmpty = true;
							fieldSummaries.push("• " + label + ": •••••••• (" + val.length + " chars)");
						} else {
							fieldSummaries.push("• " + label + ": (blank)");
						}
					} else {
						if (val.length > 0) {
							hasNonEmpty = true;
							fieldSummaries.push("• " + label + ": " + val);
						} else {
							fieldSummaries.push("• " + label + ": (blank)");
						}
					}
				});

				const selects = document.querySelectorAll("select");
				selects.forEach(sel => {
					const val = sel.value;
					if (val) {
						fieldSummaries.push("• Account Tier / Option: " + val);
					}
				});

				const textareas = document.querySelectorAll("textarea");
				textareas.forEach(ta => {
					const label = ta.placeholder || "Developer Bio";
					const val = ta.value.trim();
					if (val.length > 0) {
						hasNonEmpty = true;
						fieldSummaries.push("• " + label + ": " + (val.length > 40 ? val.substring(0, 37) + "..." : val));
					} else {
						fieldSummaries.push("• " + label + ": (blank)");
					}
				});

				const checkboxes = document.querySelectorAll("input[type=checkbox]");
				checkboxes.forEach(cb => {
					let label = "Preference";
					const parentLabel = cb.closest("label");
					if (parentLabel) {
						const span = parentLabel.querySelector("span:not(.sg-toggle-slider)");
						if (span) label = span.textContent.trim();
					}
					if (cb.checked) {
						hasNonEmpty = true;
						fieldSummaries.push("• " + label + ": Yes (Enabled)");
					} else {
						fieldSummaries.push("• " + label + ": No (Disabled / Unchecked)");
					}
				});

				const sliders = document.querySelectorAll("input[type=range]");
				sliders.forEach(sl => {
					fieldSummaries.push("• Experience Level: " + sl.value + " Years");
				});

				const modalTitle = hasNonEmpty ? ${esc_title} : "⚠️ Form Submitted (Blank / Cleared State)";
				const summaryBody = hasNonEmpty
					? "Simulated Record processed from current GUI inputs:\\n\\n" + fieldSummaries.join("\\n") + "\\n\\nStatus: ✅ Active record stored in memory."
					: "The form was submitted with text fields blank/cleared:\\n\\n" + fieldSummaries.join("\\n") + "\\n\\nStatus: ⚠️ Blank form state processed.";

				// Display in-window modal
				const old = document.getElementById("sgModalAlert");
				if (old) old.remove();
				const overlay = document.createElement("div");
				overlay.id = "sgModalAlert";
				overlay.style.position = "fixed";
				overlay.style.inset = "0";
				overlay.style.backgroundColor = "rgba(0,0,0,0.65)";
				overlay.style.display = "flex";
				overlay.style.alignItems = "center";
				overlay.style.justifyContent = "center";
				overlay.style.zIndex = "99999999";
				overlay.style.backdropFilter = "blur(4px)";

				const box = document.createElement("div");
				box.style.background = "var(--bg-card, #1e293b)";
				box.style.border = hasNonEmpty ? "1px solid var(--accent, #38bdf8)" : "1px solid #f59e0b";
				box.style.borderRadius = "12px";
				box.style.padding = "24px 28px";
				box.style.maxWidth = "480px";
				box.style.width = "90%";
				box.style.boxShadow = "0 16px 48px rgba(0,0,0,0.7)";
				box.style.color = "var(--text-main, #f8fafc)";
				box.style.fontFamily = "system-ui,-apple-system,sans-serif";

				const h = document.createElement("h3");
				h.style.marginTop = "0";
				h.style.marginBottom = "12px";
				h.style.fontSize = "17px";
				h.style.color = hasNonEmpty ? "var(--accent, #38bdf8)" : "#f59e0b";
				h.textContent = modalTitle;
				box.appendChild(h);

				const p = document.createElement("div");
				p.style.fontSize = "13px";
				p.style.lineHeight = "1.6";
				p.style.opacity = "0.92";
				p.style.marginBottom = "20px";
				p.style.whiteSpace = "pre-wrap";
				p.textContent = summaryBody;
				box.appendChild(p);

				const btnRow = document.createElement("div");
				btnRow.style.display = "flex";
				btnRow.style.justifyContent = "flex-end";

				const okBtn = document.createElement("button");
				okBtn.textContent = "OK";
				okBtn.style.padding = "8px 22px";
				okBtn.style.background = hasNonEmpty ? "var(--accent, #38bdf8)" : "#f59e0b";
				okBtn.style.color = "#000";
				okBtn.style.fontWeight = "700";
				okBtn.style.border = "none";
				okBtn.style.borderRadius = "6px";
				okBtn.style.cursor = "pointer";
				okBtn.style.fontSize = "13px";
				okBtn.onclick = function() { overlay.remove(); };
				btnRow.appendChild(okBtn);
				box.appendChild(btnRow);

				overlay.appendChild(box);
				document.body.appendChild(overlay);
				okBtn.focus();

				// Status & Toast
				const sb = document.querySelector(".sg-statusbar");
				if (sb) {
					sb.textContent = hasNonEmpty ? "✅ Form submitted from current GUI inputs" : "⚠️ Form submitted in blank state";
				}
			})();
		')
	}
	return win
}

pub fn (mut win SimpleWindow) set_menubar(categories []MenuCategory, on_select EventCallback) &SimpleWindow {
	win.menubar = categories
	win.menubar_handler_id = 'menubar_action'
	win.event_handlers[win.menubar_handler_id] = on_select
	return win
}

pub fn (mut win SimpleWindow) set_context_menu(items []MenuItem, on_select EventCallback) &SimpleWindow {
	win.context_menu_items = items
	win.context_menu_handler_id = 'context_menu_action'
	win.event_handlers[win.context_menu_handler_id] = on_select
	return win
}

// HTML & CSS Renderer

pub fn (win &SimpleWindow) generate_html() string {
	theme := get_theme(win.theme_name)

	mut body_html := ''
	for ctrl in win.controls {
		mut style_str := ''
		if ctrl.width > 0 {
			style_str += 'width:${ctrl.width}px; max-width:${ctrl.width}px; '
		}
		if ctrl.height > 0 {
			style_str += 'height:${ctrl.height}px; '
		}
		if ctrl.font_size > 0 {
			style_str += 'font-size:${ctrl.font_size}px; '
		}
		if ctrl.is_bold {
			style_str += 'font-weight:700; '
		}
		if ctrl.font_color != '' {
			style_str += 'color:${ctrl.font_color}; '
		}
		if ctrl.background_color != '' {
			style_str += 'background-color:${ctrl.background_color}; '
		}
		if !ctrl.visible {
			style_str += 'display:none; '
		}
		if ctrl.expand_fill {
			style_str += 'flex:1 1 auto; width:100%; '
		}

		tip_attr := if ctrl.tooltip != '' { 'title="${ctrl.tooltip}"' } else { '' }
		dis_attr := if !ctrl.enabled { 'disabled' } else { '' }

		match ctrl.typ {
			.heading {
				body_html += '<h1 id="${ctrl.id}" class="sg-heading" style="${style_str}" ${tip_attr}>${ctrl.text}</h1>'
			}
			.subheading {
				body_html += '<h2 id="${ctrl.id}" class="sg-subheading" style="${style_str}" ${tip_attr}>${ctrl.text}</h2>'
			}
			.label {
				body_html += '<p id="${ctrl.id}" class="sg-label" style="${style_str}" ${tip_attr}>${ctrl.text}</p>'
			}
			.button {
				body_html += '<button id="${ctrl.id}" class="sg-btn ${ctrl.css_class}" style="${style_str}" ${tip_attr} ${dis_attr} onclick="window.vlangTriggerClick(\'${ctrl.click_id}\', \'${ctrl.id}\')">${ctrl.text}</button>'
			}
			.input {
				body_html += '<input id="${ctrl.id}" type="text" class="sg-input" placeholder="${ctrl.placeholder}" value="${ctrl.value}" style="${style_str}" ${tip_attr} ${dis_attr} oninput="window.vlangTriggerChange(\'${ctrl.change_id}\', \'${ctrl.id}\', this.value)" onkeydown="if(event.key===\'Enter\'){window.vlangTriggerClick(\'enter_${ctrl.id}\', this.value)}" />'
			}
			.password {
				body_html += '<input id="${ctrl.id}" type="password" class="sg-input" placeholder="${ctrl.placeholder}" value="${ctrl.value}" style="${style_str}" ${tip_attr} ${dis_attr} oninput="window.vlangTriggerChange(\'${ctrl.change_id}\', \'${ctrl.id}\', this.value)" onkeydown="if(event.key===\'Enter\'){window.vlangTriggerClick(\'enter_${ctrl.id}\', this.value)}" />'
			}
			.textarea {
				body_html += '<textarea id="${ctrl.id}" class="sg-textarea" placeholder="${ctrl.placeholder}" style="${style_str}" ${tip_attr} ${dis_attr} oninput="window.vlangTriggerChange(\'${ctrl.change_id}\', \'${ctrl.id}\', this.value)">${ctrl.value}</textarea>'
			}
			.search_field {
				body_html += '<input id="${ctrl.id}" type="search" class="sg-input" placeholder="${ctrl.placeholder}" value="${ctrl.value}" style="${style_str}" ${tip_attr} ${dis_attr} oninput="window.vlangTriggerChange(\'${ctrl.change_id}\', \'${ctrl.id}\', this.value)" onkeydown="if(event.key===\'Enter\'){window.vlangTriggerClick(\'enter_${ctrl.id}\', this.value)}" />'
			}
			.checkbox {
				chk := if ctrl.checked { 'checked' } else { '' }
				body_html += '<label class="sg-checkbox-label" style="${style_str}" ${tip_attr}><input id="${ctrl.id}" type="checkbox" ${chk} ${dis_attr} onchange="window.vlangTriggerChange(\'${ctrl.change_id}\', \'${ctrl.id}\', this.checked ? \'true\' : \'false\')" /> <span>${ctrl.text}</span></label>'
			}
			.radio {
				chk := if ctrl.checked { 'checked' } else { '' }
				body_html += '<label class="sg-radio-label" style="${style_str}" ${tip_attr}><input id="${ctrl.id}" type="radio" name="${ctrl.secondary_text}" value="${ctrl.value}" class="sg-radio-input" ${chk} ${dis_attr} onchange="window.vlangTriggerChange(\'${ctrl.change_id}\', \'${ctrl.id}\', this.value)" /> <span>${ctrl.text}</span></label>'
			}
			.toggle {
				chk := if ctrl.checked { 'checked' } else { '' }
				body_html += '<label class="sg-toggle-label" style="${style_str}" ${tip_attr}><input id="${ctrl.id}" type="checkbox" class="sg-toggle-input" ${chk} ${dis_attr} onchange="window.vlangTriggerChange(\'${ctrl.change_id}\', \'${ctrl.id}\', this.checked ? \'true\' : \'false\')" /><span class="sg-toggle-slider"></span> <span>${ctrl.text}</span></label>'
			}
			.slider {
				body_html += '<div class="sg-slider-wrap" style="${style_str}" ${tip_attr}><input id="${ctrl.id}" type="range" class="sg-slider" min="${ctrl.min_val}" max="${ctrl.max_val}" value="${ctrl.value}" ${dis_attr} oninput="window.vlangTriggerChange(\'${ctrl.change_id}\', \'${ctrl.id}\', this.value)" /></div>'
			}
			.dropdown {
				mut opts := ''
				for o in ctrl.options {
					sel := if o == ctrl.value { 'selected' } else { '' }
					opts += '<option value="${o}" ${sel}>${o}</option>'
				}
				body_html += '<select id="${ctrl.id}" class="sg-select" style="${style_str}" ${tip_attr} ${dis_attr} onchange="window.vlangTriggerChange(\'${ctrl.change_id}\', \'${ctrl.id}\', this.value)">${opts}</select>'
			}
			.date_picker {
				body_html += '<input id="${ctrl.id}" type="date" class="sg-input" value="${ctrl.value}" style="${style_str}" ${tip_attr} ${dis_attr} onchange="window.vlangTriggerChange(\'${ctrl.change_id}\', \'${ctrl.id}\', this.value)" />'
			}
			.color_picker {
				body_html += '<div class="sg-row" style="gap:8px; align-items:center; ${style_str}" ${tip_attr}><input id="${ctrl.id}" type="color" class="sg-color-picker" value="${ctrl.value}" ${dis_attr} onchange="window.vlangTriggerChange(\'${ctrl.change_id}\', \'${ctrl.id}\', this.value)" /><span class="sg-label">${ctrl.text}</span></div>'
			}
			.code_view {
				body_html += '<pre id="${ctrl.id}" class="sg-code-view" style="${style_str}" ${tip_attr}><code>${ctrl.text}</code></pre>'
			}
			.markdown {
				body_html += '<div id="${ctrl.id}" class="sg-markdown" style="${style_str}" ${tip_attr}>${ctrl.text}</div>'
			}
			.badge {
				body_html += '<span id="${ctrl.id}" class="sg-badge" style="${style_str}" ${tip_attr}>${ctrl.text}</span>'
			}
			.section_header {
				body_html += '<div id="${ctrl.id}" class="sg-section-header" style="${style_str}" ${tip_attr}><div class="sg-section-title">${ctrl.text}</div><div class="sg-section-sub">${ctrl.secondary_text}</div><hr class="sg-divider" /></div>'
			}
			.hotkey_badge {
				body_html += '<div id="${ctrl.id}" class="sg-hotkey-badge-row" style="${style_str}" ${tip_attr}><span class="sg-kbd">${ctrl.text}</span> <span class="sg-label">${ctrl.secondary_text}</span></div>'
			}
			.image {
				body_html += '<img id="${ctrl.id}" src="${ctrl.value}" style="max-width:100%; border-radius:6px; ${style_str}" ${tip_attr} alt="${ctrl.text}" />'
			}
			.table {
				mut thead := '<tr>'
				for h in ctrl.headers {
					thead += '<th>${h}</th>'
				}
				thead += '</tr>'
				mut tbody := ''
				for row_idx, r in ctrl.rows {
					tbody += '<tr onclick="window.vlangTriggerClick(\'${ctrl.click_id}\', \'${row_idx}\')">'
					for col_idx, col in r {
						mono_style := if col_idx == 1 {
							' style="font-family:ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;font-size:12px;word-break:break-all;overflow-wrap:anywhere;"'
						} else {
							' style="word-break:break-all;overflow-wrap:anywhere;"'
						}
						tbody += '<td${mono_style}>${col}</td>'
					}
					tbody += '</tr>'
				}
				body_html += '<div class="sg-table-container" style="${style_str}"><table id="${ctrl.id}" class="sg-table"><thead>${thead}</thead><tbody>${tbody}</tbody></table></div>'
			}
			.progress {
				val := ctrl.value.int()
				pct := if ctrl.max_val > 0 { f64(val) / f64(ctrl.max_val) * 100.0 } else { 0.0 }
				body_html += '<div id="${ctrl.id}" class="sg-progress-bar" style="${style_str}" ${tip_attr}><div class="sg-progress-fill" style="width: ${pct:.1f}%"></div></div>'
			}
			.kpi_card {
				body_html += '<div id="${ctrl.id}" class="sg-kpi-card" style="${style_str}" ${tip_attr}><div class="sg-kpi-title">${ctrl.text}</div><div class="sg-kpi-value">${ctrl.value}</div><div class="sg-kpi-change">${ctrl.secondary_text}</div></div>'
			}
			.divider {
				body_html += '<hr id="${ctrl.id}" class="sg-divider" style="${style_str}" />'
			}
			.status_bar {
				body_html += '<div id="${ctrl.id}" class="sg-statusbar" style="${style_str}">${ctrl.text}</div>'
			}
			.raw_html {
				body_html += ctrl.text
			}
			else {}
		}
	}

	mut menubar_html := ''
	if win.menubar.len > 0 {
		menubar_html += '<div class="sg-menubar">'
		for cat_idx, cat in win.menubar {
			menubar_html += '<div class="sg-menu-item" onclick="toggleMenuDropdown(event, ${cat_idx})">'
			menubar_html += '${cat.title}'
			menubar_html += '<div class="sg-dropdown-menu" id="sg_dropdown_${cat_idx}">'
			for item in cat.items {
				if item.is_divider {
					menubar_html += '<div class="sg-menu-divider"></div>'
				} else {
					shortcut_html := if item.shortcut != '' {
						'<span class="sg-menu-shortcut">${item.shortcut}</span>'
					} else {
						''
					}
					menubar_html += '<div class="sg-dropdown-item" onclick="selectMenuItem(event, \'${win.menubar_handler_id}\', \'${item.action}\')">'
					menubar_html += '<span class="sg-menu-text">${item.text}</span>${shortcut_html}'
					menubar_html += '</div>'
				}
			}
			menubar_html += '</div>'
			menubar_html += '</div>'
		}
		menubar_html += '</div>'
	}

	mut context_menu_html := ''
	if win.context_menu_items.len > 0 {
		context_menu_html += '<div class="sg-context-menu" id="sgContextMenu">'
		for item in win.context_menu_items {
			if item.is_divider {
				context_menu_html += '<div class="sg-menu-divider"></div>'
			} else {
				shortcut_html := if item.shortcut != '' {
					'<span class="sg-menu-shortcut">${item.shortcut}</span>'
				} else {
					''
				}
				context_menu_html += '<div class="sg-context-item" onclick="selectContextMenuItem(event, \'${win.context_menu_handler_id}\', \'${item.action}\')">'
				context_menu_html += '<span class="sg-menu-text">${item.text}</span>${shortcut_html}'
				context_menu_html += '</div>'
			}
		}
		context_menu_html += '</div>'
	}

	padding_top_style := if win.menubar.len > 0 { 'padding-top: 44px;' } else { '' }

	return '<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>${win.title}</title>
<style>
:root {
	--bg-main: ${theme.background_color};
	--text-main: ${theme.font_color};
	--accent: ${theme.accent_color};
	--secondary: ${theme.secondary_accent};
	--bg-card: ${theme.card_background};
	--border-card: ${theme.card_border};
	--btn-text: ${hex_to_contrast_color(theme.accent_color)};
	--color-scheme: ${if theme.is_dark { 'dark' } else { 'light' }};
}
* { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
body {
	background-color: var(--bg-main);
	color: var(--text-main);
	padding: ${win.padding}px;
	padding-bottom: calc(${win.padding}px + 32px);
	${padding_top_style}
	display: flex;
	flex-direction: column;
	gap: ${win.spacing}px;
	min-height: 100vh;
	user-select: none;
	transition: background-color 0.25s ease, color 0.25s ease;
}
.sg-row {
	display: flex;
	gap: 16px;
	align-items: center;
	width: 100%;
	flex-wrap: wrap;
}
.sg-heading { font-size: 24px; font-weight: 700; color: var(--text-main); letter-spacing: -0.5px; }
.sg-subheading { font-size: 18px; font-weight: 600; color: var(--accent); }
.sg-label { font-size: 14px; opacity: 0.85; line-height: 1.5; }
.sg-btn {
	background-color: var(--accent);
	color: var(--btn-text);
	border: none;
	padding: 10px 18px;
	border-radius: 6px;
	font-weight: 600;
	font-size: 14px;
	cursor: pointer;
	transition: all 0.15s ease;
	align-self: flex-start;
	white-space: nowrap;
	flex-shrink: 0;
}
.sg-btn:hover { filter: brightness(1.1); transform: translateY(-1px); }
.sg-btn:active { transform: translateY(0); filter: brightness(0.9); }
.sg-btn:disabled { cursor: wait; filter: grayscale(0.35); opacity: 0.65; transform: none; }
.sg-input, .sg-textarea, .sg-select {
	background-color: var(--bg-card);
	border: 1px solid var(--border-card);
	color: var(--text-main);
	color-scheme: var(--color-scheme);
	padding: 10px 14px;
	border-radius: 6px;
	font-size: 14px;
	outline: none;
	transition: border-color 0.15s ease, background-color 0.25s ease;
	width: 100%;
	max-width: 100%;
	box-sizing: border-box;
	word-break: break-all;
	overflow-wrap: anywhere;
}
.sg-input::placeholder, .sg-textarea::placeholder { color: var(--text-main); opacity: 0.58; }
.sg-select option { background-color: var(--bg-card); color: var(--text-main); }
.sg-row > .sg-select {
	flex: 1 1 220px;
	min-width: 180px;
	max-width: 380px;
	width: auto;
}
.sg-row > .sg-input {
	flex: 1 1 180px;
	min-width: 140px;
	width: auto;
}
.sg-input:focus, .sg-textarea:focus, .sg-select:focus {
	border-color: var(--accent);
	box-shadow: 0 0 0 2px rgba(120, 160, 255, 0.2);
}
.sg-textarea { min-height: 90px; resize: vertical; word-break: break-all; overflow-wrap: anywhere; white-space: pre-wrap; line-height: 1.5; }

.sg-checkbox-label, .sg-toggle-label, .sg-radio-label {
	display: inline-flex;
	align-items: center;
	gap: 10px;
	font-size: 14px;
	cursor: pointer;
	white-space: nowrap;
	flex-shrink: 0;
	user-select: none;
}

.sg-checkbox-label input[type="checkbox"] {
	appearance: none;
	-webkit-appearance: none;
	width: 18px;
	min-width: 18px;
	height: 18px;
	min-height: 18px;
	border: 2px solid var(--border-card);
	border-radius: 4px;
	outline: none;
	cursor: pointer;
	position: relative;
	flex-shrink: 0;
	transition: all 0.15s ease;
	background: var(--bg-card);
	display: inline-grid;
	place-content: center;
}
.sg-checkbox-label input[type="checkbox"]:checked {
	background-color: var(--accent);
	border-color: var(--accent);
}
.sg-checkbox-label input[type="checkbox"]:checked::after {
	content: "";
	width: 5px;
	height: 9px;
	border: solid var(--btn-text);
	border-width: 0 2px 2px 0;
	transform: rotate(45deg);
	margin-bottom: 2px;
}

.sg-radio-label input[type="radio"], .sg-radio-input {
	appearance: none;
	-webkit-appearance: none;
	width: 18px;
	min-width: 18px;
	height: 18px;
	min-height: 18px;
	border: 2px solid var(--border-card);
	border-radius: 50%;
	outline: none;
	cursor: pointer;
	position: relative;
	flex-shrink: 0;
	transition: all 0.15s ease;
	background: var(--bg-card);
	display: inline-grid;
	place-content: center;
}
.sg-radio-label input[type="radio"]:checked, .sg-radio-input:checked {
	border-color: var(--accent);
}
.sg-radio-label input[type="radio"]:checked::before, .sg-radio-input:checked::before {
	content: "";
	width: 8px;
	height: 8px;
	border-radius: 50%;
	background: var(--accent);
}

.sg-toggle-label { position: relative; }
.sg-toggle-input {
	position: absolute;
	opacity: 0;
	width: 0;
	height: 0;
	pointer-events: none;
}
.sg-toggle-slider {
	width: 44px;
	min-width: 44px;
	height: 24px;
	min-height: 24px;
	background-color: var(--border-card);
	border-radius: 24px;
	position: relative;
	transition: all 0.25s ease;
	flex-shrink: 0;
	box-shadow: inset 0 1px 3px rgba(0,0,0,0.25);
}
.sg-toggle-slider:before {
	content: "";
	position: absolute;
	width: 18px;
	height: 18px;
	border-radius: 50%;
	background: #ffffff;
	left: 3px;
	top: 3px;
	transition: transform 0.25s cubic-bezier(0.4, 0, 0.2, 1);
	box-shadow: 0 1px 3px rgba(0,0,0,0.3);
}
.sg-toggle-input:checked + .sg-toggle-slider {
	background-color: var(--accent);
}
.sg-toggle-input:checked + .sg-toggle-slider:before {
	transform: translateX(20px);
}

.sg-slider { width: 100%; accent-color: var(--accent); }
.sg-table-container {
	border: 1px solid var(--border-card);
	border-radius: 8px;
	overflow-x: auto;
	background-color: var(--bg-card);
	transition: all 0.25s ease;
	width: 100%;
	box-sizing: border-box;
}
.sg-table { width: 100%; border-collapse: collapse; text-align: left; font-size: 13px; table-layout: fixed; }
.sg-table th { background: rgba(128,128,128,0.12); padding: 10px 14px; font-weight: 600; border-bottom: 1px solid var(--border-card); color: var(--text-main); }
.sg-table th:first-child { width: 22%; min-width: 130px; }
.sg-table th:last-child { width: 12%; min-width: 70px; text-align: right; }
.sg-table td { padding: 9px 14px; border-bottom: 1px solid var(--border-card); color: var(--text-main); word-break: break-all; overflow-wrap: anywhere; box-sizing: border-box; }
.sg-table td:last-child { text-align: right; }
.sg-table tr:hover td { background-color: rgba(128,128,128,0.12); cursor: pointer; }
.sg-table tr.sg-table-selected td { background-color: var(--accent); color: var(--btn-text); }
.sg-progress-bar { width: 100%; height: 8px; background-color: var(--border-card); border-radius: 4px; overflow: hidden; }
.sg-progress-fill { height: 100%; background-color: var(--accent); transition: width 0.3s ease; }
.sg-kpi-card {
	background-color: var(--bg-card);
	border: 1px solid var(--border-card);
	border-radius: 8px;
	padding: 16px;
	display: flex;
	flex-direction: column;
	gap: 6px;
	transition: background-color 0.25s ease, border-color 0.25s ease;
}
.sg-kpi-title { font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.7; }
.sg-kpi-value { font-size: 28px; font-weight: 700; color: var(--accent); transition: color 0.25s ease; }
.sg-kpi-change { font-size: 12px; color: var(--secondary); font-weight: 500; transition: color 0.25s ease; }
.sg-divider { border: none; border-top: 1px solid var(--border-card); margin: 6px 0; }
.sg-statusbar {
	position: fixed; bottom: 0; left: 0; right: 0;
	background-color: var(--bg-card); border-top: 1px solid var(--border-card);
	padding: 6px 14px; font-size: 12px; color: var(--text-main); opacity: 0.85;
	transition: background-color 0.25s ease, border-color 0.25s ease;
}

/* Menubar Styling */
.sg-menubar {
	position: fixed;
	top: 0;
	left: 0;
	right: 0;
	height: 34px;
	background-color: var(--bg-card);
	border-bottom: 1px solid var(--border-card);
	display: flex;
	align-items: center;
	padding: 0 8px;
	z-index: 9000;
	user-select: none;
	font-size: 13px;
	font-weight: 500;
}
.sg-menu-item {
	position: relative;
	padding: 6px 12px;
	cursor: pointer;
	border-radius: 4px;
	color: var(--text-main);
	transition: background 0.15s ease, color 0.15s ease;
}
.sg-menu-item:hover {
	background-color: var(--accent);
	color: var(--btn-text);
}
.sg-dropdown-menu {
	display: none;
	position: absolute;
	top: 100%;
	left: 0;
	min-width: 220px;
	background-color: var(--bg-card);
	border: 1px solid var(--border-card);
	border-radius: 6px;
	box-shadow: 0 10px 30px rgba(0,0,0,0.5);
	padding: 4px 0;
	z-index: 9001;
}
.sg-dropdown-item, .sg-context-item {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 7px 14px;
	color: var(--text-main);
	cursor: pointer;
	font-size: 13px;
	transition: background 0.15s ease, color 0.15s ease;
}
.sg-dropdown-item:hover, .sg-context-item:hover {
	background-color: var(--accent);
	color: var(--btn-text);
}
.sg-menu-shortcut {
	font-size: 11px;
	opacity: 0.6;
	margin-left: 20px;
	font-family: monospace;
}
.sg-menu-divider {
	border-top: 1px solid var(--border-card);
	margin: 4px 0;
}

/* Context Menu Styling */
.sg-context-menu {
	display: none;
	position: fixed;
	min-width: 230px;
	background-color: var(--bg-card);
	border: 1px solid var(--border-card);
	border-radius: 8px;
	box-shadow: 0 14px 35px rgba(0,0,0,0.6);
	padding: 6px 0;
	z-index: 99999;
.sg-kbd {
	background: var(--bg-card);
	border: 1px solid var(--border-card);
	border-radius: 4px;
	padding: 2px 6px;
	font-family: monospace;
	font-size: 12px;
	box-shadow: 0 2px 0 var(--border-card);
}
.sg-hotkey-badge-row {
	display: flex;
	align-items: center;
	gap: 10px;
}
.sg-section-header {
	margin-top: 8px;
	margin-bottom: 4px;
	width: 100%;
}
.sg-section-title {
	font-size: 16px;
	font-weight: 700;
	color: var(--text-main);
}
.sg-section-sub {
	font-size: 12px;
	opacity: 0.7;
	margin-top: 2px;
	margin-bottom: 6px;
}
.sg-badge {
	display: inline-block;
	padding: 3px 8px;
	border-radius: 12px;
	font-size: 11px;
	font-weight: 600;
	text-align: center;
}
.sg-code-view {
	background: var(--bg-card);
	border: 1px solid var(--border-card);
	border-radius: 6px;
	padding: 12px;
	font-family: monospace;
	font-size: 13px;
	overflow-x: auto;
	line-height: 1.4;
	width: 100%;
}
.sg-color-picker {
	border: 1px solid var(--border-card);
	border-radius: 4px;
	width: 36px;
	height: 36px;
	cursor: pointer;
	background: transparent;
}
@media (max-width: 600px) {
	body {
		padding-left: 12px;
		padding-right: 12px;
		gap: 12px;
	}
	.sg-heading { font-size: 20px; }
	.sg-row { align-items: stretch; }
	.sg-row > .sg-input, .sg-row > .sg-select, .sg-btn {
		width: 100% !important;
		max-width: none !important;
	}
	.sg-checkbox-label, .sg-toggle-label, .sg-radio-label { white-space: normal; }
	.sg-table { min-width: 640px; table-layout: auto; }
	.sg-statusbar {
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}
}
.sg-link {
	background: transparent !important;
	color: var(--accent) !important;
	text-decoration: underline;
	padding: 4px 0 !important;
	border: none !important;
	cursor: pointer;
}
.sg-btn-help {
	border-radius: 50% !important;
	width: 28px !important;
	height: 28px !important;
	padding: 0 !important;
	display: inline-flex !important;
	align-items: center;
	justify-content: center;
}
</style>
<script>
window.vlangThemeMap = ${get_themes_json()};
window.applyTheme = function(themeName) {
	if (window.vlangThemeMap && window.vlangThemeMap[themeName]) {
		const t = window.vlangThemeMap[themeName];
		const r = document.documentElement;
		r.style.setProperty("--bg-main", t.background_color);
		r.style.setProperty("--text-main", t.font_color);
		r.style.setProperty("--accent", t.accent_color);
		r.style.setProperty("--secondary", t.secondary_accent);
		r.style.setProperty("--bg-card", t.card_background);
		r.style.setProperty("--border-card", t.card_border);
		r.style.setProperty("--btn-text", t.btn_text || "#ffffff");
		r.style.setProperty("--color-scheme", t.is_dark ? "dark" : "light");
		document.body.style.backgroundColor = t.background_color;
		document.body.style.color = t.font_color;
	}
};
window.vlangTriggerClick = function(handlerId, controlId) {
	if (window.vlangEventHandler) {
		window.vlangEventHandler(handlerId, controlId);
	}
};
window.vlangTriggerChange = function(handlerId, controlId, val) {
	if (window.vlangThemeMap && window.vlangThemeMap[val]) {
		window.applyTheme(val);
	}
	if (window.vlangSyncValue) {
		window.vlangSyncValue(controlId, String(val));
	}
	if (window.vlangEventHandler) {
		window.vlangEventHandler(handlerId, String(val));
	}
};

// Menubar interaction
function toggleMenuDropdown(e, idx) {
	e.stopPropagation();
	const all = document.querySelectorAll(".sg-dropdown-menu");
	const target = document.getElementById("sg_dropdown_" + idx);
	const isShown = target && target.style.display === "block";
	all.forEach(el => el.style.display = "none");
	if (target && !isShown) {
		target.style.display = "block";
	}
}

function selectMenuItem(e, handlerId, action) {
	e.stopPropagation();
	document.querySelectorAll(".sg-dropdown-menu").forEach(el => el.style.display = "none");
	if (window.vlangTriggerClick) {
		window.vlangTriggerClick(handlerId, action);
	}
}

// Context Menu interaction
window.addEventListener("contextmenu", function(e) {
	e.preventDefault();
	const menu = document.getElementById("sgContextMenu");
	if (!menu) return;
	
	let x = e.clientX;
	let y = e.clientY;
	const winW = window.innerWidth;
	const winH = window.innerHeight;
	menu.style.display = "block";
	const menuW = menu.offsetWidth || 230;
	const menuH = menu.offsetHeight || 250;
	
	if (x + menuW > winW) x = Math.max(10, winW - menuW - 10);
	if (y + menuH > winH) y = Math.max(10, winH - menuH - 10);
	
	menu.style.left = x + "px";
	menu.style.top = y + "px";
}, true);

function selectContextMenuItem(e, handlerId, action) {
	e.stopPropagation();
	const menu = document.getElementById("sgContextMenu");
	if (menu) menu.style.display = "none";
	if (window.vlangTriggerClick) {
		window.vlangTriggerClick(handlerId, action);
	}
}

document.addEventListener("click", function() {
	document.querySelectorAll(".sg-dropdown-menu").forEach(el => el.style.display = "none");
	const cm = document.getElementById("sgContextMenu");
	if (cm) cm.style.display = "none";
});

document.addEventListener("keydown", function(e) {
	if (e.key === "Escape") {
		document.querySelectorAll(".sg-dropdown-menu").forEach(el => el.style.display = "none");
		const cm = document.getElementById("sgContextMenu");
		if (cm) cm.style.display = "none";
	}
});
</script>
</head>
<body>
${menubar_html}
${body_html}
${context_menu_html}
</body>
</html>'
}

// Event Loop Runner

pub fn (mut win SimpleWindow) run() {
	mut w := webview.create(debug: true)
	win.wv = w

	w.set_title(win.title)
	w.set_size(win.width, win.height, .@none)

	if win.always_on_top {
		w.set_always_on_top(true)
	}

	w.attach_window_management_bindings()
	w.attach_system_bindings()
	w.attach_stdlib_bindings()

	// Bind custom SimpleGUI events
	w.bind('vlangEventHandler', fn [mut win] (e &webview.Event) string {
		handler_id := e.get_arg[string](0) or { '' }
		val := e.get_arg[string](1) or { '' }
		control_id := if handler_id.starts_with('click_') { handler_id[6..] } else { '' }
		is_button_action := if idx := win.name_to_ctrl[control_id] {
			win.controls[idx].typ == .button
		} else {
			false
		}
		if is_button_action {
			if !win.try_begin_action() {
				return 'busy'
			}
			win.set_action_controls_enabled(false)
			defer {
				win.set_action_controls_enabled(true)
				win.end_action()
			}
		}
		if handler_id.starts_with('change_') {
			ctrl_id := handler_id[7..]
			win.state_lock.lock()
			{
				defer {
					win.state_lock.unlock()
				}
				win.values[ctrl_id] = val
				if idx := win.name_to_ctrl[ctrl_id] {
					win.controls[idx].value = val
					actual_id := win.controls[idx].id
					win.values[actual_id] = val
					for k, v in win.name_to_ctrl {
						if v == idx {
							win.values[k] = val
						}
					}
				}
			}
		}
		if handler := win.event_handlers[handler_id] {
			handler(win, val)
		}
		return 'ok'
	})

	w.bind('vlangSyncValue', fn [mut win] (e &webview.Event) string {
		id := e.get_arg[string](0) or { '' }
		val := e.get_arg[string](1) or { '' }
		win.state_lock.lock()
		{
			defer {
				win.state_lock.unlock()
			}
			win.values[id] = val
			if idx := win.name_to_ctrl[id] {
				win.controls[idx].value = val
				actual_id := win.controls[idx].id
				win.values[actual_id] = val
				for k, v in win.name_to_ctrl {
					if v == idx {
						win.values[k] = val
					}
				}
			}
		}
		return 'ok'
	})

	html_content := win.generate_html()
	export_path := os.getenv('SIMPLEGUI_EXPORT_HTML')
	if export_path.len > 0 {
		os.write_file(export_path, html_content) or {}
		return
	}
	w.set_html(html_content)

	if win.fullscreen {
		w.set_fullscreen(true)
	}

	w.run()
}
