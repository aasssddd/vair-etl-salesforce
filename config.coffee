# config.coffee
module.exports = 
	mysql:
		host: "mysql host"
		user: "user name"
		password: "password"
		database: "database"
		poolSize: 1
		waitForConnection: true
		acquireTimeout: 600000
	ftp:
		host: "salesforce host"
		port: 22
		user: "user name"
		password: "password"
		# secure: true
	ftpPayload:
		targetPath: "/import"
		fileName: "members_data.csv"
		csvHeader: "account,email,natioinality,language,firstName,lastName,gender,birthday,passportExpDay,mobileNo,contactType"

	sql:
		getAccount: "SELECT 
						lower(membership.members.account) as account, 
						lower(membership.members.email) as email,
						upper(membership.nationalities.alpha2Code) as natioinality,
						upper(case
							when membership.nationalities.alpha2Code = 'TW' then 'ZH'
							when membership.nationalities.alpha2Code = 'JP' then 'JA'
							when membership.nationalities.alpha2Code = 'KR' then 'KO'
							else 'EN'
						  end
						) as language, 
						upper(membership.members.firstName) as firstName, 
						upper(membership.members.lastName) as lastName,
						upper(membership.members.gender) as gender,
						ifnull(membership.members.birthday, '1900-01-01')as birthday,
						ifnull(membership.members.passportExpDay, '3000-12-31')as passportExpDay,
						membership.members.mobileNo,
						'Member' as contactType
					FROM membership.members, membership.nationalities
					WHERE membership.members.nationalityId = membership.nationalities.id"

