# index.coffee
SalesforceFTP = require './ftp/ftp'
config = require './config'
Logger = require('vair_log').Logger

log = Logger.getLogger()
ftp = new SalesforceFTP config.mysql, config.ftp, log

ftp.uploadUserAccount config.ftpPayload, config.sql.getAccount, (err) ->
	if err?
		log.error "#{err}"
	else 
		log.info "complete"
	process.exit()
