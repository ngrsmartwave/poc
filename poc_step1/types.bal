import ballerina/constraint;
import ballerina/log;

// Représente un étudiant tel que lu depuis le fichier CSV
type Student record {|
    int id;       // Identifiant unique de l'étudiant
    string nom;
    @log:Sensitive {
       strategy: {
            replacement: "****"  // Le prénom est masqué dans les logs
        }
    }
    string prenom;
    @constraint:String {
        pattern: re`^.*@epfl.ch$`  // L'email doit appartenir au domaine @epfl.ch
    }
    string email;
    boolean actif; // Indique si l'étudiant est actif
|};

// Rapport de traitement d'un fichier CSV : statistiques d'insertion, mise à jour et erreurs
type ProcessingReport record {|
    int totalCsvRows;   // Nombre total de lignes dans le fichier CSV
    int validRows;      // Lignes valides (format correct)
    int invalidRows;    // Lignes invalides (format incorrect)
    int insertions;     // Nouveaux étudiants insérés en base
    int updates;        // Étudiants mis à jour
    int deactivations;  // Étudiants désactivés
    int errors;         // Erreurs rencontrées lors du traitement
    string startTime;   // Horodatage de début de traitement
    string endTime;     // Horodatage de fin de traitement
|};
