#!/bin/bash

# Función para mostrar mensajes de estado
show_status() {
    printf "[*] %s\n" "$1"
}

# Función para mostrar el encabezado
show_header() {
    echo "                                                                    "
    echo "  ███████╗ ██████╗ ██╗     ███████╗ ██████╗ █████╗ ██████╗ ███████╗ "
    echo "  ██╔════╝██╔═══██╗██║     ██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝ "
    echo "  ███████╗██║   ██║██║     ███████╗██║     ███████║██████╔╝█████╗   "
    echo "  ╚════██║██║▄▄ ██║██║     ╚════██║██║     ██╔══██║██╔═══╝ ██╔══╝   "
    echo "  ███████║╚██████╔╝███████╗███████║╚██████╗██║  ██║██║     ███████╗ "
    echo "  ╚══════╝ ╚══▀▀═╝ ╚══════╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝     ╚══════╝ "
    echo ""
    echo " SQLscape - Detect SQL injections in URLs            "
    echo " Version: 1.1                                        "
    echo " Author: kvendish                                    "
    echo "                                                     "
    echo "                                                     "
    echo ""
}

# Mostrar el encabezado al iniciar la herramienta
show_header

# Función para mostrar ayuda
show_help() {
    echo "Usage: $0 [-l urls_file | -u single_url] -p payloads_file [-h]"
    echo ""
    echo "Options:"
    echo "  -l urls_file    File containing list of URLs to check for SQLi"
    echo "  -u single_url   Single URL to check for SQLi"
    echo "  -p payloads_file  File containing SQL injection payloads"
    echo "  -h              Show this help message"
    echo ""
    echo "Description:"
    echo "  SQLscape is a tool to detect SQL injections in URLs using specified payloads."
    echo "  It identifies vulnerabilities, attempts to detect the database type, and more."
    echo ""
    echo "Functions:"
    echo "  1. check_sqli_vulnerability(url, payloads_file): Checks if a URL is vulnerable to SQL injection using payloads."
    echo ""
    echo "Example:"
    echo "  $0 -l urls.txt -p sql_payloads.txt"
    echo "  $0 -u http://example.com/page?id=1 -p sql_payloads.txt"
    echo ""
    exit 0
}

