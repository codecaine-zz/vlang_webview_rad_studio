module main

import simplegui
import sqliteutils
import system
import time
import os

struct QueryResult {
	headers  []string
	rows     [][]string
	duration string
}

fn execute_sql_query(path string, query string) !QueryResult {
	if path.trim_space() == '' {
		return error('database path must not be empty')
	}
	if query.trim_space() == '' {
		return error('SQL query must not be empty')
	}
	sw := time.new_stopwatch()
	mut db := sqliteutils.open_db(path)!
	defer {
		sqliteutils.close_db(mut db) or {}
	}
	result := db.exec(query)!
	elapsed := sw.elapsed()
	dur_str := '${elapsed.milliseconds()}ms'

	if result.len == 0 {
		return QueryResult{
			headers: ['Status']
			rows: [['Query executed successfully. 0 rows returned.']]
			duration: dur_str
		}
	}

	mut column_count := 0
	mut rows := [][]string{}
	for item in result {
		if item.vals.len > column_count {
			column_count = item.vals.len
		}
		rows << item.vals.clone()
	}

	mut col_headers := []string{}
	// Extract column names if available from query or default
	for i in 0 .. column_count {
		col_headers << 'Col ${i + 1}'
	}

	return QueryResult{
		headers: col_headers
		rows: rows
		duration: dur_str
	}
}

fn fetch_tables_list(path string) []string {
	if path.trim_space() == '' {
		return []string{}
	}
	mut db := sqliteutils.open_db(path) or { return []string{} }
	defer {
		sqliteutils.close_db(mut db) or {}
	}
	result := db.exec("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name;") or {
		return []string{}
	}
	mut tables := []string{}
	for r in result {
		if r.vals.len > 0 && r.vals[0] != '' {
			tables << r.vals[0]
		}
	}
	return tables
}

fn export_query_results_csv(headers []string, rows [][]string) string {
	mut lines := []string{}
	lines << headers.map('"${it}"').join(',')
	for r in rows {
		lines << r.map('"${it.replace("\"", "\"\"")}"').join(',')
	}
	return lines.join('\n')
}

