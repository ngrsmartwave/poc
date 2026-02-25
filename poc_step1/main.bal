//import poc_step_1.epfl;
//import ballerina/constraint;


import ballerina/data.csv;
import ballerina/ftp;
import ballerina/log;

listener ftp:Listener ftpListenerCVS = new (protocol = ftp:SFTP, path = "/home/ec2-user/csv", port = 22, auth = {

    credentials: {
        username: "ec2-user",
        password: ""
    },
    privateKey: {
        path: "/Users/nicolasgruszczynska/Downloads/gru-keykey.pem"
    }
}, host = "52.213.30.15", pollingInterval = 1, csvFailSafe = {
    contentType: "RAW_AND_METADATA"
}
);

service on ftpListenerCVS {
    @ftp:FunctionConfig {
        fileNamePattern: ".*\\.csv"
    }
    remote function onFileCsv(string[][] students, ftp:FileInfo fileInfo, ftp:Caller caller) returns error? {

        string[] header = ["id", "nom", "prenom", "email", "actif"];
        log:printInfo(string `==== New File  : ${fileInfo.pathDecoded} ====`);
        check caller->rename(fileInfo.pathDecoded,fileInfo.pathDecoded+".bak");
        foreach string[] student in students {
            string[][] studentArray = [student];
            log:printInfo(string `==== New Student  : ${student.toString()} ====`);
            do {
                Student[] csvRecords = check csv:parseList(studentArray, {customHeaders: header});
                log:printInfo(string `==== Parsed Records  : ${csvRecords.toString()} ====`);
                Student csvStudent = csvRecords[0];
                check functionStudent(csvStudent);
            } on fail error e {
                log:printError(string `==== Error processing student  : ${studentArray.toString()} ${e.toString()} ====`);
            }
        }
        //check caller->delete(fileInfo.pathDecoded+".bak");
    }
}
