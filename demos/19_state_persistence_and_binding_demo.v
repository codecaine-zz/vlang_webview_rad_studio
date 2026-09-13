module main

import simplegui
import stateutils
import time

struct UserProfileState {
pub mut:
	username         string = 'alex_mercer'
	company          string = 'Antigravity Systems'
	role             string = 'Architect'
	remember_session bool   = true
	updated_at       string
}

const app_id = 'vlang_rad_studio_demo19'
const state_filename = 'user_profile_v1.json'

fn update_preview(w &simplegui.SimpleWindow, status_label string, change_label string) {
	user := w.get('username')
	role := w.get('role')
	display_user := if user.len > 0 { user } else { '(empty)' }
	display_role := if role.len > 0 { role } else { 'General' }
	w.set_kpi('kpi_profile', display_user, display_role)
	w.set_kpi('kpi_sync', status_label, change_label)
}

fn main() {
	mut initial_state := UserProfileState{
		username: 'alex_mercer'
		company: 'Antigravity Systems'
		role: 'Architect'
		remember_session: true
		updated_at: 'Initial Preset'
	}

	if stateutils.app_state_exists(app_id, state_filename) {
		if loaded := stateutils.load_app_state[UserProfileState](app_id, state_filename) {
			initial_state = loaded
		}
	}

	mut win := simplegui.new_window(
		title: 'Demo 19 - State Persistence & Reactive Bindings'
		width: 900
		height: 660
		theme: 'nord'
	)

	win.heading('💾 State Persistence & Two-Way Bindings')
	win.subheading('Live synchronized form fields and state restoration across renders:')
	win.divider()

	win.box_start('Persisted User Profile')
	win.row_start()
	win.input_named('username', 'Username', initial_state.username, fn (w &simplegui.SimpleWindow, val string) {
		update_preview(w, 'Modified', 'Live Typing...')
		w.set_status('⚡ Username updated to "${val}" (unsaved changes)')
	})
	win.input_named('company', 'Company', initial_state.company, fn (w &simplegui.SimpleWindow, val string) {
		update_preview(w, 'Modified', 'Live Typing...')
		w.set_status('⚡ Company updated to "${val}" (unsaved changes)')
	})
	win.row_end()

	win.row_start()
	win.dropdown_named('role', ['Engineer', 'Manager', 'Architect', 'Director'], initial_state.role, fn (w &simplegui.SimpleWindow, val string) {
		update_preview(w, 'Modified', 'Role Changed')
		w.set_status('⚡ Role selection changed to "${val}" (unsaved changes)')
	})
	win.toggle_named('remember_session', 'Remember Session on Exit', initial_state.remember_session, fn (w &simplegui.SimpleWindow, val string) {
		status_desc := if val == 'true' { 'Enabled' } else { 'Disabled' }
		update_preview(w, 'Modified', 'Session: ' + status_desc)
		w.set_status('⚡ Session persistence set to ${status_desc} (unsaved changes)')
	})
	win.row_end()
	win.box_end()

	win.box_start('Dynamic Live Value Preview')
	win.row_start()
	win.kpi_card_named('kpi_profile', 'Current Profile', initial_state.username, initial_state.role)
	sync_change := if initial_state.updated_at.len > 0 { initial_state.updated_at } else { 'Ready' }
	win.kpi_card_named('kpi_sync', 'Sync Status', 'Synchronized', sync_change)
	win.row_end()
	win.box_end()

	win.row_start()
	win.button('💾 Force Save State', fn (w &simplegui.SimpleWindow, _ string) {
		profile := UserProfileState{
			username: w.get('username')
			company: w.get('company')
			role: w.get('role')
			remember_session: w.get_bool('remember_session')
			updated_at: time.now().format_ss()
		}
		stateutils.save_app_state[UserProfileState](app_id, state_filename, profile) or {
			w.toast_error('Failed to save state: ${err.msg()}')
			return
		}
		path := stateutils.get_state_path(app_id, state_filename, .data)
		update_preview(w, 'Synchronized', 'Saved at ' + profile.updated_at)
		w.toast_success('User profile state persisted to disk!')
		w.set_status('Profile state persisted to disk: ' + path)
	})
	win.button('🔄 Reload State', fn (w &simplegui.SimpleWindow, _ string) {
		loaded := stateutils.load_app_state[UserProfileState](app_id, state_filename) or {
			w.toast_warning('No saved state on disk. Using default presets.')
			return
		}
		w.set_value('username', loaded.username)
		w.set_value('company', loaded.company)
		w.set_value('role', loaded.role)
		w.set_checked('remember_session', loaded.remember_session)
		w.set_kpi('kpi_profile', loaded.username, loaded.role)
		timestamp := if loaded.updated_at.len > 0 { loaded.updated_at } else { 'Loaded' }
		w.set_kpi('kpi_sync', 'Synchronized', 'Restored: ' + timestamp)
		w.toast_info('Profile state successfully reloaded from storage cache!')
		w.set_status('Profile reloaded from disk: ${loaded.username} (${loaded.role})')
	})
	win.button('↺ Reset Defaults', fn (w &simplegui.SimpleWindow, _ string) {
		stateutils.delete_app_state(app_id, state_filename) or {}
		w.set_value('username', 'alex_mercer')
		w.set_value('company', 'Antigravity Systems')
		w.set_value('role', 'Architect')
		w.set_checked('remember_session', true)
		w.set_kpi('kpi_profile', 'alex_mercer', 'Architect')
		w.set_kpi('kpi_sync', 'Default Presets', 'Cache Cleared')
		w.toast_warning('Form reset to default presets and storage cache cleared.')
		w.set_status('State reset to factory presets.')
	})
	win.row_end()

	target_path := stateutils.get_state_path(app_id, state_filename, .data)
	win.status_bar('Storage Driver: stateutils JSON backend (${target_path})')

	win.run()
}
