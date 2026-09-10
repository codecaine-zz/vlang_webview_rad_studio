module main

import flag
import os
import system

fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('api_cli')
	fp.version('2.0.0')
	fp.description('Enterprise HTTP / REST API Client CLI')
	fp.skip_executable()

	method := fp.string('method', `X`, 'GET', 'HTTP Method (GET, POST, PUT, DELETE, PATCH)')
	body := fp.string('data', `d`, '', 'HTTP Request Body')
	content_type := fp.string('content-type', `c`, 'application/json', 'Content-Type header')
	show_headers := fp.bool('headers', `i`, false, 'Include response headers in output')

	additional_args := fp.finalize() or {
		println('Error: ${err}')
		println(fp.usage())
		return
	}

	if additional_args.len == 0 {
		eprintln('Error: Target URL required')
		println(fp.usage())
		exit(1)
	}

	url := additional_args[0]
	mut headers_map := map[string]string{}
	headers_map['Content-Type'] = content_type

	resp := system.http_request(method, url, body, headers_map)

	if show_headers {
		println('HTTP Status: ${resp.status_code}')
		for k, v in resp.headers {
			println('${k}: ${v}')
		}
		println('--------------------------------------------------------------------')
	}

	println(resp.body)
}
