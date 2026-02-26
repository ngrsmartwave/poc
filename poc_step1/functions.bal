import poc_step1.epfl;

import ballerina/log;
import ballerina/persist;

function functionStudentStep3(Student csvEtudiant) returns error? {
    epfl:Client dbClient = check new epfl:Client();
    epfl:EtudiantInsert epflEtudiantinsert = transformCVStoDB(csvEtudiant);
    epfl:EtudiantOptionalized|persist:Error existResult = dbClient->/etudiants/[epflEtudiantinsert.id].get();
    if existResult is persist:NotFoundError {
        _ = check dbClient->/etudiants.post([epflEtudiantinsert]);
        log:printInfo(string `Creating Student  : ${epflEtudiantinsert.id} `);
    } else if existResult is persist:Error {
        return existResult;
    } else {
        if csvEtudiant.actif == true {
            epfl:EtudiantUpdate epflEtudiantUpdate = transformCVStoDBUpdate(csvEtudiant);
            _ = check dbClient->/etudiants/[csvEtudiant.id].put(epflEtudiantUpdate);
            log:printInfo(string `Updating Student  : ${csvEtudiant.id} `);
        } else {
            _ = check dbClient->executeNativeSQL(`UPDATE etudiants SET actif = 0 WHERE id = ${csvEtudiant.id}`);
            log:printInfo(string `Deactivating Student  : ${csvEtudiant.id} `);
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