fn main() {
	mut last_headers := []string{}
	mut last_rows := [][]string{}

	mut win := simplegui.new_window(
		title: 'Database Studio Pro Enterprise -- SQLite Query & Schema Workbench'
		width: 1180
		height: 890
		theme: 'one_dark_pro'
	)

	win.heading('🗄️ Database Studio Pro Enterprise')
	win.subheading('High-Performance Embedded SQLite Database Query Console, Schema Inspector & Data Browser')
	win.divider()

	// Top Telemetry Dashboard
	win.row_start()
	win.kpi_card_named('kpi_status', 'Database Connection', 'Connected (:memory:)', 'Active')
	win.kpi_card_named('kpi_rows', 'Rows Returned', '3 Rows', 'Demo Data')
	win.kpi_card_named('kpi_latency', 'Query Latency', '0ms', 'Standby')
	win.kpi_card_named('kpi_tables', 'Tables Discovered', '0 Tables', 'In-memory')
	win.row_end()

	// Database Configuration Box
	win.box_start('⚙️ Target Database & Schema Browser')
	win.row_start()
	win.input_named('db_path', 'SQLite Database Path (*.db, *.sqlite, or :memory:)...', ':memory:', fn (w &simplegui.SimpleWindow, val string) {
		w.set_status('Target database path: ' + val)
	})
	win.button('📂 Browse DB File...', fn (w &simplegui.SimpleWindow, _ string) {
		path := w.open_file_dialog('Select SQLite Database', 'sqlite,db,sqlite3')
		if path != '' {
			w.set_value('db_path', path)
			w.set_kpi('kpi_status', os.file_name(path), 'File DB')
			w.toast_success('Connected to database: ' + path)
			tables := fetch_tables_list(path)
			w.set_kpi('kpi_tables', '${tables.len} Tables', 'Found')
		}
	})
	win.button('🧠 In-Memory DB', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_value('db_path', ':memory:')
		w.set_kpi('kpi_status', 'Connected (:memory:)', 'Volatile')
		w.toast_info('Switched to in-memory database (:memory:)')
	})
	win.row_end()

	// Query Presets & Input Box
	win.row_start()
	presets := [
		'Template: Sample Users Query',
		'Template: Create & Populate Products Table',
		'Template: Show All Database Tables',
		'Template: Table Schema Information',
	]
	win.dropdown_named('sql_presets', presets, presets[0], fn (w &simplegui.SimpleWindow, val string) {
		query := match val {
			'Template: Sample Users Query' {
				'SELECT 1 AS id, "Alice" AS name, "admin" AS role, "active" AS status\nUNION ALL SELECT 2, "Bob", "developer", "active"\nUNION ALL SELECT 3, "Charlie", "designer", "pending";'
			}
			'Template: Create & Populate Products Table' {
				'CREATE TABLE IF NOT EXISTS products (id INTEGER PRIMARY KEY, sku TEXT, name TEXT, price REAL);\nINSERT INTO products (sku, name, price) VALUES ("PRD-001", "Studio Key", 49.99);\nSELECT * FROM products;'
			}
			'Template: Show All Database Tables' {
				"SELECT type, name, tbl_name FROM sqlite_master WHERE type='table' ORDER BY name;"
			}
			'Template: Table Schema Information' {
				"PRAGMA table_info('products');"
			}
			else { 'SELECT 1;' }
		}
		w.set_value('sql_query', query)
		w.toast_info('Loaded SQL preset: ' + val)
	})
	win.button('⚡ Execute SQL Query', fn [mut last_headers, mut last_rows] (w &simplegui.SimpleWindow, _ string) {
		path := w.get('db_path').trim_space()
		query_sql := w.get('sql_query').trim_space()

		result := execute_sql_query(path, query_sql) or {
			w.toast_error('SQL Error: ${err}')
			w.set_status('Query Failed: ${err}')
			return
		}

		last_headers = result.headers.clone()
		last_rows = result.rows.clone()

		w.set_table_headers('query_results', result.headers)
		w.set_table_rows('query_results', result.rows)

		w.set_kpi('kpi_rows', '${result.rows.len} Rows', 'Returned')
		w.set_kpi('kpi_latency', result.duration, 'Execution Time')
		w.toast_success('Query executed in ${result.duration} (${result.rows.len} rows)')
		w.set_status('Executed successfully • ${result.rows.len} row(s) returned in ${result.duration}')
	})
	win.row_end()

	win.textarea_named('sql_query', 'Enter SQL query (SELECT, INSERT, UPDATE, CREATE TABLE)...', 'SELECT 1 AS id, "Alice" AS name, "admin" AS role, "active" AS status\nUNION ALL SELECT 2, "Bob", "developer", "active"\nUNION ALL SELECT 3, "Charlie", "designer", "pending";', fn (w &simplegui.SimpleWindow, _ string) {})
	win.box_end()

	// Query Results Table Box
	win.box_start('📊 SQL Query Results Browser')
	default_headers := ['ID', 'User Name', 'Role', 'Status']
	default_rows := [
		['1', 'Alice', 'admin', 'active'],
		['2', 'Bob', 'developer', 'active'],
		['3', 'Charlie', 'designer', 'pending'],
	]
	win.table_named('query_results', default_headers, default_rows, fn (w &simplegui.SimpleWindow, idx string) {
		w.toast_info('Inspected row #${idx}')
	})

	win.row_start()
	win.button('💾 Export Results to CSV', fn [last_headers, last_rows] (w &simplegui.SimpleWindow, _ string) {
		if last_rows.len == 0 {
			w.toast_warning('No query results to export.')
			return
		}
		path := w.save_file_dialog('Export Query Results to CSV', 'query_export.csv')
		if path != '' {
			csv := export_query_results_csv(last_headers, last_rows)
			os.write_file(path, csv) or {
				w.toast_error('Failed to export CSV: ${err}')
				return
			}
			w.toast_success('Exported query results to: ' + path)
		}
	})
	win.button('📋 Copy Results CSV', fn [last_headers, last_rows] (w &simplegui.SimpleWindow, _ string) {
		if last_rows.len == 0 {
			w.toast_warning('No results to copy.')
			return
		}
		csv := export_query_results_csv(last_headers, last_rows)
		system.set_clipboard_text(csv)
		w.toast_success('Query results copied to clipboard as CSV!')
	})
	win.button('🧹 Clear Results Table', fn (w &simplegui.SimpleWindow, _ string) {
		w.set_table_rows('query_results', [][]string{})
		w.set_kpi('kpi_rows', '0 Rows', 'Cleared')
		w.toast_info('Results table cleared')
	})
	win.row_end()
	win.box_end()

	win.status_bar('Database Studio Pro Enterprise  •  SQLite3 Engine  •  Ready')
	win.run()
}
