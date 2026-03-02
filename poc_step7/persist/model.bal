import ballerina/persist as _;
import ballerina/time;
import ballerinax/persist.sql;

@sql:Name {value: "etudiants"}
public type Etudiant record {|
    readonly int id;
    @sql:Varchar {length: 50}
    string? nom;
    @sql:Varchar {length: 50}
    string? prenom;
    @sql:Varchar {length: 100}
    string? email;
    @sql:Name {value: "date_naissance"}
    time:Date? dateNaissance;
    boolean? actif;
|};

