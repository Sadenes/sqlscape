# SQLscape

SQLscape es una herramienta en Bash diseñada para detectar vulnerabilidades de inyección SQL en URLs mediante el uso de payloads específicos. Esta utilidad automatiza el proceso de verificación de seguridad al enviar solicitudes HTTP modificadas con payloads SQL conocidos y analizar las respuestas para detectar posibles vulnerabilidades.

## Installation

Preferably, you can download SQLscape by cloning the Git repository:

```bash
git clone https://github.com/Sadenes/sqlscape.git
chmod +x sqlscape.sh

## Usage
To start using SQLscape, follow these steps:

Make sure you have curl installed on your system.
Navigate to the directory where SQLscape is cloned.
Run the script with appropriate options:

```bash
./sqlscape.sh -l urls.txt -p payloadssqli.txt
./sqlscape.sh -u http://example.com/page?id=1 -p payloadssqli.txt
