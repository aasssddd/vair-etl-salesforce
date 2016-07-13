# ftp.coffee
Client = require('ssh2').Client
Logger = require('vair_log').Logger
MySQL = require '../mysql/mysql'
csv = require 'csv-write-stream'
fs = require 'graceful-fs'
path = require 'path'

class SalesforceFTP
	constructor: (dbOpts, option, logger) ->
		@log = logger ? Logger.getLogger()
		@config = 
			host: option.host ? "localhost"
			port: option.port ? 21
			user: option.user ? "guest"
			password: option.password ? ""
			secure: option.secure ? false
			pasvTimeout: option.pasvTimeout ? 20000
			keepalive: option.keepalive ? 20000
		@db = new MySQL dbOpts, @log

	uploadUserAccount: (param, sql, callback) ->
		log = @log 
		db = @db
		config = @config
		log.info "starting query user account from db"
		payload = 
			targetPath: param.targetPath
			fileName: param.fileName
			csvHeader: param.csvHeader
		header = "#{payload.csvHeader}\r\n"
		client = new Client()
		client.on 'banner', (message, language) ->
			log.info "welcome message: #{message}"
		client.on 'end', () ->
			log.info "socket closed"
			callback null
		client.on 'error', (err) ->
			log.error "upload file error: #{err}"
		client.on 'ready', () ->
			client.sftp (err, sftp) ->
				if err?
					log.error "connect fail: #{err}"
					return callback err
				log.info "preparing temp file"
				# writeStream = sftp.createWriteStream path.join payload.targetPath, payload.fileName
				writeStream = fs.createWriteStream param.fileName
				# Write header
				writeStream.write header, (err) ->
					if err?
						log.error "write csv header failed"
						return client.end()
					log.info "header written"

					db.processUserAccountStream sql, (err, readStream) ->
						if err?
							log.error "query db fail! #{err}"
							return client.end()
						
						readStream.on 'data', (data) ->
							row = "#{data.account},#{data.email},#{data.natioinality},#{data.language},#{data.firstName},#{data.lastName},#{data.gender},#{data.birthday},#{data.passportExpDay},#{data.mobileNo},#{data.contactType}\r\n"
							log.debug "writing data #{data}"
							writeStream.write row

						readStream.on 'conn_released', () ->
							log.info "start uploading file"
							writeStream.end()
						writeStream.on 'close', () ->
							log.info "copying file"
							fileReadStream = fs.createReadStream param.fileName
							ftpWriteStream = sftp.createWriteStream path.join payload.targetPath, payload.fileName
							ftpWriteStream.on 'error', (err) ->
								log.error "upload file error #{err}"
								ftpWriteStream.close()
								fileReadStream.close()
								return client.end()
							fileReadStream.on 'error', (err) ->
								log.error "read file error #{err}"
							ftpWriteStream.on 'finish', () ->
								log.info "upload member data successfully"
								ftpWriteStream.close()
								fileReadStream.close()
								return client.end()
							fileReadStream.pipe ftpWriteStream

		client.connect config
		
module.exports = SalesforceFTP