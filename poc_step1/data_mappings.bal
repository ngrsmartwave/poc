import poc_step1.epfl;

// Transforme un enregistrement Student (issu du CSV) en EtudiantInsert (format base de données)
function transformCVStoDB(Student csv) returns epfl:EtudiantInsert => {
    id: csv.id,
    nom: csv.nom,
    prenom: csv.prenom,
    email: csv.email,
    actif: csv.actif
};
