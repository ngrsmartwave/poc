import ballerina/constraint;
type Student record {|
    int id;
    string nom;
    string prenom;
    @constraint:String {
        pattern: re`^.*@epfl.ch$`
    }
    string email;
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
