# Curso de Automatización con Terraform en OCI

Este repositorio contiene todas las actividades y ejercicios desarrollados durante el curso de **Automatización con Terraform en Oracle Cloud Infrastructure (OCI)**.

## Contenido

Aquí encontrarás los siguientes recursos:

- Archivos de configuración de Terraform (`.tf`)
- Ejemplos de despliegue de recursos en OCI
- Scripts y variables utilizados durante el curso
- Ejercicios prácticos por lección

Cada carpeta corresponde a una lección o módulo específico del curso.

## Objetivo del curso

El objetivo del curso es aprender a utilizar **Terraform** para automatizar la creación, gestión y configuración de recursos en **OCI**, siguiendo las mejores prácticas de infraestructura como código (IaC).

## Notas

- Los archivos de variables con información sensible (`*.tfvars`) están excluidos del repositorio por seguridad (ver `.gitignore`).
- Se recomienda personalizar las variables de acuerdo a tu propio tenancy de OCI.

## Requisitos

- [Terraform](https://www.terraform.io/) instalado
- Acceso a un tenancy de Oracle Cloud Infrastructure (OCI)
- Claves API configuradas

## Uso

Para desplegar una lección, navega al directorio correspondiente y ejecuta:

```bash
terraform init
terraform plan
terraform apply
