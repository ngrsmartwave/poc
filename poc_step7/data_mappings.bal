import poc_step7.epfl;

function transformCVStoDB(Student csv) returns epfl:EtudiantInsert => {
    id: csv.id,
    nom: csv.nom,
    prenom: csv.prenom,
    email: csv.email,
    actif: csv.actif,
    dateNaissance: dateNaissanceById[csv.id.toString()]
};

function transformCVStoDBUpdate(Student csv) returns epfl:EtudiantUpdate=> {
    nom: csv.nom,
    prenom: csv.prenom,
    email: csv.email,
    actif: true
    //dateNaissance: csv.datenaissance
};

