module main

import simplegui
import system

fn main() {
	// 1. Load saved preferences or use defaults
	mut state := system.load_app_state_or('DevOpsWorkstation', 'state.json')
	target_host := state['target_host'] or { '1.1.1.1' }

	mut win := simplegui.new_window(
		title: 'DevOps Hardware & Network Sentinel'
		width: 1024
		height: 720
		theme: 'tokyo_night'
		fullscreen: true
	)

	// 2. Menubar
	win.set_menubar([
		simplegui.MenuCategory{
			title: '⚡ Actions'
			items: [
				simplegui.MenuItem{ text: '🔄 Refresh Now', action: 'refresh', shortcut: 'Cmd+R' },
				simplegui.MenuItem{ text: '🚪 Quit', action: 'quit', shortcut: 'Cmd+Q' },
			]
		}
	], fn (w &simplegui.SimpleWindow, action string) {
		if action == 'quit' { w.quit() }
	})

	// 3. Hardware KPI Cards
	hw := system.get_hardware_telemetry()
	win.box_start('Hardware Telemetry')
	win.row_start()
	win.kpi_card('CPU Model', hw.cpu_model, '${hw.cpu_cores} Cores (${hw.cpu_usage.str()}% load)')
	win.kpi_card('Memory (RAM)', hw.ram_formatted, 'RAM in use')
	win.kpi_card('Battery', '${hw.battery_percent}%', if hw.battery_charging { '⚡ Charging' } else { '🔋 On Battery' })
	win.row_end()
	win.box_end()

	// 4. Network Diagnostics Section
	win.box_start('Network Health')
	win.row_start()
	masked_ip := system.get_masked_ip()
	is_online := system.ping_host(target_host)
	win.label('Network IP: ${masked_ip} | Host ${target_host}: ' + if is_online { 'ONLINE ✅' } else { 'OFFLINE ❌' })
	win.row_end()
	win.box_end()

	// 5. Actions & Window Controls
	win.box_start('Quick Controls')
	win.row_start()
	win.button('⛶ Toggle Fullscreen (Cmd+F)', fn (w &simplegui.SimpleWindow, _ string) {
		w.toggle_fullscreen()
	})
	win.button('📌 Pin On Top (Cmd+Shift+T)', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_always_on_top(true)
		w.notification('Window Pinned', 'Sentinel is now always on top.')
	})
	win.button('🎯 Center Window', fn (w &simplegui.SimpleWindow, _ string) {
		w.center()
	})
	win.button('🔊 Sound Test', fn (w &simplegui.SimpleWindow, _ string) {
		system.sys_beep()
	})
	win.row_end()
	win.box_end()

	win.status_bar('DevOps Sentinel: Active | Host: ${target_host} | Press Cmd+Q to Exit')

	// 6. Run Application
	win.run()
}
