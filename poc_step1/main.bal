//import poc_step1.epfl;
//import ballerina/constraint;

import ballerina/data.csv;
import ballerina/ftp;
import ballerina/log;
import ballerina/time;

ProcessingReport report = {insertions: 0, validRows: 0, deactivations: 0, totalCsvRows: 0, startTime: "", endTime: "", updates: 0, errors: 0, invalidRows: 0};

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
        report.startTime = time:utcToString(startTime);
        string[] header = ["id", "nom", "prenom", "email", "actif"];
        log:printInfo(string `File  : ${fileInfo.pathDecoded} `);
        do {
            check caller->rename(fileInfo.pathDecoded, fileInfo.pathDecoded + ".bak");
        } on fail error e {
            log:printError(string `Error renaming file : ${fileInfo.pathDecoded + ".bak"} cause : ${e.toString()} `);
        }
        report.totalCsvRows = students[0].length();
        foreach string[] student in students {
            string[][] studentArray = [student];
            log:printInfo(string `CSV Student  : ${student.toString()} `);
            do {
                Student[] csvRecords = check csv:parseList(studentArray, {customHeaders: header});
                log:printInfo(string `Parsed Records  : ${csvRecords.toString()} `);
                Student csvStudent = csvRecords[0];
                check step1Function(csvStudent);

            } on fail error e {
                report.invalidRows += 1;
                log:printError(string `Error processing student  : ${studentArray.toString()} ${e.toString()} `);
            }
        }
        time:Seconds duration = time:utcDiffSeconds(time:utcNow(),startTime);
        log:printInfo(string `duration  : ${duration.toString()} sec`);
        report.endTime = time:utcToString(time:utcNow());
        //check sendEmailNotification(); 
    }
}
