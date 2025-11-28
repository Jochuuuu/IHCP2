# 🏥 Sistema de Gestión Hospitalaria VR -  

> Proyecto Universitario - Interacción Humano-Computadora (IHC)  
> Universidad de Ingeniería y Tecnología (UTEC)

Sistema interactivo de gestión hospitalaria desarrollado en **Roblox VR** para simular procesos de atención médica, gestión de pacientes y flujos de trabajo hospitalarios.

## 🎯 Características

- 🥽 **Experiencia VR completa** - Navegación y manipulación de objetos en realidad virtual
- 👥 **Simulación de pacientes** - Sistema de colas con NPCs inteligentes
- 📋 **Gestión de derivaciones** - CHIP, informes médicos, y fichas de atención
- 🎮 **Interfaz intuitiva** - Menús 3D y controles optimizados para VR
- 📊 **Tutorial interactivo** - Sistema de guía paso a paso integrado

## 🛠️ Tecnologías

- **Motor**: Roblox Studio
- **Lenguaje**: Luau (Lua optimizado)
- **Sincronización**: Argon 2.0
- **Editor**: Visual Studio Code
- **Control de versiones**: Git & GitHub

## 📁 Estructura del Proyecto
```
src/
├── Client/              # Scripts del lado del cliente
│   └── FirstPersonLock.client.luau
├── Server/              # Lógica del servidor
│   └── Main.server.luau
├── Shared/              # Módulos compartidos
│   └── Hello.luau
├── UI/                  # Interfaces gráficas
│   ├── Modulos/        # Sistema de módulos médicos
│   ├── SurfaceGui/     # Menús y tutoriales
│   └── ScreenGui/      # HUD del jugador
└── Workspace/          # Objetos del mundo 3D
```

## 🚀 Instalación y Configuración

### Requisitos Previos

- [Roblox Studio](https://www.roblox.com/create)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Argon CLI](https://argon.wiki/)
- Git

### Configuración Rápida

1. **Clona el repositorio**
```bash
   git clone https://github.com/Jochuuuu/IHCP2.git
   cd IHCP2
```

2. **Inicia el servidor de Argon**
```bash
   argon serve
```

3. **Conecta Roblox Studio**
   - Abre Roblox Studio
   - Instala el [plugin de Argon](https://create.roblox.com/marketplace/asset/11263738833)
   - Conecta a `localhost:8000`
   - Activa **Two-Way Sync**

4. **¡Listo para desarrollar!**
   - Edita archivos en VS Code
   - Los cambios se sincronizan automáticamente con Roblox Studio

## 💻 Comandos Útiles
```bash
# Iniciar servidor de desarrollo
argon serve

# Construir el proyecto
argon build

# Generar sourcemap
argon sourcemap

# Detener sesiones activas
argon stop --all
```

## 📝 Flujos de Trabajo Implementados

### 1. Tutorial Interactivo
- **Inicio**: Introducción al sistema
- **Atención**: Proceso de recepción de pacientes
- **CHIP**: Gestión de fichas de identificación
- **Derivación**: Sistema de referencia entre especialidades
- **Informe**: Generación de reportes médicos

### 2. Sistema de Gestión
- Cola de pacientes automatizada
- Navegación VR con teleportación
- Manipulación de objetos médicos
- Interfaz adaptativa según contexto

## 🎮 Controles VR

| Acción | Control |
|--------|---------|
| Movimiento | Joystick izquierdo |
| Girar vista | Joystick derecho |
| Agarrar objetos | Grip/Gatillo |
| Interactuar | Botón A/X |
| Menú | Botón B/Y |

## 👥 Equipo

- **Desarrollador Principal**: [Jos](https://github.com/Jochuuuu)
- **Curso**: Interacción Humano-Computadora
- **Universidad**: UTEC

## 📄 Licencia

Este proyecto es parte de un trabajo académico universitario.

## 🔗 Links Útiles

- [Documentación de Argon](https://argon.wiki/)
- [Roblox Creator Docs](https://create.roblox.com/docs)
- [Luau Language](https://luau-lang.org/)

---

**Desarrollado con ❤️ en Roblox Studio**