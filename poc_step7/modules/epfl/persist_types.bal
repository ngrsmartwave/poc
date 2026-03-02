// AUTO-GENERATED FILE. DO NOT MODIFY.

// This file is an auto-generated file by Ballerina persistence layer for model.
// It should not be modified by hand.

import ballerina/time;

public type Etudiant record {|
    readonly int id;
    string? nom;
    string? prenom;
    string? email;
    time:Date? dateNaissance;
    boolean? actif;
|};

public type EtudiantOptionalized record {|
    int id?;
    string? nom?;
    string? prenom?;
    string? email?;
    time:Date? dateNaissance?;
    boolean? actif?;
|};

public type EtudiantTargetType typedesc<EtudiantOptionalized>;

public type EtudiantInsert Etudiant;

public type EtudiantUpdate record {|
    string? nom?;
    string? prenom?;
    string? email?;
    time:Date? dateNaissance?;
    boolean? actif?;
|};

