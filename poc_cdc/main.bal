import ballerina/log;
import ballerinax/cdc;
import ballerinax/mysql;
import ballerinax/mysql.cdc.driver as _;
import ballerinax/rabbitmq;

configurable string username = ?;
configurable string password = ?;
configurable string rabbitUsername = ?;
configurable string rabbitPassword = ?;

const string RABBITMQ_HOST = "52.213.30.15";
const int RABBITMQ_PORT = 5672;
const string CDC_QUEUE = "cdc.etudiants";

type Etudiants record {|
    int id;
    string? nom;
    string? prenom;
    string? email;
    int? actif;
|};

final rabbitmq:Client rabbitmqClient;

function init() returns error? {
    rabbitmqClient = check new (RABBITMQ_HOST, RABBITMQ_PORT,username = rabbitUsername,password = rabbitPassword);
    check rabbitmqClient->queueDeclare(CDC_QUEUE);
    log:printInfo(`RabbitMQ connecté sur ${RABBITMQ_HOST}:${RABBITMQ_PORT}, queue: ${CDC_QUEUE}`);
}

listener mysql:CdcListener studentDBListener = new (
    database = {
        username,
        password,
        hostname: "52.213.30.15",
        includedDatabases: "EPFL",
        includedTables: "EPFL.etudiants"
    },
    options = {
        snapshotMode: cdc:NO_DATA,
        skippedOperations: [cdc:TRUNCATE, cdc:DELETE]
    }
);

service cdc:Service on studentDBListener {
    remote function onCreate(Etudiants etu) returns error? {
        log:printInfo(`Etudiant créé avec id: ${etu.id}`);
        json payload = {
            event: "CREATE",
            data: {id: etu.id, nom: etu.nom, prenom: etu.prenom, email: etu.email, actif: etu.actif}
        };
        check rabbitmqClient->publishMessage({
            content: payload.toJsonString(),
            routingKey: CDC_QUEUE
        });
    }

    remote function onUpdate(Etudiants before, Etudiants after) returns error? {
        log:printInfo(`Etudiant mis à jour: ${after.toString()}`);
        json payload = {
            event: "UPDATE",
            before: {id: before.id, nom: before.nom, prenom: before.prenom, email: before.email, actif: before.actif},
            after: {id: after.id, nom: after.nom, prenom: after.prenom, email: after.email, actif: after.actif}
        };
        check rabbitmqClient->publishMessage({
            content: payload.toJsonString(),
            routingKey: CDC_QUEUE
        });
    }

    remote function onError(cdc:Error e) {
        log:printError("CDC error occurred", e);
    }
}
