import ballerina/log;
import ballerina/data.csv;
import ballerina/sql;
import ballerina/time;
import ballerina/ftp;
import ballerina/email;

function downloadFile(string filePath) returns byte[]|error {
    ftp:Client sftpClient = check getSftpClient();
    log:printInfo(string `Downloading: ${filePath}`);
    string content = check sftpClient->getText(filePath);
    byte[] fileContent = content.toBytes();
    log:printInfo(string `Downloaded ${fileContent.length()} bytes`);
    check sftpClient->rename(filePath,filePath+".bak");
    return fileContent;
}

function convertDateFormat(string dateStr) returns string|error {
    string[] parts = [];
    if dateStr.includes("/") {
        parts = re `/`.split(dateStr);
    } else if dateStr.includes(".") {
        parts = re `\.`.split(dateStr);
    } else {
        return error(string `Unknown date format: ${dateStr}`);
    }

    if parts.length() != 3 {
        return error(string `Invalid date: ${dateStr}`);
    }

    string day = parts[0].trim();
    string month = parts[1].trim();
    string year = parts[2].trim();

    if day.length() == 1 { day = string `0${day}`; }
    if month.length() == 1 { month = string `0${month}`; }

    int|error m = int:fromString(month);
    int|error d = int:fromString(day);
    if m is int && (m < 1 || m > 12) {
        return error(string `Invalid month in date: ${dateStr}`);
    }
    if d is int && (d < 1 || d > 31) {
        return error(string `Invalid day in date: ${dateStr}`);
    }

    return string `${year}-${month}-${day}`;
}

function parseAlumniCsv(byte[] content) returns AlumniCsv[]|error {
    byte[] processed = content;
    if content.length() >= 3 && content[0] == 0xEF && content[1] == 0xBB && content[2] == 0xBF {
        processed = content.slice(3);
    }
    string csvString = check string:fromBytes(processed);
    AlumniCsv[] records = check csv:parseString(csvString, {delimiter: ";"});
    log:printInfo(string `Parsed ${records.length()} alumni records`);
    return records;
}

function processPerformanceFile(byte[] csvBytes) returns error? {
    AlumniCsv[] alumni = check parseAlumniCsv(csvBytes);

    time:Utc startTime = time:utcNow();
    log:printInfo(string `Loading ${alumni.length()} alumni records...`);

    // Build all parameterized queries (skip alumni with empty or null Id)
    sql:ParameterizedQuery[] insertQueries = from AlumniCsv a in alumni
        where a.Id != 0 && a.Nom != ""
        select `INSERT INTO etudiants (id, nom, prenom, email, actif) VALUES (${a.Id}, ${a.Nom}, ${a.Prenom}, ${a.Email}, ${a.Statut == "TRUE"})`;

    // Execute batch insert
    int totalInserted = 0;
    int errors = 0;

    sql:ExecutionResult[]|error result = mysqlClient->batchExecute(insertQueries);
    if result is sql:ExecutionResult[] {
        totalInserted = result.length();
    } else {
        log:printError(string `Batch error: ${result.message()}`);
        errors = insertQueries.length();
    }

    time:Utc endTime = time:utcNow();
    decimal timeTaken = time:utcDiffSeconds(endTime, startTime);

    decimal rowsPerSecond = totalInserted > 0 && timeTaken > 0d ?
        <decimal>totalInserted / timeTaken : 0d;

    string perfReport = string `
====================================================
     PERFORMANCE TEST RESULTS
====================================================
  Total Records  : ${alumni.length()}
  Inserted       : ${totalInserted}
  Errors         : ${errors}
  Time Taken     : ${timeTaken} seconds
  Rows/Second    : ${rowsPerSecond}
====================================================`;

    log:printInfo(perfReport);

    // Send email with results
    check sendPerformanceEmail(perfReport);
}

function sendPerformanceEmail(string report) returns error? {
    if !enableEmail {
        log:printInfo("Email disabled — skipping");
        return;
    }

    email:SmtpClient smtp = check new (
        host = smtpHost, username = smtpUser, password = smtpPassword,
        clientConfig = {port: smtpPort, security: email:START_TLS_AUTO}
    );

    check smtp->sendMessage({
        to: recipientEmail,
        subject: "EPFL Performance Test - Results",
        'from: smtpUser,
        body: report
    });
    log:printInfo(string `Performance report emailed to ${recipientEmail}`);
}
