//import poc_step1.epfl;
//import ballerina/constraint;

import ballerina/data.csv;
import ballerina/ftp;
import ballerina/log;
import ballerina/time;

// Écouteur SFTP : surveille le répertoire /home/ec2-user/csv/step1 toutes les 10 secondes
// et détecte les nouveaux fichiers CSV déposés
listener ftp:Listener ftpListenerCVS = new (protocol = ftp:SFTP, path = "/home/ec2-user/csv/step1", port = 22, auth = {

    credentials: {
        username: sftpUser,
        password: ""
    },
    privateKey: {
        path: sftpPrivateKeyPath  // Authentification par clé privée SSH
    }
}, host = sftpHost, pollingInterval = 10, csvFailSafe = {
    contentType: "RAW_AND_METADATA"  // Conserve les métadonnées en cas d'échec
}
);

// Service déclenché à la réception d'un fichier CSV sur le serveur SFTP
service on ftpListenerCVS {
    @ftp:FunctionConfig {
        fileNamePattern: ".*\\.csv"  // Filtre : uniquement les fichiers .csv
    }
    remote function onFileCsv(string[][] students, ftp:FileInfo fileInfo, ftp:Caller caller) returns error? {
        time:Utc startTime = time:utcNow();
        // En-têtes attendus dans le fichier CSV (ordre des colonnes)
        string[] header = ["id", "nom", "prenom", "email", "actif"];
        log:printInfo(string `File  : ${fileInfo.pathDecoded} `);

        // Renommage du fichier en .bak pour éviter un double traitement
        do {
            check caller->rename(fileInfo.pathDecoded, fileInfo.pathDecoded + ".bak");
        } on fail error e {
            log:printError(string `Error renaming file : ${fileInfo.pathDecoded + ".bak"} cause : ${e.toString()} `);
        }

        // Traitement ligne par ligne du fichier CSV
        foreach string[] student in students {
            string[][] studentArray = [student];
            log:printInfo(string `CSV Student  : ${student.toString()} `);
            do {
                // Désérialisation de la ligne CSV en enregistrement Student
                Student[] csvRecords = check csv:parseList(studentArray, {customHeaders: header});
                log:printInfo(string `Parsed Records  : ${csvRecords.toString()} `);
                Student csvStudent = csvRecords[0];

                // Appel de la fonction métier pour insérer l'étudiant en base
                check step1Function(csvStudent);

            } on fail error e {
                // Erreur isolée par étudiant — le traitement continue pour les lignes suivantes
                log:printError(string `Error processing student  : ${studentArray.toString()} ${e.toString()} `);
            }
        }

        // Journalisation de la durée totale de traitement du fichier
        time:Seconds duration = time:utcDiffSeconds(time:utcNow(), startTime);
        log:printInfo(string `duration  : ${duration.toString()} sec`);
    }
}
