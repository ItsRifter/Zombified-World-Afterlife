GM.MYSQL = {}
GM.MYSQL.Data = {}

GM.MYSQL.Data.Type = "mysql" --Usable types: mysql | txt (expect txt to cause issues)

if GM.MYSQL.Data.Type == "mysql" then
	GM.MYSQL.Data.Host = "127.0.0.1" --IP to the server running your myMYSQL server (use 127.0.0.1 to connect to a server running on the same machine)
	GM.MYSQL.Data.Port = 3306 --Port the myMYSQL server is listening on, 3306 is the myMYSQL default
	GM.MYSQL.Data.Database = "zwrtest"  --Name of the database you have created on your myMYSQL server
	GM.MYSQL.Data.Username = "root" --Name of the user you have created on your myMYSQL server
	GM.MYSQL.Data.Password = "" --Password for the user you created
	GM.MYSQL.Data.MYSQLSnapshotInterval = 5 * 60
end