# Función para verificar si una URL es vulnerable a SQLi y detectar la base de datos
check_sqli_vulnerability() {
    local url="$1"
    local payloads_file="$2"
    show_status "Checking SQLi vulnerability for: $url"

    local vulnerable=false
    local injection_points=()
    local db_type="Unknown"

    # Verificar que el archivo de payloads exista y sea legible
    if [ ! -f "$payloads_file" ]; then
        show_status "Error: Payloads file '$payloads_file' not found or not readable."
        exit 1
    fi

    # Obtener la longitud del contenido de la respuesta original sin inyección
    local original_content=$(curl -s -L "$url")
    local original_length=${#original_content}

    # Leer los payloads del archivo y verificar cada uno
    while IFS= read -r payload; do
        local full_url="$url$payload"
        show_status "Testing payload: $payload"

        # Realizar la solicitud y capturar el código de respuesta y el contenido
        local response=$(curl -s -L -I "$full_url" -o /dev/null -w '%{http_code}')
        local content=$(curl -s -L "$full_url")
        local content_length=${#content}

        if [ "$response" -eq 200 ] || [ "$response" -eq 500 ]; then
            # Verificar diferencias en el contenido para confirmar la vulnerabilidad SQLi
            if [[ $content =~ "SQL syntax" || $content =~ "mysql_fetch_array" || $content =~ "you have an error in your SQL syntax" || $content =~ "KumbiaException: Posible intento de hack" || $content =~ "PostgreSQL query failed" || $content =~ "Microsoft OLE DB Provider for SQL Server" || $content =~ "SQLite3::SQLException" || $content =~ "syntax error in SQLite" || $content =~ "Warning: oci_fetch_array" || $content =~ "Sybase message" ]] || [ "$content_length" -ne "$original_length" ]; then
                show_status "Potential SQLi vulnerability found with payload: $payload"
                vulnerable=true
                injection_points+=("$full_url")

                # Detectar el tipo de error SQLi
                local error_type=""
                if [[ $content =~ "SQL syntax" || $content =~ "you have an error in your SQL syntax" ]]; then
                    error_type="Error-based SQL Injection"
                elif [[ $content =~ "mysql_fetch_array" ]]; then
                    error_type="Blind SQL Injection"
                elif [[ $content =~ "KumbiaException: Posible intento de hack" ]]; then
                    error_type="Custom SQL Injection Detection"
                elif [[ $content =~ "PostgreSQL query failed" ]]; then
                    error_type="PostgreSQL Error-based SQL Injection"
                elif [[ $content =~ "Microsoft OLE DB Provider for SQL Server" ]]; then
                    error_type="Microsoft SQL Server Error-based SQL Injection"
                elif [[ $content =~ "SQLite3::SQLException" || $content =~ "syntax error in SQLite" ]]; then
                    error_type="SQLite Error-based SQL Injection"
                elif [[ $content =~ "Warning: oci_fetch_array" ]]; then
                    error_type="Oracle Error-based SQL Injection"
                elif [[ $content =~ "Sybase message" ]]; then
                    error_type="Sybase Error-based SQL Injection"
                else
                    error_type="Content length change detected, potential SQL Injection"
                fi

                # Detectar el tipo de base de datos
                if [[ $content =~ "MySQL" ]]; then
                    db_type="MySQL"
                elif [[ $content =~ "PostgreSQL" ]]; then
                    db_type="PostgreSQL"
                elif [[ $content =~ "Microsoft SQL Server" ]]; then
                    db_type="Microsoft SQL Server"
                elif [[ $content =~ "SQLite" ]]; then
                    db_type="SQLite"
                elif [[ $content =~ "Oracle" ]]; then
                    db_type="Oracle"
                elif [[ $content =~ "Sybase" ]]; then
                    db_type="Sybase"
                # Agregar más casos según sea necesario para otros tipos de bases de datos
                fi

                show_status "Injection point: $full_url"
                show_status "Error type: $error_type"
                show_status "Database type detected: $db_type"
            fi
        fi
    done < "$payloads_file"

    if ! $vulnerable; then
        show_status "No SQLi vulnerability detected at: $url"
    else
        show_status "SQLi vulnerabilities detected at the following points:"
        for point in "${injection_points[@]}"; do
            show_status "$point"
        done
    fi
}

# Función principal del script
main() {
    local urls=()
    local single_url=""
    local payloads_file=""

    # Procesar argumentos de línea de comandos
    while getopts "l:u:p:h" opt; do
        case $opt in
            l)
                # Leer las URLs de un archivo
                while IFS= read -r line; do
                    urls+=("$line")
                done < "$OPTARG"
                ;;
            u)
                single_url="$OPTARG"
                ;;
            p)
                payloads_file="$OPTARG"
                ;;
            h)
                show_help
                ;;
            \?)
                echo "Invalid option: -$OPTARG"
                show_help
                ;;
        esac
    done

    # Verificar que se haya especificado el archivo de payloads
    if [ -z "$payloads_file" ]; then
        show_status "Error: Payloads file not specified."
        exit 1
    fi

    # Verificar si se proporcionó una lista de URLs o una sola URL
    if [ ${#urls[@]} -gt 0 ]; then
        # Iterar sobre la lista de URLs
        for url in "${urls[@]}"; do
            # Llamar a la función para verificar vulnerabilidad SQLi con los payloads
            check_sqli_vulnerability "$url" "$payloads_file"
        done
    elif [ -n "$single_url" ]; then
        # Llamar a la función para verificar vulnerabilidad SQLi con los payloads
        check_sqli_vulnerability "$single_url" "$payloads_file"
    else
        show_status "Error: No URLs provided."
        exit 1
    fi
}

# Verificar la existencia de curl antes de proceder
if ! command -v curl &> /dev/null; then
    show_status "Error: 'curl' command not found. Please install curl."
    exit 1
fi

# Llamar a la función principal para comenzar la ejecución del script
main "$@"
