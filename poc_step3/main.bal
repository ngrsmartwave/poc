import ballerina/data.csv;
import ballerina/ftp;
import ballerina/log;
import ballerina/time;


listener ftp:Listener ftpListenerCVS = new (protocol = ftp:SFTP, path = "/home/ec2-user/csv", port = 22, auth = {

    credentials: {
        username: sftpUser,
        password: ""
    },
    privateKey: {
        path: sftpPrivateKeyPath
    }
}, host = sftpHost, pollingInterval = 10, csvFailSafe = {
    contentType: "RAW_AND_METADATA"
}
);

service on ftpListenerCVS {
    @ftp:FunctionConfig {
        fileNamePattern: ".*\\.csv"
    }
    remote function onFileCsv(string[][] students, ftp:FileInfo fileInfo, ftp:Caller caller) returns error? {
        time:Utc startTime = time:utcNow();
        string[] header = ["id", "nom", "prenom", "email", "actif"];
        log:printInfo(string `File  : ${fileInfo.pathDecoded} `);
        do {
            check caller->rename(fileInfo.pathDecoded, fileInfo.pathDecoded + ".bak");
        } on fail error e {
            log:printError(string `Error renaming file : ${fileInfo.pathDecoded + ".bak"} cause : ${e.toString()} `);
        }
        foreach string[] student in students {
            string[][] studentArray = [student];
            log:printInfo(string `CSV Student  : ${student.toString()} `);
            do {
                Student[] csvRecords = check csv:parseList(studentArray, {customHeaders: header});
                log:printInfo(string `Parsed Records  : ${csvRecords.toString()} `);
                Student csvStudent = csvRecords[0];
                check step3Function(csvStudent);

            } on fail error e {
                log:printError(string `Error processing student  : ${studentArray.toString()} ${e.toString()} `);
            }
        }
        time:Seconds duration = time:utcDiffSeconds(time:utcNow(),startTime);
        log:printInfo(string `duration  : ${duration.toString()} sec`);
    }
}
