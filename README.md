# SQLscape

SQLscape is a Bash tool designed to detect SQL injection vulnerabilities in URLs using specific payloads. This utility automates the security verification process by sending HTTP requests modified with known SQL payloads and analyzing responses to detect potential vulnerabilities.

Installation
----
To download SQLscape and prepare it for use, follow these steps:

git clone https://github.com/Sadenes/sqlscape.git

chmod +x sqlscape.sh


Usage
----
   ./sqlscape.sh -l urls.txt -p payloadssqli.txt

./sqlscape.sh -u http://example.com/page?id=1 -p payloadssqli.txt
`
 
