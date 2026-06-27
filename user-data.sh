#!/bin/bash
# ============================================================
# user-data.sh
# Script de arranque (User Data) para las instancias EC2
# Arquitectura Cloud de 3 capas - AWS
# Autor: Carlos Gabriel Peña Arandia (CGPA)
# Asignatura: Soluciones Cloud (CCY0010)
#
# Funcion: instala Apache, obtiene metadatos de la instancia
# (hostname y zona de disponibilidad) y genera una pagina web
# que evidencia el balanceo de carga entre zonas.
# ============================================================

# Instalar y habilitar el servidor web Apache
dnf install -y httpd
systemctl enable httpd
systemctl start httpd

# Obtener metadatos de la instancia usando IMDSv2 (token de seguridad)
TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
  -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/placement/availability-zone)
HOST=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" \
  http://169.254.169.254/latest/meta-data/local-hostname)

# Generar la pagina web con los datos de la instancia
cat > /var/www/html/index.html <<HTML
<!DOCTYPE html>
<html lang="es">
<head><meta charset="UTF-8"><title>EFT Cloud - Carlos Pena</title>
<style>
body{font-family:sans-serif;text-align:center;padding:60px;background:#0f6e56;color:#fff}
.card{background:#fff;color:#222;display:inline-block;padding:40px 60px;border-radius:16px}
h1{color:#0f6e56}
</style></head>
<body><div class="card">
<h1>Arquitectura Cloud de 3 capas</h1>
<p><strong>Carlos Gabriel Pena Arandia</strong></p>
<p>Servidor: <strong>$HOST</strong></p>
<p>Zona de disponibilidad: <strong>$AZ</strong></p>
</div></body></html>
HTML

# Reiniciar Apache para asegurar que toma el nuevo contenido
systemctl restart httpd
