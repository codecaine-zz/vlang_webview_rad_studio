module main

import flag
import os
import system

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('database_cli')
	fp.version('2.0.0')
	fp.description('Enterprise SQLite Database Inspector & SQL Console')
	fp.skip_executable()

	db_path := fp.string('database', `d`, 'app.db', 'SQLite database file path')
	list_tables := fp.bool('tables', `t`, false, 'List all tables in the database')
	schema_table := fp.string('schema', `s`, '', 'Display schema of specified table')
	exec_sql := fp.string('query', `q`, '', 'Execute an SQL query')

	additional_args := fp.finalize() or {
		println('Error: ${err}')
		println(fp.usage())
		return
	}

	query := if exec_sql != '' {
		exec_sql
	} else if additional_args.len > 0 {
		additional_args.join(' ')
	} else {
		''
	}

	if list_tables {
		out, _ := system.exec('sqlite3 "${db_path}" "SELECT name FROM sqlite_master WHERE type=\'table\';"')
		println('====================================================================')
		println('📦 TABLES IN ${db_path}:')
		println('====================================================================')
		println(out)
		return
	}

	if schema_table != '' {
		out, _ := system.exec('sqlite3 "${db_path}" ".schema ${schema_table}"')
		println('====================================================================')
		println('📐 SCHEMA FOR TABLE ${schema_table}:')
		println('====================================================================')
		println(out)
		return
	}

	if query != '' {
		out, code := system.exec('sqlite3 -header -column "${db_path}" "${query}"')
		if code != 0 {
			eprintln('❌ Query failed:\n${out}')
			exit(1)
		}
		println(out)
		return
	}

	println(fp.usage())
}
