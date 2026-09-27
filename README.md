# PracticeZone

**Practica vocabulario en inglés en cualquier lugar, incluso sin conexión.**  
App iOS para hispanohablantes con IA que se ejecuta directamente en el dispositivo.

## Resumen ejecutivo

> Imagina entrar al metro o subir a un vuelo sin Wi-Fi y aprovechar ese tiempo muerto para practicar inglés. En PracticeZone, Apple Intelligence vive en tu dispositivo: corrige la gramática de tus frases, genera significados y ejemplos y revisa tus respuestas escritas en los exámenes, sin conexión y sin enviar tus datos a ningún servidor.

PracticeZone cierra la brecha entre **reconocer una palabra** y **saber usarla**: el usuario escribe oraciones propias con su vocabulario y recibe retroalimentación al momento.

## 🎬 Ver demo

<p align="center">
  <a href="https://youtube.com/shorts/NJ5rrB_D2Ts">
    <img src="https://img.youtube.com/vi/NJ5rrB_D2Ts/hqdefault.jpg" alt="Demo de PracticeZone en YouTube" width="320">
  </a>
  <br>
</p>

---

## Qué ofrece

- **Grupos temáticos** de vocabulario: viajes, trabajo, phrasal verbs…
- **Significados, traducciones y ejemplos** generados con IA, que el usuario revisa y edita antes de guardar.
- **Práctica escrita** de frases de hasta 200 caracteres con corrección gramatical.
- **Exámenes** de opción múltiple y producción escrita; las respuestas se revelan al final.
- **Historial de resultados** por grupo.
- **Audio** con voz `en-US` y pronunciación amigable escrita por el usuario.
- **Sin conexión:** crear y editar vocabulario nunca depende de la red ni de la IA.

## Apple Intelligence: potencial y límites

| Lo que aporta | Lo que no resuelve |
|---|---|
| **Privacidad:** nada sale del dispositivo. | Requiere un dispositivo compatible, Apple Intelligence activada, el modelo descargado y un idioma y región admitidos. |
| **Disponibilidad:** sin conexión y sin coste por solicitud. | Modelo compacto, con límites de contexto y de respuesta. |
| **Salidas estructuradas** con `@Generable`. | Puede equivocarse en significados, traducciones o correcciones. |
| **Respuesta rápida** en frases cortas. | No juzga si la palabra se usó con el significado correcto. |

**Por qué la corrección es solo gramatical.** Para comprobar si la palabra se usó con el significado correcto, el modelo tendría que recibir en cada solicitud, al menos, la palabra y sus significados. En un modelo local con contexto y respuesta limitados, eso aumenta la latencia, puede superar el límite de contexto y no garantiza un resultado más fiable. Por eso PracticeZone solo le pide al modelo la frase corregida. Tampoco comprueba si la palabra estudiada aparece en la oración, porque tendría que reconocerla en sus distintos tiempos verbales y formas gramaticales.

**Sin IA disponible**, la app no se bloquea: oculta esas funciones, explica el motivo y mantiene la biblioteca y la edición manual.

## Tecnología

<p align="left">
  <kbd>SwiftUI</kbd> • <kbd>SwiftData</kbd> • <kbd>Apple Intelligence</kbd> • <kbd>@Generable</kbd> • <kbd>AVSpeechSynthesizer</kbd>
</p>

## Arquitectura

```text
Views / Components  →  ViewModels (estado y generación con IA)  →  Services · Model (SwiftData, @Generable)  →  Foundation Models
```

- `Model/`: modelos SwiftData y tipos `@Generable`.
- `ViewModels/`: estado de cada pantalla y generación con IA por streaming, con una sesión por solicitud.
- `Services/`: validaciones y reglas sin interfaz.
- `Views/` y `Components/`: pantallas y componentes reutilizables.

## Evolución: arquitectura multimodelo

Un solo modelo generalista no es óptimo para todas las tareas lingüísticas. La evolución natural es una capa que elija el modelo según la tarea: **Apple Intelligence** como opción local por defecto, un **modelo especializado de mayor capacidad** para correcciones complejas y **evaluación semántica**. El objetivo no es reemplazar a Apple Intelligence, sino complementarla cuando haya una mejora medible.

## Estado y siguientes pasos

- [x] Biblioteca por grupos, práctica escrita, exámenes con historial y persistencia con SwiftData.
- [x] Funciones de IA condicionadas a la disponibilidad de Apple Intelligence.
- [ ] Evaluación semántica del uso de las palabras.
- [ ] Métricas de calidad para las correcciones.
- [ ] Arquitectura multimodelo con privacidad por diseño.

## Aprendizajes: accesibilidad

> Fue una de las partes con mayor curva de aprendizaje y sigue siendo una de las grandes mejoras que le faltan a la app. La IA acelera el código, pero no garantiza un foco correcto, una lectura clara con VoiceOver, buen contraste, objetivos táctiles adecuados ni una navegación comprensible. Es fundamental formarse para comprender, implementar y validar la accesibilidad.
