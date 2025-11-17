# ÍNDICE DE DOCUMENTACIÓN - EPILEPSY TRACKER

## Documentos Disponibles

### 1. PROYECTO_RESUMEN.md
**Resumen ejecutivo completo del proyecto**
- Visión general del proyecto Flutter
- Pantallas y componentes existentes
- Base de datos SQLite implementada
- Arquitectura y estructura de carpetas
- Sistema de navegación
- Modelos de datos (Medication, Seizure)
- Integraciones (Fitbit, FHIR)
- Dependencias principales
- Estado actual (qué existe, qué falta)

**Ideal para**: Entender rápidamente toda la arquitectura

---

### 2. EJEMPLOS_CODIGO.md
**Código fuente con ejemplos prácticos**
- Modelo Medication (código completo)
- Servicio de BD SeizureDatabaseService
- Servicio Fitbit OAuth2
- Sistema de Navegación (main.dart)
- Configuración de Tema (Material Design 3)
- Bottom Navigation Bar
- Modelo Seizure con tipos y síntomas

**Ideal para**: Copiar y pegar código existente, entender patrones

---

### 3. ESTRUCTURA_PROYECTO.txt
**Árbol visual de directorios**
- Jerarquía completa de /lib
- Organización de carpetas
- Propósito de cada directorio

**Ideal para**: Navegación rápida, entender dónde está cada cosa

---

### 4. RECOMENDACIONES.md
**Guía paso a paso para nuevas features**
- Cómo implementar persistencia de medicamentos
- Cómo agregar notificaciones push
- Mejoras sugeridas (Provider, Firebase, etc.)
- Estructura propuesta post-implementación
- Checklist de tareas
- Archivos clave a revisar

**Ideal para**: Desarrollar nuevas features, entender qué hay que hacer

---

## Mapa Rápido

```
¿Quiero entender...?

├─ Toda la arquitectura
│  └─> PROYECTO_RESUMEN.md
│
├─ Cómo está organizado el código
│  └─> ESTRUCTURA_PROYECTO.txt
│
├─ Modelos de datos y servicios
│  └─> EJEMPLOS_CODIGO.md
│
├─ Cómo agregar medicamentos a BD
│  └─> RECOMENDACIONES.md (Sección 1)
│
├─ Cómo implementar notificaciones
│  └─> RECOMENDACIONES.md (Sección 2)
│
└─ Mejoras futuras
   └─> RECOMENDACIONES.md (Secciones 3-5)
```

---

## Información por Rol

### Para Product Managers
1. Lee: PROYECTO_RESUMEN.md (Secciones 1, 11)
2. Lee: RECOMENDACIONES.md (Secciones 3-5)
3. Consulta: Checklist de implementación

### Para Desarrolladores Flutter
1. Lee: PROYECTO_RESUMEN.md (Completo)
2. Consulta: EJEMPLOS_CODIGO.md (Según necesidad)
3. Sigue: RECOMENDACIONES.md (Para nuevas features)
4. Usa: ESTRUCTURA_PROYECTO.txt (Para navegación)

### Para QA/Testers
1. Lee: PROYECTO_RESUMEN.md (Secciones 1, 6, 8)
2. Usa: ESTRUCTURA_PROYECTO.txt
3. Consulta: RECOMENDACIONES.md (Checklist, Sección 5)

### Para Diseñadores
1. Lee: PROYECTO_RESUMEN.md (Sección 4)
2. Lee: EJEMPLOS_CODIGO.md (Sección 5 - Theme)
3. Archivos: /lib/core/constants/

---

## Rutas de Archivos Importantes

### Modelos de Datos
- `/lib/core/models/medication.dart` - Modelo de medicamento
- `/lib/models/seizure.dart` - Modelo de ataque epiléptico
- `/lib/models/fitbit_data.dart` - Datos de Fitbit

### Servicios
- `/lib/services/seizure_database_service.dart` - BD para ataques
- `/lib/services/fitbit_service.dart` - Integración Fitbit
- `/lib/services/fhir_service.dart` - Estándar FHIR

### Pantallas Principales
- `/lib/features/home/home_screen_new.dart` - Pantalla de inicio
- `/lib/features/medications/medications_screen_new.dart` - Medicamentos
- `/lib/features/insights/insights_screen_new.dart` - Analytics
- `/lib/features/relaxation/relaxation_screen_new.dart` - Relajación

### Configuración
- `/lib/main.dart` - Punto de entrada y navegación
- `/lib/app/theme.dart` - Tema Material Design 3
- `/lib/core/constants/` - Colores, textos, dimensiones
- `/pubspec.yaml` - Dependencias del proyecto

---

## Estadísticas del Proyecto

- **Total de líneas de código**: 7,415
- **Número de archivos Dart**: 35+
- **Base de datos**: SQLite (epilepsy_tracker.db)
- **Framework**: Flutter 3.9.2+
- **Idioma**: Alemán (i18n en trabajo)
- **Integraciones**: Fitbit, FHIR, Secure Storage

---

## Estado del Proyecto

✅ **IMPLEMENTADO**
- Registro de ataques epilépticos
- Seguimiento de medicamentos (con demo data)
- Integración Fitbit (OAuth2)
- Analytics e Insights
- Wohlbefinden (bienestar)
- Relajación/respiración
- Base de datos SQLite
- Tema Material Design 3

❌ **NO IMPLEMENTADO**
- Persistencia de medicamentos
- Notificaciones/recordatorios
- Sincronización en la nube
- Exportación de reportes PDF
- State management activado (Provider)

---

## Próximos Pasos Recomendados

1. Implementar MedicationDatabaseService (Sección 1 de RECOMENDACIONES.md)
2. Persistir medicamentos en SQLite
3. Agregar NotificationService
4. Programar recordatorios de medicamentos
5. Implementar Provider para state management
6. Agregar pantalla para crear medicamentos nuevos
7. Sincronización en la nube (Firebase o similar)

---

## Contacto/Ayuda

Para dudas específicas sobre:
- **Arquitectura**: Revisa ESTRUCTURA_PROYECTO.txt
- **Código existente**: Revisa EJEMPLOS_CODIGO.md
- **Implementación**: Revisa RECOMENDACIONES.md
- **General**: Revisa PROYECTO_RESUMEN.md

