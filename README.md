# Arquitectura Cloud de 3 Capas en AWS

**Evaluación Final Transversal — Soluciones Cloud (CCY0010)**
**Autor:** Carlos Gabriel Peña Arandia (CGPA)
**Región:** us-east-1 · **Entorno:** AWS Academy Learner Lab

---

## Descripción

Sitio web desplegado sobre una arquitectura de tres capas en AWS, que demuestra el uso de servicios de red, cómputo, base de datos y almacenamiento, aplicando los pilares de una arquitectura bien diseñada en la nube.

La página web muestra el nombre del servidor y la zona de disponibilidad (AZ) que atiende cada solicitud, evidenciando el balanceo de carga entre múltiples AZs.

> **Nota:** la infraestructura se desplegó en un entorno sandbox temporal (AWS Academy). Este repositorio aloja la evidencia reproducible del sistema: el código de la web y el script de despliegue.

---

## Arquitectura

```
Internet
   │
   ▼
Application Load Balancer (alb-cgpa)   ── subredes públicas (2 AZs)
   │
   ▼
Auto Scaling Group (asg-web-cgpa)
   ├── EC2 (Apache)  ── us-east-1a
   └── EC2 (Apache)  ── us-east-1b
   │
   ▼
RDS MySQL (rds-cgpa)  ── subredes privadas
```

Bucket **S3** (`bucket-cgpa-static-web`) para recursos estáticos.

### Capas

| Capa | Servicio | Ubicación |
|------|----------|-----------|
| Presentación / Web | ALB + EC2 (Apache) | Subredes públicas |
| Aplicación | Lógica en instancias EC2 | Subredes públicas |
| Datos | RDS MySQL | Subredes privadas |

---

## Recursos desplegados (nomenclatura CGPA)

| Servicio | Name Tag |
|----------|----------|
| VPC | `cgpa-vpc` (10.0.0.0/16, 2 AZs) |
| Security Groups | `SG-Web-ALB-CGPA`, `SG-Web-EC2-CGPA`, `SG-DB-CGPA` |
| Load Balancer | `alb-cgpa` |
| Target Group | `tg-web-cgpa` |
| Launch Template | `lt-web-cgpa` |
| Auto Scaling Group | `asg-web-cgpa` |
| Base de datos | `rds-cgpa` |
| Almacenamiento | `bucket-cgpa-static-web` |

---

## Seguridad (principio de menor privilegio)

- `SG-Web-ALB-CGPA`: HTTP (80) desde Internet.
- `SG-Web-EC2-CGPA`: HTTP (80) **solo** desde el ALB.
- `SG-DB-CGPA`: MySQL (3306) **solo** desde las EC2.

La base de datos vive en subredes privadas, sin acceso público.

---

## Despliegue

El archivo [`user-data.sh`](./user-data.sh) se configura como *User Data* en el Launch Template (`lt-web-cgpa`). Al lanzarse cada instancia:

1. Instala y arranca Apache.
2. Obtiene los metadatos de la instancia (hostname y AZ) vía IMDSv2.
3. Genera la página web con esos datos.

El Auto Scaling Group lanza las instancias en las subredes públicas de ambas AZs y las registra automáticamente en el target group del ALB.

---

## Archivos

- `index.html` — página web (versión estática de referencia).
- `user-data.sh` — script de arranque de las instancias EC2.
- `docs/` — capturas de pantalla de la implementación.
