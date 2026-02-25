import poc_step_1.epfl;

function transformCVStoDB(Student csv) returns epfl:EtudiantInsert => {
    id: csv.id,
    nom: csv.nom,
    prenom: csv.prenom,
    email: csv.email,
    actif: csv.actif
};

function transformCVStoDBUpdate(Student csv) returns epfl:EtudiantUpdate=> {
    nom: csv.nom,
    prenom: csv.prenom,
    email: csv.email,
    actif: true
};

