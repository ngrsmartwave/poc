//import poc_step7.epfl;
//import ballerina/constraint;
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
}, host = sftpHost, pollingInterval = 1,fileNamePattern=  "(.*)\\.csv"
);

service on ftpListenerCVS {

    // remote function onFileText(string content, ftp:FileInfo fileInfo, ftp:Caller caller) returns error? {
    //     report.startTime = time:utcToString(time:utcNow());
    //     string headerRow = "id;nom;prenom;email;sexe;datenaissance;employeur;fonction;pays;statut";
    //     log:printInfo(string `File  : ${fileInfo.pathDecoded} `);
    //     do {
    //         check caller->rename(fileInfo.pathDecoded, fileInfo.pathDecoded + ".bak");
    //     } on fail error e {
    //         log:printError(string `Error renaming file : ${fileInfo.pathDecoded + ".bak"} cause : ${e.toString()} `);
    //     }
    //     string[] rows = re `\r\n`.split(content).slice(1);
    //     report.totalCsvRows = rows.length();
    //     foreach string row in rows {
    //         log:printInfo(string `CSV Student  : ${row} `);
    //         do {
    //             Student[] csvRecords = check csv:parseString(headerRow + "\n" + row, {delimiter: ";"});
    //             log:printInfo(string `Parsed Records  : ${csvRecords.toString()} `);
    //             check functionStudentStep6(csvRecords[0]);
    //         } on fail error e {
    //             report.invalidRows += 1;
    //             log:printError(string `Error processing student  : ${row} ${e.toString()} `);
    //         }
    //     }
    //     report.endTime = time:utcToString(time:utcNow());
    //     check sendEmailNotification();
    // }
    remote function onFile(byte[] content, ftp:FileInfo fileInfo, ftp:Caller caller) returns error? {
        string csvContent = check string:fromBytes(content);
        // Remove UTF-8 BOM if present
        if csvContent.startsWith("\u{FEFF}") {
            csvContent = csvContent.substring(1);
        }
        report.startTime = time:utcToString(time:utcNow());
        //string headerRow = "id;nom;prenom;email;sexe;datenaissance;employeur;fonction;pays;statut";
        log:printInfo(string `File  : ${fileInfo.pathDecoded} `);
        do {
            check caller->rename(fileInfo.pathDecoded, fileInfo.pathDecoded + ".bak");
        } on fail error e {
            log:printError(string `Error renaming file : ${fileInfo.pathDecoded + ".bak"} cause : ${e.toString()} `);
        }
        string[] rows = re `\r\n`.split(csvContent).slice(1);
        report.totalCsvRows = rows.length();
        foreach string row in rows {
            log:printInfo(string `CSV Student  : ${row} `);
            string[] csvRecords = re `;`.split(row);
            do {
                Student student = {
                         Id: check int:fromString(csvRecords[0]),
                         Nom:csvRecords[1],
                         Prenom:csvRecords[2],
                         Email:csvRecords[3],
                         Sexe:csvRecords[4],
                         DateNaissance:csvRecords[5],
                         Employeur:csvRecords[6],
                         Fonction:csvRecords[7],
                         Pays:csvRecords[8],
                         Statut:csvRecords[9]
                };
                log:printInfo(string `Parsed Records  : ${student.toString()} `);
                check functionStudentStep6(student);
            } on fail error e {
                report.invalidRows += 1;
                log:printError(string `Error processing student  : ${row} ${e.toString()} `);
            }
        }
        report.endTime = time:utcToString(time:utcNow());
        check sendEmailNotification();
    }
}
