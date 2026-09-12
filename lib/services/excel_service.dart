import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../models/curso.dart';
import '../models/alumno.dart';
import '../repositories/curso_repository.dart';
import '../repositories/alumno_repository.dart';

class ExcelService {
  final _cursoRepo = CursoRepository();
  final _alumnoRepo = AlumnoRepository();

  /// Genera una plantilla Excel de ejemplo y la guarda en la carpeta Documents/Downloads
  Future<String?> generarPlantilla() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Cursos'];

      // Encabezados
      sheet.appendRow([
        const TextCellValue('Curso'),
        const TextCellValue('Paralelo'),
        const TextCellValue('Turno'),
        const TextCellValue('Aula'),
        const TextCellValue('Alumno'),
        const TextCellValue('Codigo'),
      ]);

      // Datos de ejemplo
      sheet.appendRow([
        const TextCellValue('Matemáticas'),
        const TextCellValue('3° B'),
        const TextCellValue('Matutino'),
        const TextCellValue('101'),
        const TextCellValue('Juan Pérez'),
        const TextCellValue('JP001'),
      ]);
      sheet.appendRow([
        const TextCellValue('Matemáticas'),
        const TextCellValue('3° B'),
        const TextCellValue('Matutino'),
        const TextCellValue('101'),
        const TextCellValue('María García'),
        const TextCellValue('MG002'),
      ]);
      sheet.appendRow([
        const TextCellValue('Historia'),
        const TextCellValue('4° A'),
        const TextCellValue('Vespertino'),
        const TextCellValue('205'),
        const TextCellValue('Carlos López'),
        const TextCellValue('CL003'),
      ]);

      // Guardar en Documents
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/plantilla_cursos.xlsx';
      
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);
      
      return filePath;
    } catch (e) {
      print('Error al generar plantilla: $e');
      return null;
    }
  }

  /// Importa cursos y alumnos desde un archivo Excel
  /// Retorna un mapa con estadísticas: {creados, omitidos, advertencias}
  Future<Map<String, dynamic>> importarCursosYAlumnos(String? filePath) async {
    if (filePath == null) {
      return {'error': 'No se seleccionó ningún archivo'};
    }

    final file = File(filePath);
    if (!await file.exists()) {
      return {'error': 'El archivo no existe'};
    }

    final bytes = await file.readAsBytes();
    final excel = Excel.decodeBytes(bytes);
    
    // Buscar la hoja "Cursos" o usar la primera disponible
    String? sheetName;
    for (final name in excel.tables.keys) {
      if (name.toLowerCase().contains('curso')) {
        sheetName = name;
        break;
      }
    }
    sheetName ??= excel.tables.keys.first;

    final sheet = excel.tables[sheetName]!;
    final rows = sheet.rows;

    if (rows.isEmpty) {
      return {'error': 'La hoja está vacía'};
    }

    // Encontrar índices de columnas (primera fila = encabezados)
    final headers = rows.first.map((cell) => cell?.value.toString().trim().toLowerCase() ?? '').toList();
    
    int idxCurso = headers.indexOf('curso');
    int idxParalelo = headers.indexOf('paralelo');
    int idxTurno = headers.indexOf('turno');
    int idxAula = headers.indexOf('aula');
    int idxAlumno = headers.indexOf('alumno');
    int idxCodigo = headers.indexOf('codigo');

    if (idxCurso == -1 || idxAlumno == -1) {
      return {'error': 'Faltan columnas requeridas: Curso y Alumno son obligatorias'};
    }

    // Si no existen las otras columnas, usar valores por defecto
    idxParalelo = idxParalelo == -1 ? idxCurso + 1 : idxParalelo;
    idxTurno = idxTurno == -1 ? idxCurso + 2 : idxTurno;
    idxAula = idxAula == -1 ? idxCurso + 3 : idxAula;
    idxCodigo = idxCodigo == -1 ? idxAlumno + 1 : idxCodigo;

    int creados = 0;
    int omitidos = 0;
    final advertencias = <String>[];

    // Mapa para agrupar cursos: clave = "curso|paralelo"
    final Map<String, Curso> cursosMap = {};

    // Procesar filas (saltando encabezado)
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      
      // Saltar filas completamente vacías
      if (row.every((cell) => cell == null || cell.value.toString().trim().isEmpty)) {
        continue;
      }

      final cursoNombre = _getCell(row, idxCurso) ?? 'Sin nombre';
      final cursoParalelo = _getCell(row, idxParalelo) ?? '';
      final cursoTurno = _getCell(row, idxTurno) ?? 'Matutino';
      final cursoAula = _getCell(row, idxAula) ?? '';
      final alumnoNombre = _getCell(row, idxAlumno);
      final alumnoCodigo = _getCell(row, idxCodigo) ?? '';

      if (alumnoNombre == null || alumnoNombre.trim().isEmpty) {
        advertencias.add('Fila $i: Alumno sin nombre, se omite.');
        omitidos++;
        continue;
      }

      // Clave única para el curso
      final cursoKey = '$cursoNombre|$cursoParalelo'.toLowerCase().trim();

      // Crear o recuperar curso
      Curso? curso = cursosMap[cursoKey];
      if (curso == null) {
        // Verificar si ya existe en BD
        final existente = await _cursoRepo.buscarPorNombreYParalelo(cursoNombre, cursoParalelo);
        if (existente != null) {
          curso = existente;
          cursosMap[cursoKey] = curso;
        } else {
          // Crear nuevo curso con ID único
          final nuevoId = DateTime.now().millisecondsSinceEpoch.toString() + cursoKey.hashCode.abs().toString();
          curso = await _cursoRepo.crearConId(
            id: nuevoId,
            nombre: cursoNombre,
            paralelo: cursoParalelo,
            turno: cursoTurno,
            aula: cursoAula,
            unidadActual: '',
          );
          cursosMap[cursoKey] = curso;
          creados++;
        }
      }

      // Verificar si el alumno ya existe en este curso
      // Usamos ! porque curso ya no puede ser null aquí
      final alumnoExistente = await _alumnoRepo.buscarPorNombreYCurso(alumnoNombre, curso!.id);
      if (alumnoExistente != null) {
        advertencias.add('Fila $i: "$alumnoNombre" ya existe en ${curso.nombreCompleto}, se omite.');
        omitidos++;
      } else {
        // Crear alumno con ID único
        final nuevoId = DateTime.now().millisecondsSinceEpoch.toString() + alumnoNombre.hashCode.abs().toString() + curso.id.hashCode.toString();
        await _alumnoRepo.crear(
          cursoId: curso.id,
          nombre: alumnoNombre,
          codigo: alumnoCodigo,
        );
        creados++;
      }
    }

    return {
      'creados': creados,
      'omitidos': omitidos,
      'advertencias': advertencias,
    };
  }

  String? _getCell(List<dynamic> row, int index) {
    if (index < 0 || index >= row.length) return null;
    final cell = row[index];
    if (cell == null) return null;
    final value = cell.value.toString().trim();
    return value.isEmpty ? null : value;
  }

  /// Abre selector de archivos y retorna la ruta del archivo seleccionado
  Future<String?> seleccionarArchivo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );
    return result?.files.single.path;
  }
}
