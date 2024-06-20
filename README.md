# SQLscape

SQLscape is a Bash tool designed to detect SQL injection vulnerabilities in URLs using specific payloads. This utility automates the security verification process by sending HTTP requests modified with known SQL payloads and analyzing responses to detect potential vulnerabilities.

## Installation

To download SQLscape and prepare it for use, follow these steps:

```bash
# Clone the SQLscape repository
git clone https://github.com/Sadenes/sqlscape.git

# Grant execution permissions to the script
chmod +x sqlscape.sh
Usage
To start using SQLscape, follow these steps:

Ensure you have curl installed on your system.
Navigate to the directory where SQLscape is cloned.
Run the script with the appropriate options:
# Example usage with a list of URLs and SQL payloads file
./sqlscape.sh -l urls.txt -p payloadssqli.txt

# Example usage with a specific URL and SQL payloads file
./sqlscape.sh -u http://example.com/page?id=1 -p payloadssqli.txt
