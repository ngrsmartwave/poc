import ballerina/persist as _;
import ballerinax/persist.sql;

// Modèle de données correspondant à la table MySQL "etudiants"
@sql:Name {value: "etudiants"}
public type Etudiant record {|
    readonly int id;               // Clé primaire — identifiant unique de l'étudiant
    @sql:Varchar {length: 50}
    string? nom;                   // Nom de famille (50 caractères max)
    @sql:Varchar {length: 50}
    string? prenom;                // Prénom (50 caractères max)
    @sql:Varchar {length: 100}
    string? email;                 // Adresse email institutionnelle (100 caractères max)
    boolean? actif;                // Statut d'activité de l'étudiant
|};
