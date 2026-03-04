import poc_step1.epfl;
import ballerina/log;

// Traite un étudiant issu du CSV : transforme les données puis les insère en base de données
function step1Function(Student csvEtudiant) returns error? {
    // Initialisation du client de base de données
    epfl:Client dbClient = check new epfl:Client();

    // Transformation du format CSV vers le format base de données
    epfl:EtudiantInsert epflEtudiantinsert = transformCVStoDB(csvEtudiant);

    log:printInfo(string `Creating Student  : ${epflEtudiantinsert.id} `);
    do {
        // Insertion de l'étudiant dans la table etudiants
        _ = check dbClient->/etudiants.post([epflEtudiantinsert]);
        log:printInfo(string `Student  ${epflEtudiantinsert.id} created succesfully`);
    } on fail error e {
        // En cas d'échec, on journalise l'erreur sans interrompre le traitement global
        log:printError(string `Student ${epflEtudiantinsert.id}  fails cause : ${e.toString()}`);
    }
}
