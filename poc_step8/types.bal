import ballerina/constraint;
type Student record {|
    int Id;
    string Nom;
    string Prenom;
    @constraint:String {
        pattern: re`^.*@epfl.ch$`
    }
    string Email;
    string Sexe;
    string DateNaissance;
    string Employeur;
    string Fonction;
    string Pays;
    string Statut;
|};

type StudentDateNaissance record {|
    int id;
    string nom;
    string prenom;
    @constraint:String {
        pattern: re`^.*@epfl.ch$`
    }
    string email;
    string? datenaissance;
    boolean actif;
|};

type ProcessingReport record {|
    int totalCsvRows;
    int validRows;
    int invalidRows;
    int insertions;
    int updates;
    int deactivations;
    int errors;
    string startTime;
    string endTime;
|};
