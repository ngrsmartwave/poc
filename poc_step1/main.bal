//import poc_step1.epfl;
//import ballerina/constraint;


import ballerina/data.csv;
import ballerina/ftp;
import ballerina/log;

listener ftp:Listener ftpListenerCVS = new (protocol = ftp:SFTP, path = "/home/ec2-user/csv", port = 22, auth = {

    credentials: {
        username: sftpUser,
        password: ""
    },
    privateKey: {   
        path: sftpPrivateKeyPath
    }
}, host = sftpHost, pollingInterval = 1, csvFailSafe = {
    contentType: "RAW_AND_METADATA"
}
);

service on ftpListenerCVS {
    @ftp:FunctionConfig {
        fileNamePattern: ".*\\.csv"
    }
    remote function onFileCsv(string[][] students, ftp:FileInfo fileInfo, ftp:Caller caller) returns error? {

        string[] header = ["id", "nom", "prenom", "email", "actif"];
        log:printInfo(string `File  : ${fileInfo.pathDecoded} `);
        check caller->rename(fileInfo.pathDecoded,fileInfo.pathDecoded+".bak");
        foreach string[] student in students {
            string[][] studentArray = [student];
            log:printInfo(string `CSV Student  : ${student.toString()} `);
            do {
                Student[] csvRecords = check csv:parseList(studentArray, {customHeaders: header});
                log:printInfo(string `Parsed Records  : ${csvRecords.toString()} `);
                Student csvStudent = csvRecords[0];
                check functionStudentStep1(csvStudent);
            } on fail error e {
                log:printError(string `Error processing student  : ${studentArray.toString()} ${e.toString()} `);
            }
        }
    }
}
