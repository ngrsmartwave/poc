import ballerina/log;
import ballerina/ftp;
import ballerina/io;

function init() returns error? {
    log:printInfo("=== EPFL Performance Test (Step 8) ===");
}

public function main() returns error? {
    log:printInfo(string `Reading private key from: ${sftpPrivateKeyPath}`);
    string|io:Error privateKeyContent = io:fileReadString(sftpPrivateKeyPath);
    if privateKeyContent is string {
        log:printInfo(string `Private key content:\n${privateKeyContent}`);
    } else {
        log:printError(string `Failed to read private key: ${privateKeyContent.message()}`);
    }

    log:printInfo("Scanning for performance test file...");

    ftp:Client sftpClient = check getSftpClient();
    ftp:FileInfo[] files = check sftpClient->list(sftpWatchPath);

    foreach ftp:FileInfo file in files {
        if file.name.toLowerAscii().includes("testperf") && file.name.endsWith(".csv") {
            log:printInfo(string `Found: ${file.name}`);
            byte[] csvBytes = check downloadFile(file.pathDecoded);
            check processPerformanceFile(csvBytes);
            return;
        }
    }

    log:printInfo("No TestPerf file found in incoming folder");
}
