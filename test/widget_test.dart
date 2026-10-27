import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:medical_app/main.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES', null);
  });

  Future<void> openHomeScreen(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'Muestra el logo en la splash y luego abre la pantalla principal',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ProviderScope(child: MedicalApp()));
      await tester.pump();

      expect(find.text('Citas Médicas'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Mis Citas'), findsNothing);

      await openHomeScreen(tester);

      expect(find.text('Mis Citas'), findsOneWidget);
      expect(find.text('Agendar'), findsOneWidget);

      await tester.tap(find.text('Agendar'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Si necesitas agendar una cita, visita el sitio de Telesalud.',
        ),
        findsOneWidget,
      );
      expect(find.text('Visitar Telesalud'), findsOneWidget);
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Ver tutorial para confirmar citas'));
      await tester.pumpAndSettle();

      expect(find.text('Cómo confirmar una cita'), findsOneWidget);
      expect(find.byIcon(Icons.play_circle_outline), findsOneWidget);
    },
  );

  testWidgets('Simula cancelación por profesional y permite agendar nuevamente', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MedicalApp()));
    await openHomeScreen(tester);

    await tester.tap(
      find.byTooltip('Simular aviso de profesional no disponible'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cambio en tu cita'), findsOneWidget);
    expect(find.text('Visitar Telesalud'), findsOneWidget);
    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();

    expect(find.text('Cancelada por el profesional'), findsOneWidget);
    expect(
      find.text(
        'Cancelada por el profesional debido a un inconveniente de horario.',
      ),
      findsOneWidget,
    );
    expect(find.text('Agendar nuevamente'), findsOneWidget);

    await tester.tap(find.text('Agendar nuevamente'));
    await tester.pumpAndSettle();
    expect(find.text('Visitar Telesalud'), findsOneWidget);
    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Dr. Roberto Sánchez'));
    await tester.pumpAndSettle();
    expect(find.text('Cambié de opinión: Sí podré asistir'), findsNothing);
    expect(
      find.text(
        'Tu aviso oportuno permitió que el centro médico libere este horario para otro paciente en lista de espera.',
      ),
      findsNothing,
    );
  });

  testWidgets('Carga inicial, Drawer y navegación a Configuración', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MedicalApp()));
    await openHomeScreen(tester);

    // 1. Verifica pantalla principal
    expect(find.text('Mis Citas'), findsOneWidget);

    // 2. Abre el Drawer
    final ScaffoldState scaffoldState = tester.firstState(
      find.byType(Scaffold),
    );
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    // 3. Verifica datos del paciente y enlaces del Drawer
    expect(find.text('Usuario'), findsOneWidget);
    expect(find.text('usuario@email.com'), findsOneWidget);
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Historial Clínico'), findsOneWidget);

    // 4. Navega a la pantalla de Configuración
    await tester.tap(find.text('Configuración'));
    await tester.pumpAndSettle();

    // 5. Verifica que los elementos clave de Configuración estén presentes
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Perfil del Paciente'), findsOneWidget);
    expect(
      find.byIcon(Icons.edit_outlined),
      findsNothing,
    ); // Sin botón de editar
    expect(find.text('Apariencia'), findsOneWidget);
    expect(find.text('Tamaño del texto'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('Tema de la aplicación'), findsOneWidget);
    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Notificaciones push'), findsOneWidget);

    // 6. Prueba interactiva: cambiar tema a "Oscuro"
    expect(find.text('Oscuro'), findsOneWidget);
    await tester.tap(find.text('Oscuro'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Normal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Muy grande').last);
    await tester.pumpAndSettle();
    final textScaleFactor = MediaQuery.textScalerOf(
      tester.element(find.text('Apariencia')),
    ).scale(10);
    expect(textScaleFactor, closeTo(14, 0.01));

    await tester.tap(find.text('Muy grande'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Normal').last);
    await tester.pumpAndSettle();

    // 7. Prueba interactiva: cambiar switch de Notificaciones Push
    final switchFinder = find.byType(Switch).first;
    await tester.ensureVisible(switchFinder);
    await tester.pumpAndSettle();
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // 8. Hacer scroll y verificar elementos inferiores
    await tester.scrollUntilVisible(
      find.text('Centro de ayuda'),
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Centro de ayuda'), findsOneWidget);
    expect(find.text('Restablecer ajustes'), findsOneWidget);
    expect(find.textContaining('v1.0.0'), findsNothing);
  });

  testWidgets('Navegación a Historial Clínico con citas pasadas', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MedicalApp()));
    await openHomeScreen(tester);

    // Abrir Drawer
    final ScaffoldState scaffoldState = tester.firstState(
      find.byType(Scaffold),
    );
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    // Tocar 'Historial Clínico'
    await tester.tap(find.text('Historial Clínico'));
    await tester.pumpAndSettle();

    // Verificar pantalla de Historial Clínico
    expect(find.text('Historial Clínico'), findsOneWidget);

    // Verificar citas pasadas
    expect(find.text('Dr. Roberto Sánchez'), findsOneWidget);
    expect(find.textContaining('Médico General'), findsOneWidget);
    expect(find.text('Dra. María Gómez'), findsOneWidget);
    expect(find.textContaining('Nutricionista'), findsOneWidget);
    expect(find.text('Completada'), findsNothing);

    // Verificar ausencia de filtros y resúmenes
    expect(find.text('Ficha N° HC-482910 • Plan Activo'), findsNothing);
    expect(find.text('Filtros'), findsNothing);
  });

  testWidgets('Flujo de confirmación e inasistencia con selección de motivo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MedicalApp()));
    await openHomeScreen(tester);

    // 1. Verificar el banner de Acción Requerida (2 turnos pendientes)
    expect(find.text('2 Turnos pendientes de confirmación'), findsOneWidget);

    // 2. Tocar la cita de Dra. María Gómez para abrir la pantalla de detalle
    await tester.tap(find.text('Dra. María Gómez'));
    await tester.pumpAndSettle();

    // 3. Verificar que se abrió la pantalla de detalle y presionar "No podré asistir"
    expect(find.text('Confirmar Turno'), findsOneWidget);
    final confirmButton = find.text('Confirmar cita');
    final cancelButton = find.text('Cancelar cita');
    expect(confirmButton, findsOneWidget);
    expect(cancelButton, findsOneWidget);
    expect(
      tester.getCenter(confirmButton).dy,
      closeTo(tester.getCenter(cancelButton).dy, 1),
    );
    expect(
      tester.getTopLeft(cancelButton).dy,
      lessThan(tester.getTopLeft(find.byType(Card).first).dy),
    );

    await tester.scrollUntilVisible(
      cancelButton,
      200.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(cancelButton);
    await tester.pumpAndSettle();

    // 4. Verificar que el diálogo de inasistencia está abierto y confirmar liberación
    expect(find.text('Avisar Inasistencia'), findsOneWidget);
    expect(find.text('Conflicto de horario o trabajo'), findsOneWidget);
    await tester.tap(find.text('Liberar Turno'));
    await tester.pumpAndSettle();

    // 5. Volver a la pantalla principal
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // 6. Verificar que el contador ahora bajó a 1 turno pendiente
    expect(find.text('1 Turno pendiente de confirmación'), findsOneWidget);
    expect(find.text('2 Turnos pendientes de confirmación'), findsNothing);
  });
}
