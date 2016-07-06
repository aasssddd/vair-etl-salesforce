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
		header = "account,email,natioinality,firstName,lastName,gender,birthday,passportExpDay,nationalityId,mobileNo,contactType\r\n"
		client = new Client()
		log.info "starting uploading file"
		client.on 'banner', (message, language) ->
			log.info "welcome message: #{message}, language: #{language}"
		client.on 'end', () ->
			log.info "socket closed"
		client.on 'error', (err) ->
			log.error "upload file error: #{err}"
		client.on 'ready', () ->
			client.sftp (err, sftp) ->
				if err?
					log.error "connect fail: #{err}"
					return callback err
				
				writeStream = sftp.createWriteStream path.join payload.targetPath, payload.fileName
				# Write header
				writeStream.write header, ->
					log.info "header written"
					db.processUserAccount sql, (data, cb) ->
						row = "#{data.account},#{data.email},#{data.natioinality},#{data.firstName},#{data.lastName},#{data.gender},#{data.birthday},#{data.passportExpDay},#{data.nationalityId},#{data.mobileNo},#{data.contactType}\r\n"
						log.debug "writing data #{data}"
						writeStream.write row, ->
							cb null
				, (err) ->
					writeStream.close()
					if err?
						log.error "upload file to salesforce ftp fail: #{err}"
						return callback err
					callback null

		client.connect config
		

module.exports = SalesforceFTP