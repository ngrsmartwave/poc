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