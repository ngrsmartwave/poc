import ballerina/constraint;
import ballerina/log;
type Student record {|
    int id;
    string nom;
    @log:Sensitive {
       strategy: {
            replacement: "****"
        }
    }
    string prenom;
    @constraint:String {
        pattern: re`^.*@epfl.ch$`
    }
    string email;
    boolean actif;
|};