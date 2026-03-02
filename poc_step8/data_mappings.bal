import poc_step7.epfl;

function transformCVStoDB(Student csv) returns epfl:EtudiantInsert => {
    id: csv.Id,
    nom: csv.Nom,
    prenom: csv.Prenom,
    email: csv.Email,
    actif: (csv.Statut=="TRUE"),
    dateNaissance: ()
};

function transformCVStoDBUpdate(Student csv) returns epfl:EtudiantUpdate=> {
    nom: csv.Nom,
    prenom: csv.Prenom,
    email: csv.Email,
    actif: true
};




