import ballerina/ftp;

final ftp:Client secondSourceftpClient = check new ({
    protocol: ftp:SFTP,
    host: sftpHost,
    port: 22,
    auth: {
        credentials: {username: sftpUser},
        privateKey: {
            path: sftpPrivateKeyPath
        }
    }
});
