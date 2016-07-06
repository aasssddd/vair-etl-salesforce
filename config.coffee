# config.coffee
module.exports = 
	mysql:
		host: "ibe-read.ctiobqdwe6ok.us-west-2.rds.amazonaws.com"
		user: "vairibe"
		password: "VairRDSIBE"
		database: "membership"
		poolSize: 1
		waitForConnection: true
		acquireTimeout: 600000
	ftp:
		host: "ftp.s7.exacttarget.com"
		port: 22
		user: "7277374"
		password: "Flyv@ir.c0m!"
		# secure: true
	ftpPayload:
		targetPath: "/import"
		fileName: "members_data.csv"


	sql:
		getAccount: "SELECT LOWER(membership.members.account) AS account, LOWER(membership.members.email) AS email, UPPER(membership.nationalities.alpha2Code) AS natioinality, UPPER(membership.members.firstName) AS firstName, UPPER(membership.members.lastName) AS lastName, UPPER(membership.members.gender) AS gender, IFNULL(membership.members.birthday, '1900-01-01') AS birthday, IFNULL(membership.members.passportExpDay, '3000-12-31') AS passportExpDay,
					membership.members.nationalityId,
					membership.members.mobileNo,
					'Member' AS contactType
					FROM membership.members, membership.nationalities
					WHERE membership.members.nationalityId = membership.nationalities.id"

