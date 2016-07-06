# mysql.coffee
Logger = require('vair_log').Logger
mysql = require 'mysql'
class MySQL 
	constructor: (config, logger) ->
		@log = logger ? Logger.getLogger()
		log = @log
		@pool = mysql.createPool {
			host: config.host ? "localhost"
			user: config.user ? "root"
			password: config.password ? "P@ssw0rd"
			database: config.database ? "default"
			connectionLimit: mysql.poolSize ? 1
			waitForConnection: mysql.waitForConnection ? true
			acquireTimeout: config.acquireTimeout ? 600000
		}

		@pool.on 'enqueue', () ->
			log.debug "waiting for available connection slot"

		@pool.on 'connection', () ->
			log.debug "connection created"

	processUserAccount: (sql, processRow, callback) ->
		strSql = sql
		log = @log
		
		@pool.getConnection (err, conn) ->
			if err?
				log.error "get connection failed! #{err}"
				return callback err
			log.debug "Query: #{strSql}"
			result = conn.query strSql
			result.on 'result', (data) ->
				log.debug "data: #{JSON.stringify data}"
				conn.pause()
				processRow data
				conn.resume()
			.on 'end', () ->
				log.info "query data consumed"
				conn.release()
				callback null
			.on 'error', (err) ->
				log.error "pipe data failed: #{err}"
				conn.release()
				callback err
			
	close: () ->
		@pool.end()

module.exports = MySQL
