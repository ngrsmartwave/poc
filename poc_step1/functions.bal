import poc_step1.epfl;

import ballerina/log;
import ballerina/persist;
import ballerina/email;

function functionStudentStep3(Student csvEtudiant) returns error? {
    epfl:Client dbClient = check new epfl:Client();
    epfl:EtudiantInsert epflEtudiantinsert = transformCVStoDB(csvEtudiant);
    epfl:EtudiantOptionalized|persist:Error existResult = dbClient->/etudiants/[epflEtudiantinsert.id].get();
    if existResult is persist:NotFoundError {
         log:printInfo(string `Creating Student  : ${epflEtudiantinsert.id} `);
        do{
            _ = check dbClient->/etudiants.post([epflEtudiantinsert]);
            log:printInfo(string `Student  ${epflEtudiantinsert.id} created succesfully`);
        } on fail error e {
            log:printError(string `Student ${epflEtudiantinsert.id}  fails cause : ${e.toString()}`);
        }        
    } else if existResult is persist:Error {
            log:printError(string `Read fails cause : ${existResult.toString()}`);
        return existResult;
    } else {
        if csvEtudiant.actif == true {
            epfl:EtudiantUpdate epflEtudiantUpdate = transformCVStoDBUpdate(csvEtudiant);
           log:printInfo(string `Updating Student  : ${csvEtudiant.id} `);
            do{
               _ = check dbClient->/etudiants/[csvEtudiant.id].put(epflEtudiantUpdate);
                log:printInfo(string `Student  ${csvEtudiant.id} updated succesfully`);
            } on fail error e {
                log:printError(string `Student ${csvEtudiant.id}  fails cause : ${e.toString()}`);
            }   
        } else {
             log:printInfo(string `Desactivating Student  : ${csvEtudiant.id} `);
             do{
                _ = check dbClient->executeNativeSQL(`UPDATE etudiants SET actif = 0 WHERE id = ${csvEtudiant.id}`);                
                log:printInfo(string `Student  ${csvEtudiant.id} desactivated succesfully`);
            } on fail error e {
                log:printError(string `Student ${csvEtudiant.id}  fails cause : ${e.toString()}`);
            }   
        }
    }
}


function functionStudentStep1(Student csvEtudiant) returns error? {
    epfl:Client dbClient = check new epfl:Client();
    epfl:EtudiantInsert epflEtudiantinsert = transformCVStoDB(csvEtudiant);
    log:printInfo(string `Creating Student  : ${epflEtudiantinsert.id} `);
    do{
    _ = check dbClient->/etudiants.post([epflEtudiantinsert]);
      log:printInfo(string `Student  ${epflEtudiantinsert.id} created succesfully`);
    } on fail error e {
      log:printError(string `Student ${epflEtudiantinsert.id}  fails cause : ${e.toString()}`);
    }
}


function functionStudentStep6(Student csvEtudiant) returns error? {
   report.validRows+=1;
    epfl:Client dbClient = check new epfl:Client();
    epfl:EtudiantInsert epflEtudiantinsert = transformCVStoDB(csvEtudiant);
    epfl:EtudiantOptionalized|persist:Error existResult = dbClient->/etudiants/[epflEtudiantinsert.id].get();
    if existResult is persist:NotFoundError {
         log:printInfo(string `Creating Student  : ${epflEtudiantinsert.id} `);
        do{
            _ = check dbClient->/etudiants.post([epflEtudiantinsert]);
            log:printInfo(string `Student  ${epflEtudiantinsert.id} created succesfully`);
            report.insertions+=1;
        } on fail error e {
            report.errors+=1;
            log:printError(string `Student ${epflEtudiantinsert.id}  fails cause : ${e.toString()}`);
        }        
    } else if existResult is persist:Error {
            report.errors+=1;
            log:printError(string `Read fails cause : ${existResult.toString()}`);
        return existResult;
    } else {
        if csvEtudiant.actif == true {
            epfl:EtudiantUpdate epflEtudiantUpdate = transformCVStoDBUpdate(csvEtudiant);
           log:printInfo(string `Updating Student  : ${csvEtudiant.id} `);
            do{
               _ = check dbClient->/etudiants/[csvEtudiant.id].put(epflEtudiantUpdate);
               report.updates+=1;
                log:printInfo(string `Student  ${csvEtudiant.id} updated succesfully`);
            } on fail error e {
                report.errors+=1;
                log:printError(string `Student ${csvEtudiant.id}  fails cause : ${e.toString()}`);
            }   
        } else {
             log:printInfo(string `Desactivating Student  : ${csvEtudiant.id} `);
             do{
                _ = check dbClient->executeNativeSQL(`UPDATE etudiants SET actif = 0 WHERE id = ${csvEtudiant.id}`);          
                report.deactivations+=1;      
                log:printInfo(string `Student  ${csvEtudiant.id} desactivated succesfully`);
            } on fail error e {
                report.errors+=1;
                log:printError(string `Student ${csvEtudiant.id}  fails cause : ${e.toString()}`);
            }   
        }
    }
}


function generateReport() returns string {
    return string `
====================================================
     STUDENT DATA SYNC - PROCESSING REPORT
====================================================
  Start Time    : ${report.startTime}
  End Time      : ${report.endTime}
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