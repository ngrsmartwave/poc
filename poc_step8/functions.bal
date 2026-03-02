import poc_step7.epfl;

import ballerina/log;
import ballerina/email;
import ballerina/time;


function functionStudentStep1(Student[] students) returns error? {
    epfl:Client dbClient = check new epfl:Client();
    epfl:EtudiantInsert[] inserts = from Student s in students select transformCVStoDB(s);
    do {
        _ = check dbClient->/etudiants.post(inserts);
        report.insertions += inserts.length();
        log:printInfo(string `Batch of ${inserts.length()} students inserted`);
    } on fail error e {
        report.errors += inserts.length();
        log:printError(string `Batch insert failed : ${e.toString()}`);
    }
}


function generateReport() returns string {
    decimal processingSeconds = 0d;
    time:Utc|error startUtc = time:utcFromString(report.startTime);
    time:Utc|error endUtc = time:utcFromString(report.endTime);
    if startUtc is time:Utc && endUtc is time:Utc {
        processingSeconds = time:utcDiffSeconds(endUtc, startUtc);
    }
    return string `
====================================================
     STUDENT DATA SYNC - PROCESSING REPORT
====================================================
  Start Time     : ${report.startTime}
  End Time       : ${report.endTime}
  Process Time   : ${processingSeconds} 
----------------------------------------------------
  CSV PROCESSING
  Total CSV Rows : ${report.totalCsvRows}
  Valid Rows     : ${report.validRows}
  Invalid Rows   : ${report.invalidRows}
----------------------------------------------------
  DATABASE OPERATIONS
  Insertions     : ${report.insertions}
  Updates        : ${report.updates}
  Deactivations  : ${report.deactivations}
  Errors         : ${report.errors}
----------------------------------------------------
  Status: ${report.errors == 0 ? "SUCCESS" : "COMPLETED WITH ERRORS"}
====================================================`;
}

function sendEmailNotification() returns error? {
    string report =generateReport();

    email:SmtpClient smtp = check new (
        host = smtpHost, username = smtpUser, password = smtpPassword,
        clientConfig = {port: smtpPort, security: email:START_TLS_AUTO}
    );

    check smtp->sendMessage({
        to: recipientEmail,
        subject: "EPFL Student Sync - Processing Report",
        'from: smtpUser,
        body: report
    });
    log:printInfo(string `Email sent to ${recipientEmail}`);
}
