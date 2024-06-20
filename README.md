# SQLscape

SQLscape es una herramienta en Bash diseñada para detectar vulnerabilidades de inyección SQL en URLs mediante el uso de payloads específicos. Esta utilidad automatiza el proceso de verificación de seguridad al enviar solicitudes HTTP modificadas con payloads SQL conocidos y analizar las respuestas para detectar posibles vulnerabilidades.

## Instalación

Puedes descargar la última versión en formato tarball haciendo clic [aquí](#) o la última versión en formato zip haciendo clic [aquí](#).

Preferiblemente, puedes descargar SQLscape clonando el repositorio Git:

```bash
git clone --depth 1 https://github.com/tuusuario/sqlscape.git
SQLscape funciona en cualquier plataforma que admita scripts Bash.

Uso
Para comenzar a utilizar SQLscape, sigue estos pasos:

Asegúrate de tener instalado curl en tu sistema.
Navega al directorio donde has clonado SQLscape.
Ejecuta el script con las opciones adecuadas:
bash
Copiar código
./sqlscape.sh -l urls.txt -p sql_payloads.txt
./sqlscape.sh -u http://ejemplo.com/pagina?id=1 -p sql_payloads.txt
