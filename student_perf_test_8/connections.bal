import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/ftp;
import ballerina/log;

// MySQL Client - created on demand to avoid stale connection errors
function getMysqlClient() returns mysql:Client|error {
    return new (
        host = mysqlHost,
        port = mysqlPort,
        user = mysqlUser,
        password = mysqlPassword,
        database = mysqlDatabase
    );
}

// SFTP Client for downloading files
function getSftpClient() returns ftp:Client|error {
    ftp:Client|error clientsftp = new ({
        protocol: ftp:SFTP,
        host: sftpHost,
        port: sftpPort,
        auth: {
            privateKey: {
                path: sftpPrivateKeyPath
            },
            credentials: {
                username: sftpUser,
                password: ""
            }
        }
    });

    if clientsftp is error {
        log:printError(string `SFTP connection failed: ${clientsftp.message()}`);
        log:printError(string `Stack trace: ${clientsftp.stackTrace().toString()}`);
        return clientsftp;
    }
    return clientsftp;
}
