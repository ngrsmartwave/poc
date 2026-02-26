import poc_step1.epfl;

import ballerina/log;
import ballerina/persist;

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
