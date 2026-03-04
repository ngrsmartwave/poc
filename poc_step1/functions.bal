import poc_step1.epfl;
import ballerina/log;


function step1Function(Student csvEtudiant) returns error? {
    epfl:Client dbClient = check new epfl:Client();
    epfl:EtudiantInsert epflEtudiantinsert = transformCVStoDB(csvEtudiant);
    log:printInfo(string `Creating Student  : ${epflEtudiantinsert.id} `);
    do {
        _ = check dbClient->/etudiants.post([epflEtudiantinsert]);
        log:printInfo(string `Student  ${epflEtudiantinsert.id} created succesfully`);
    } on fail error e {
        log:printError(string `Student ${epflEtudiantinsert.id}  fails cause : ${e.toString()}`);
    }
}