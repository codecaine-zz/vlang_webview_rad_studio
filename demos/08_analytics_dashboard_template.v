module main

import simplegui

fn main() {
	mut win := simplegui.new_window(
		title: 'Demo 8 - Analytics Dashboard Template'
		width: 1000
		height: 750
		theme: 'catppuccin_mocha'
	)

	win.heading('📈 Enterprise Analytics & Executive Dashboard')
	win.subheading('Live business intelligence, conversion funnels & revenue performance:')
	win.divider()

	win.row_start()
	win.kpi_card('Gross Revenue', '$128,490.00', '+18.2% vs last month')
	win.kpi_card('Conversion Rate', '4.68%', '+0.4% improvement')
	win.kpi_card('Active Subscriptions', '1,420', 'Net +95 this week')
	win.kpi_card('Refund Rate', '0.42%', 'Target < 1.0%')
	win.row_end()

	win.box_start('Target Quarterly Quota (82% Reached)')
	win.progress(82, 100)
	win.box_end()

	win.box_start('Recent High-Value Enterprise Transactions')
	headers := ['Transaction ID', 'Account Name', 'Plan Tier', 'Amount', 'Date', 'Status']
	rows := [
		['TXN-9042', 'Global Logistics LLC', 'Enterprise Annual', '$24,000.00', '2026-09-08', 'Settled'],
		['TXN-9043', 'OmniCorp Dynamics', 'Scale Custom', '$18,500.00', '2026-09-09', 'Settled'],
		['TXN-9044', 'Apex Systems Group', 'Enterprise Pro', '$12,000.00', '2026-09-09', 'Settled'],
		['TXN-9045', 'Horizon Media Cloud', 'Developer Pro', '$2,400.00', '2026-09-10', 'Processing'],
	]
	win.table(headers, rows, fn (w &simplegui.SimpleWindow, row string) {
		println('Selected Transaction: ${row}')
	})
	win.box_end()

	win.row_start()
	win.button('📥 Export CSV Report', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('Report Exported', 'CSV summary generated and saved to Downloads.')
	})
	win.button('🔄 Refresh Analytics', fn (w &simplegui.SimpleWindow, _ string) {
		w.alert('Refreshed', 'Latest data synchronized with cloud pipeline.')
	})
	win.row_end()

	win.status_bar('Data Pipeline: Connected to BigQuery Lakehouse | Last sync: 10 seconds ago')

	win.run()
}
