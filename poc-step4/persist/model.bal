import ballerina/persist as _;
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
    boolean? actif;
|};

