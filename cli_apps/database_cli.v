module main

import flag
import os
import system

fn is_safe_read_query(query string) bool {
	normalized := query.to_upper().replace('\n', ' ').replace('\r', ' ').trim_space()
	if normalized == '' {
		return false
	}
	return normalized.starts_with('SELECT ') || normalized == 'SELECT'
		|| normalized.starts_with('WITH ') || normalized.starts_with('EXPLAIN ')
		|| normalized.starts_with('PRAGMA ')
}

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
	allow_write := fp.bool('allow-write', `w`, false, 'Allow a query that can modify the database')

	additional_args := fp.finalize() or {
		eprintln('Error: ${err}')
		eprintln(fp.usage())
		exit(2)
	}

	query := if exec_sql != '' {
		exec_sql
	} else if additional_args.len > 0 {
		additional_args.join(' ')
	} else {
		''
	}
	mode_count := int(list_tables) + int(schema_table != '') + int(query != '')
	if mode_count > 1 {
		eprintln('Error: --tables, --schema, and query modes are mutually exclusive')
		exit(2)
	}

	if (list_tables || schema_table != '' || query != '') && !os.is_file(db_path) {
		eprintln('Error: Database file "${db_path}" does not exist or is not a regular file')
		exit(1)
	}

	if list_tables {
		res := system.exec_safe('sqlite3', ['-readonly', db_path,
			"SELECT name FROM sqlite_master WHERE type='table';"])
		if res.exit_code != 0 {
			eprintln('Error: Unable to list tables: ${res.output.trim_space()}')
			exit(1)
		}
		println('====================================================================')
		println('📦 TABLES IN ${db_path}:')
		println('====================================================================')
		println(res.output.trim_space())
		return
	}

	if schema_table != '' {
		if schema_table.bytes().any(!(it.is_alnum() || it in [`.`, `_`])) {
			eprintln('Error: Invalid table name "${schema_table}"')
			exit(2)
		}
		res := system.exec_safe('sqlite3', ['-readonly', db_path, '.schema ${schema_table}'])
		if res.exit_code != 0 {
			eprintln('Error: Unable to read schema: ${res.output.trim_space()}')
			exit(1)
		}
		println('====================================================================')
		println('📐 SCHEMA FOR TABLE ${schema_table}:')
		println('====================================================================')
		println(res.output.trim_space())
		return
	}

	if query != '' {
		if !allow_write && !is_safe_read_query(query) {
			eprintln('Error: Refusing a potentially destructive query without --allow-write')
			exit(2)
		}
		mut args := ['-header', '-column']
		if !allow_write {
			args << '-readonly'
		}
		args << db_path
		args << query
		res := system.exec_safe('sqlite3', args)
		if res.exit_code != 0 {
			eprintln('❌ Query failed:\n${res.output.trim_space()}')
			exit(1)
		}
		println(res.output.trim_space())
		return
	}

	println(fp.usage())
}
