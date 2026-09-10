module simplegui

pub enum ControlType {
	button
	label
	heading
	subheading
	input
	password
	textarea
	checkbox
	radio
	toggle
	slider
	dropdown
	table
	tree_view
	tabs
	progress
	kpi_card
	groupbox
	divider
	toolbar
	status_bar
	raw_html
	search_field
	color_picker
	date_picker
	code_view
	markdown
	image
	badge
	section_header
	hotkey_badge
}

pub struct ControlSpec {
pub mut:
	id               string
	typ              ControlType
	text             string
	placeholder      string
	value            string
	checked          bool
	min_val          int
	max_val          int
	step_val         int
	options          []string
	headers          []string
	rows             [][]string
	change_id        string
	click_id         string
	css_class        string
	width            int
	height           int
	left             int
	top              int
	font_size        int
	background_color string
	font_color       string
	secondary_text   string
	tooltip          string
	is_bold          bool
	expand_fill      bool
	enabled          bool = true
	visible          bool = true
	alignment        string
}

@[heap]
pub struct ControlRef {
pub mut:
	spec   &ControlSpec
	window &SimpleWindow
}

pub fn (mut cr ControlRef) id(new_id string) &ControlRef {
	cr.spec.id = new_id
	return cr
}

pub fn (mut cr ControlRef) width(w int) &ControlRef {
	cr.spec.width = w
	return cr
}

pub fn (mut cr ControlRef) height(h int) &ControlRef {
	cr.spec.height = h
	return cr
}

pub fn (mut cr ControlRef) pos(x int, y int) &ControlRef {
	cr.spec.left = x
	cr.spec.top = y
	return cr
}

pub fn (mut cr ControlRef) bg(color string) &ControlRef {
	cr.spec.background_color = color
	return cr
}

pub fn (mut cr ControlRef) color(color string) &ControlRef {
	cr.spec.font_color = color
	return cr
}

pub fn (mut cr ControlRef) font_size(size int) &ControlRef {
	cr.spec.font_size = size
	return cr
}

pub struct MenuItem {
pub:
	text       string
	action     string
	shortcut   string
	is_divider bool
}

pub struct MenuCategory {
pub:
	title string
	items []MenuItem
}

