//
//  FolderStructure.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 24/12/25.
//

/ChurchApp
│
├── 📂 Core (Configuración base)
│   ├── 📄 ChurchApp.swift (App Entry Point)
│   ├── 📄 Secrets.swift (API Keys, Configuración Supabase/RevenueCat)
│   └── 📄 Constants.swift
│
├── 📂 Data (La capa de datos pura)
│   ├── 📂 Services (Lógica de red/exterior)
│   │   ├── 📄 AuthService.swift
│   │   ├── 📄 LibraryService.swift
│   │   └── 📄 VimeoService.swift
│   ├── 📂 DTOs (Data Transfer Objects - Decodables de Supabase)
│   │   ├── 📄 UserDTO.swift
│   │   ├── 📄 TeachingDTO.swift
│   │   └── 📄 CollectionDTO.swift
│   └── 📂 Models (SwiftData @Model)
│       ├── 📄 User.swift
│       ├── 📄 Teaching.swift
│       └── 📄 Collection.swift
│
├── 📂 Domain (La lógica de negocio / Managers)
│   ├── 📂 Managers (Los que viven en el Environment)
│   │   ├── 📄 AuthManager.swift
│   │   ├── 📄 LibraryManager.swift
│   │   └── 📄 SubscriptionManager.swift
│   └── 📂 Repositories (Opcional: Si quieres separar aún más el acceso a datos)
│
├── 📂 UI (La capa visual)
│   ├── 📂 Screens (Vistas completas que representan una pantalla)
│   │   ├── 📂 Home
│   │   │   └── 📄 HomeView.swift
│   │   ├── 📂 Library
│   │   │   └── 📄 LibraryView.swift
│   │   └── 📂 Player
│   │       └── 📄 VideoPlayerView.swift
│   ├── 📂 Components (Vistas pequeñas y reutilizables)
│   │   ├── 📄 TeachingRow.swift
│   │   ├── 📄 CollectionCard.swift
│   │   └── 📄 LoadingOverlay.swift
│   └── 📂 Modifiers (ViewModifiers personalizados)
│       └── 📄 PremiumShadowModifier.swift
│
├── 📂 Shared (Utilidades transversales)
│   ├── 📂 Extensions (Extensiones de clases de Apple)
│   │   ├── 📄 Date+Extensions.swift
│   │   ├── 📄 Color+Custom.swift
│   │   └── 📄 View+Extensions.swift
│   └── 📂 Utils (Funciones de ayuda/Helpers)
│       └── 📄 DurationFormatter.swift
│
└── 📂 Resources (Assets y localizaciones)
    ├── 📄 Assets.xcassets
    └── 📄 Localizable.strings
