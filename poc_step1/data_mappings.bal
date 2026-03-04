import poc_step1.epfl;

function transformCVStoDB(Student csv) returns epfl:EtudiantInsert => {
    id: csv.id,
    nom: csv.nom,
    prenom: csv.prenom,
    email: csv.email,
    actif: csv.actif
};

